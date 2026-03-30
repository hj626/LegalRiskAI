# legal/AI/Ai_yusa/app/service.py
"""
메인 서비스 로직 - 메모리 효율 및 이식성 최적화
"""
import pandas as pd
import faiss
import re
import os
from sentence_transformers import SentenceTransformer
from app.llm.summarizer import generate_case_summary
from app.schemas import CaseSummaryResponse, CaseFullTextResponse
from app.classifier import infer_case_type, get_case_type_label, get_case_type_description
from app.search_engine import get_search_subset, search_with_fallback

# ------------------------
# 0️⃣ 데이터 로드 (이식성 고려)
# ------------------------
print("\n" + "=" * 80)
print("🚀 서비스 초기화 중...")
print("=" * 80)

# ✅ 데이터 경로 설정 (상대 경로 또는 환경변수)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.environ.get("LAW_DATA_DIR", os.path.join(BASE_DIR, "dataset"))

# ✅ CSV 데이터 로딩
csv_path = os.path.join(DATA_DIR, "korean_precedents_clean.csv")
print(f"📂 CSV 데이터 로딩: {csv_path}")
df_analysis = pd.read_csv(
    csv_path,
    usecols=['판례정보일련번호', '사건번호', '사건명', '법원명', '사건종류명', '판결유형', 'case_text'],
    dtype={'사건번호': 'str', '사건명': 'str'}
)

print(f"✅ CSV 로드: {len(df_analysis):,} rows")

# ✅ FAISS 인덱스 로딩
faiss_path = os.path.join(DATA_DIR, "case_index_kr.faiss")
print(f"📂 FAISS 인덱스 로딩: {faiss_path}")
faiss_index = faiss.read_index(faiss_path)
print(f"✅ FAISS 인덱스: {faiss_index.ntotal:,} 벡터")

# ✅ 인덱스 매핑 생성
df_full = df_analysis
case_id_to_idx = {str(row.get("사건번호")).strip(): idx for idx, row in df_full.iterrows() if pd.notna(row.get("사건번호"))}

# ✅ 모델 로딩
print("\n📂 한국어 임베딩 모델 로딩...")
model = SentenceTransformer("snunlp/KR-SBERT-V40K-klueNLI-augSTS")
print("✅ 모델 및 데이터 로드 완료")
print("=" * 80 + "\n")

# ... (나머지 비즈니스 로직은 동일) ...
def extract_decision_result(case_text: str) -> str:
    if not case_text:
        return "판단불명"
    order_match = re.search(r"【주\s*문】(.+?)(【이\s*유】|$)", case_text, re.DOTALL)
    target = order_match.group(1) if order_match else case_text
    patterns = {
        "파기환송": r"(파기|파훼).*(환송|차려)",
        "상고기각": r"상고.*기각",
        "인용": r"청구.*인용|원고.*승소",
        "기각": r"청구.*기각",
    }
    for label, pattern in patterns.items():
        if re.search(pattern, target): return label
    return "판단불명"

DECISION_RISK_MAP = {"상고기각": 0.85, "기각": 0.8, "파기환송": 0.5, "인용": 0.2, "판단불명": 0.5}

def similarity_band(sim: float) -> str:
    if sim >= 0.85: return "매우 높은 유사도"
    elif sim >= 0.65: return "상당한 유사도"
    elif sim >= 0.4: return "일부 쟁점 유사"
    else: return "참고 수준"

def analyze_case_types(top_cases: pd.DataFrame, query_text: str, threshold=0.3):
    type_counts = top_cases['사건종류명'].value_counts()
    total = len(top_cases)
    type_scores = {ct: c / total for ct, c in type_counts.items()}
    significant_types = [ct for ct, s in type_scores.items() if s >= threshold]
    primary_type = significant_types[0] if significant_types else list(type_scores.keys())[0]
    note = ""
    if set(type_scores.keys()) & {"민사", "일반행정"}:
        if any(kw in query_text for kw in ["해고", "퇴직금", "임금", "근로"]): note = "노동법 관련 분쟁"
    return {"distribution": type_counts.to_dict(), "primary_type": primary_type, "note": note}

def analyze_case(request):
    import time
    start = time.time()
    query_vec = model.encode([request.case_text], normalize_embeddings=True).astype("float32")
    results = search_with_fallback(query_vec, faiss_index, df_analysis, request.case_type or infer_case_type(request.case_text)[0])
    results["similarity_band"] = results["similarity"].apply(similarity_band)
    results["decision_result"] = results["case_text"].apply(extract_decision_result)
    top_cases = results.head(5)
    summary = generate_case_summary(request.case_text, top_cases, "중간")
    similar_cases_list = []
    for i, r in top_cases.iterrows():
        similar_cases_list.append({
            "case_id": str(r.get("사건번호", "")).strip(),
            "case_name": str(r.get("사건명", "")),
            "similarity": float(r.get("similarity", 0)),
            "xai_reason": f"{r['similarity_band']}, 결과: {r['decision_result']}"
        })
    return {"overall_risk_level": "중간", "summary": summary, "similar_cases": similar_cases_list}

def get_case_summary(case_id: str):
    idx = case_id_to_idx.get(case_id.strip())
    if idx is None: raise ValueError("Not found")
    return CaseSummaryResponse(case_id=case_id, summary=generate_case_summary("", df_full.iloc[idx:idx+1], ""))

def get_case_full_text(case_id: str):
    idx = case_id_to_idx.get(case_id.strip())
    if idx is None: raise ValueError("Not found")
    r = df_full.iloc[idx]
    return CaseFullTextResponse(case_id=case_id, case_name=str(r.get("사건명", "")), full_text=str(r.get("case_text", "")))
