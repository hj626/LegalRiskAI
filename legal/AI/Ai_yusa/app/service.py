# app/service.py
"""
메인 서비스 로직 - 메모리 효율 최적화
"""
import pandas as pd
import faiss
import re
from sentence_transformers import SentenceTransformer
from app.llm.summarizer import generate_case_summary
from app.schemas import CaseSummaryResponse, CaseFullTextResponse
from app.classifier import infer_case_type, get_case_type_label, get_case_type_description
from app.search_engine import get_search_subset, search_with_fallback

# ------------------------
# 0️⃣ 데이터 로드 (메모리 효율)
# ------------------------
print("\n" + "=" * 80)
print("🚀 서비스 초기화 중...")
print("=" * 80)

# ✅ CSV만 로드 (Parquet보다 메모리 효율적)
print("📂 CSV 데이터 로딩...")
df_analysis = pd.read_csv(
    r"C:\LawAI\notebooks\korean_precedents_clean.csv",
    usecols=['판례정보일련번호', '사건번호', '사건명', '법원명', '사건종류명', '판결유형', 'case_text'],  # ✅ 필요한 컬럼만
    dtype={'사건번호': 'str', '사건명': 'str'}  # ✅ 타입 명시
)

print(f"✅ CSV 로드: {len(df_analysis):,} rows")
print(f"   메모리 사용: {df_analysis.memory_usage(deep=True).sum() / 1024 / 1024:.1f} MB")

# df_full은 df_analysis와 동일
df_full = df_analysis

# ✅ 사건번호 → 인덱스 매핑
case_id_to_idx = {}
for idx, row in df_full.iterrows():
    case_num = row.get("사건번호")
    if pd.notna(case_num):
        normalized = str(case_num).strip()
        if normalized:
            case_id_to_idx[normalized] = idx

print(f"✅ case_id_to_idx 크기: {len(case_id_to_idx):,}")

# 사건종류명 분포
print("\n📊 사건종류명 분포:")
print(df_analysis["사건종류명"].value_counts().head(10))

# ✅ FAISS 인덱스 (한국어 모델)
print("\n📂 FAISS 인덱스 로딩...")
faiss_index = faiss.read_index(
    r"C:\LawAI\notebooks\case_index_kr.faiss"
)
print(f"✅ FAISS 인덱스: {faiss_index.ntotal:,} 벡터")

# ✅ 모델
print("\n📂 한국어 모델 로딩...")
model = SentenceTransformer(
    "snunlp/KR-SBERT-V40K-klueNLI-augSTS"
)
print("✅ 모델 로드 완료")

print("=" * 80 + "\n")

# ------------------------
# 판결 결과 추출
# ------------------------
def extract_decision_result(case_text: str) -> str:
    if not case_text:
        return "판단불명"

    order_match = re.search(
        r"【주\s*문】(.+?)(【이\s*유】|$)",
        case_text,
        re.DOTALL
    )
    target = order_match.group(1) if order_match else case_text

    patterns = {
        "파기환송": r"(파기|파훼).*(환송|차려)",
        "상고기각": r"상고.*기각",
        "인용": r"청구.*인용|원고.*승소",
        "기각": r"청구.*기각",
    }

    for label, pattern in patterns.items():
        if re.search(pattern, target):
            return label
    return "판단불명"

DECISION_RISK_MAP = {
    "상고기각": 0.85,
    "기각": 0.8,
    "파기환송": 0.5,
    "인용": 0.2,
    "판단불명": 0.5
}

def similarity_band(sim: float) -> str:
    if sim >= 0.85:
        return "매우 높은 유사도"
    elif sim >= 0.65:
        return "상당한 유사도"
    elif sim >= 0.4:
        return "일부 쟁점 유사"
    else:
        return "참고 수준"

# ------------------------
# Multi-label 처리
# ------------------------
def analyze_case_types(top_cases: pd.DataFrame, query_text: str, threshold=0.3):
    """검색 결과 기반 복수 유형 분석"""
    type_counts = top_cases['사건종류명'].value_counts()
    total = len(top_cases)
    
    type_scores = {
        case_type: count / total 
        for case_type, count in type_counts.items()
    }
    
    significant_types = [
        case_type 
        for case_type, score in type_scores.items() 
        if score >= threshold
    ]
    
    is_mixed = len(significant_types) > 1
    primary_type = significant_types[0] if significant_types else list(type_scores.keys())[0]
    
    # 특수 케이스
    note = ""
    if set(type_scores.keys()) & {"민사", "일반행정"}:
        labor_keywords = ["해고", "퇴직금", "임금", "근로", "부당해고", "산재", "근로계약"]
        if any(kw in query_text for kw in labor_keywords):
            note = "노동법 관련 민사 분쟁으로 분석됩니다"
            if "노동" not in significant_types:
                significant_types.append("노동")
    
    if set(type_scores.keys()) & {"특허", "민사"}:
        if "침해" in query_text or "손해배상" in query_text:
            note = "특허 침해 손해배상 소송으로 보입니다"
    
    if set(type_scores.keys()) & {"형사", "민사"}:
        if "배상" in query_text or "피해" in query_text:
            note = "형사 사건의 민사적 손해배상도 고려해야 합니다"
    
    return {
        "distribution": type_counts.to_dict(),
        "percentages": type_scores,
        "is_mixed": is_mixed,
        "primary_type": primary_type,
        "significant_types": significant_types,
        "note": note
    }

# ------------------------
# 1️⃣ /analyze
# ------------------------
def analyze_case(request):
    import time
    start = time.time()
    
    print("\n" + "=" * 80)
    print("🚀 analyze_case START")
    print("=" * 80)
    print(f"입력 텍스트 길이: {len(request.case_text)} chars")

    if not request.case_text or not request.case_text.strip():
        raise ValueError("case_text is empty")

    # case_type 처리
    if request.case_type:
        inferred_type = request.case_type
        confidence = 1.0
        print(f"📌 사용자 지정 case_type: {inferred_type}")
    else:
        inferred_type, confidence = infer_case_type(request.case_text)
        print(f"🔍 자동 분류: {inferred_type} (신뢰도: {confidence:.2f})")
    
    type_label = get_case_type_label(inferred_type)
    type_desc = get_case_type_description(inferred_type, confidence)

    # 쿼리 임베딩
    query_vec = model.encode([request.case_text], normalize_embeddings=True).astype("float32")

    # Subset 검색
    results = search_with_fallback(
        query_vec=query_vec,
        faiss_index=faiss_index,
        df_full=df_analysis,
        case_type=inferred_type,
        top_k=10,
        fallback_threshold=3
    )

    print(f"\n📊 최종 검색 결과: {len(results)} 건")

    # 후처리
    results["similarity_band"] = results["similarity"].apply(similarity_band)
    results["decision_result"] = results["case_text"].apply(extract_decision_result)
    results["risk_score"] = results["decision_result"].map(DECISION_RISK_MAP).fillna(0.5)

    avg_risk = results["risk_score"].mean() if len(results) > 0 else 0.5
    overall_risk = (
        "높음" if avg_risk >= 0.7 else "중간" if avg_risk >= 0.4 else "낮음"
    )

    top_cases = results.head(5)

    # Multi-label 분석
    case_type_analysis = analyze_case_types(top_cases, request.case_text)
    print(f"🔍 유형 분포: {case_type_analysis['distribution']}")
    if case_type_analysis['is_mixed']:
        print(f"⚠️ 복수 유형: {case_type_analysis['significant_types']}")

    # 요약 생성
    try:
        summary = generate_case_summary(
            user_case=request.case_text,
            results_df=top_cases,
            overall_risk_level=overall_risk
        )
    except Exception as e:
        print(f"⚠️ 요약 생성 오류: {e}")
        summary = "요약 생성 중 오류가 발생했습니다."

    # 응답 생성
    similar_cases_list = []
    
    for idx, (i, r) in enumerate(top_cases.iterrows()):
        case_num_raw = r.get("사건번호")
        
        case_id = None
        if pd.notna(case_num_raw):
            normalized = str(case_num_raw).strip()
            if normalized in case_id_to_idx:
                case_id = normalized
        
        similar_cases_list.append({
            "case_id": case_id,
            "case_name": str(r.get("사건명", "")),
            "court": str(r.get("법원명", "")),
            "case_number": str(case_num_raw) if pd.notna(case_num_raw) else "",
            "decision_type": str(r.get("판결유형", "판결")),
            "decision_result": str(r.get("decision_result", "판단불명")),
            "similarity": float(r.get("similarity", 0)),
            "case_type_label": str(r.get("사건종류명", "")),
            "xai_reason": (
                f"{r['similarity_band']}에 해당하며 판단 결과는 '{r['decision_result']}'입니다."
            ),
        })

    print(f"\n✅ analyze_case END: {time.time() - start:.2f}s")
    print("=" * 80 + "\n")

    return {
        "overall_risk_level": overall_risk,
        "summary": summary,
        "similar_cases": similar_cases_list,
        "inferred_case_type": inferred_type,
        "case_type_label": type_label,
        "case_type_confidence": confidence,
        "case_type_description": type_desc,
        "search_result_types": case_type_analysis
    }

# ------------------------
# 2️⃣ /case/{case_id}/summary
# ------------------------
def get_case_summary(case_id: str) -> CaseSummaryResponse:
    case_id_norm = case_id.strip()
    
    if case_id_norm not in case_id_to_idx:
        raise ValueError(f"Case not found: {case_id}")
    
    idx = case_id_to_idx[case_id_norm]
    row = df_full.iloc[idx:idx+1]

    try:
        summary = generate_case_summary(
            user_case="",
            results_df=row,
            overall_risk_level=""
        )
    except Exception as e:
        print(f"⚠️ 요약 생성 오류: {e}")
        summary = "요약 생성 불가"

    return CaseSummaryResponse(case_id=case_id, summary=summary)

# ------------------------
# 3️⃣ /case/{case_id}/full
# ------------------------
def get_case_full_text(case_id: str) -> CaseFullTextResponse:
    print(f"📂 get_case_full_text: '{case_id}'")
    
    case_id_norm = case_id.strip()
    
    if case_id_norm not in case_id_to_idx:
        print(f"❌ Case not found: {case_id}")
        raise ValueError(f"Case not found: {case_id}")
    
    idx = case_id_to_idx[case_id_norm]
    r = df_full.iloc[idx]
    
    full_text = r.get("case_text", "")
    
    if not full_text or pd.isna(full_text):
        print(f"⚠️ full_text 비어있음")
        full_text = "판례 전문을 찾을 수 없습니다."
    else:
        print(f"✅ full_text 로드 성공: {len(full_text)} chars")
    
    summary = ""  # 두 번째 요약 제거

    return CaseFullTextResponse(
        case_id=case_id,
        case_name=str(r.get("사건명", "")),
        full_text=full_text,
        summary=summary
    )
