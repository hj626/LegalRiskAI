# legal/AI/Ai_yusa/app/service.py
"""
메인 서비스 로직 - Lifespan 이벤트 도입으로 메모리 효율화
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

# 전역 변수 선언 (Lifespan에서 초기화)
df_analysis = None
faiss_index = None
model = None
case_id_to_idx = {}

def load_data():
    """서버 시작 시 대용량 데이터를 메모리에 로드"""
    global df_analysis, faiss_index, model, case_id_to_idx
    
    print("\n" + "=" * 80)
    print("🚀 Ai_yusa 데이터 로딩 시작...")
    
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    DATA_DIR = os.environ.get("LAW_DATA_DIR", os.path.join(BASE_DIR, "dataset"))

    # CSV 로드
    csv_path = os.path.join(DATA_DIR, "korean_precedents_clean.csv")
    df_analysis = pd.read_csv(
        csv_path,
        usecols=['판례정보일련번호', '사건번호', '사건명', '법원명', '사건종류명', '판결유형', 'case_text'],
        dtype={'사건번호': 'str'}
    )
    
    # FAISS 로드
    faiss_path = os.path.join(DATA_DIR, "case_index_kr.faiss")
    faiss_index = faiss.read_index(faiss_path)
    
    # 인덱스 매핑
    case_id_to_idx = {str(row.get("사건번호")).strip(): idx for idx, row in df_analysis.iterrows() if pd.notna(row.get("사건번호"))}
    
    # 모델 로드
    model = SentenceTransformer("snunlp/KR-SBERT-V40K-klueNLI-augSTS")
    
    print("✅ 데이터 및 모델 로드 완료!")
    print("=" * 80 + "\n")

# ... (분석 함수들은 기존 로직 유지, 전역 변수 참조) ...
def analyze_case(request):
    query_vec = model.encode([request.case_text], normalize_embeddings=True).astype("float32")
    results = search_with_fallback(query_vec, faiss_index, df_analysis, request.case_type or "민사")
    # ... 후처리 로직 ...
    return {"status": "success", "results": []} # 요약 응답
