# boonAI/app/service.py
# ====================================================================
# 통합 법률 AI 서비스 (LangChain 없이 직접 구현)
# 분류(KLUE-BERT) + 검색(FAISS) + 생성(Ollama API)
# ====================================================================

import os
import pickle
import torch
import faiss
import httpx
import numpy as np
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from sentence_transformers import SentenceTransformer
from app.schemas import (
    ClassifyResponse, 
    UnifiedAnalyzeResponse, 
    SimilarCase
)

# ================================================================
# 환경 설정
# ================================================================

print("\n" + "=" * 80)
print("🚀 통합 법률 AI 서비스 초기화 중...")
print("=" * 80)

# 환경변수에서 경로 읽기 (로컬 및 Docker 호환)
# 프로젝트 루트 디렉토리 기준 경로 계산
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH = os.getenv("MODEL_PATH", os.path.join(BASE_DIR, "final"))
VECTOR_STORE_PATH = os.getenv("VECTOR_STORE_PATH", os.path.join(BASE_DIR, "vector_store"))
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "qwen2.5:7b")

# 디바이스 설정
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"✅ 실행 디바이스: {device}")

# ================================================================
# 1. 분류 모델 로드 (KLUE-BERT)
# ================================================================

print("📂 분류 모델 로드 중...")
tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)
classifier_model = AutoModelForSequenceClassification.from_pretrained(MODEL_PATH)
classifier_model.to(device)
classifier_model.eval()

# 라벨 인코더 로드
label_encoder_path = os.path.join(MODEL_PATH, "label_encoder.pkl")
with open(label_encoder_path, "rb") as f:
    label_encoder = pickle.load(f)

CLASSES = label_encoder.classes_.tolist()
print(f"✅ 분류 카테고리: {CLASSES}")

# 분쟁 유형별 설명
DISPUTE_DESCRIPTIONS = {
    "가사": "이혼, 양육권, 상속 등 가족 관련 분쟁",
    "민사": "계약, 손해배상, 부동산 등 일반 민사 분쟁",
    "세무": "세금 부과, 조세 불복 등 세무 관련 분쟁",
    "일반행정": "행정처분, 허가 취소 등 행정 관련 분쟁",
    "특허": "특허권, 상표권 등 지식재산권 분쟁",
    "형사": "폭행, 사기, 절도 등 형사 사건"
}

# ================================================================
# 2. RAG 벡터 스토어 로드 (FAISS 직접 사용)
# ================================================================

print("📂 벡터 스토어 로드 중...")

# 임베딩 모델 로드
embedding_model = SentenceTransformer("jhgan/ko-sbert-nli", device=device)

# FAISS 인덱스 로드
faiss_index_path = os.path.join(VECTOR_STORE_PATH, "index.faiss")
faiss_index = faiss.read_index(faiss_index_path)

# 문서 메타데이터 로드 (pkl 파일)
docs_path = os.path.join(VECTOR_STORE_PATH, "index.pkl")
with open(docs_path, "rb") as f:
    documents = pickle.load(f)

print(f"✅ FAISS 인덱스 로드 완료 ({faiss_index.ntotal}개 문서)")

# ================================================================
# 3. Ollama 클라이언트 설정
# ================================================================

print(f"📂 Ollama 설정: {OLLAMA_HOST} / {OLLAMA_MODEL}")
ollama_client = httpx.Client(base_url=OLLAMA_HOST, timeout=120.0)

print("=" * 80)
print("✅ 통합 법률 AI 서비스 초기화 완료!")
print("=" * 80 + "\n")

# ================================================================
# 분류 함수
# ================================================================

def classify_dispute(text: str) -> ClassifyResponse:
    """텍스트를 분쟁 유형으로 분류"""
    inputs = tokenizer(
        text,
        return_tensors="pt",
        truncation=True,
        max_length=512,
        padding=True
    )
    inputs = {k: v.to(device) for k, v in inputs.items()}
    
    with torch.no_grad():
        outputs = classifier_model(**inputs)
        logits = outputs.logits
    
    probs = torch.softmax(logits, dim=-1).squeeze().cpu().numpy()
    pred_idx = probs.argmax()
    pred_class = CLASSES[pred_idx]
    confidence = float(probs[pred_idx])
    
    probabilities = {cls: float(prob) for cls, prob in zip(CLASSES, probs)}
    
    print(f"✅ 분류 완료: {pred_class} (신뢰도: {confidence:.2%})")
    
    return ClassifyResponse(
        dispute_type=pred_class,
        confidence=confidence,
        probabilities=probabilities,
        description=DISPUTE_DESCRIPTIONS.get(pred_class, "")
    )

# ================================================================
# RAG 검색 함수 (FAISS 직접 사용)
# ================================================================

def search_similar_cases(query: str, top_k: int = 3) -> list:
    """FAISS로 유사 케이스 검색"""
    # 쿼리 임베딩
    query_embedding = embedding_model.encode([query], convert_to_numpy=True)
    
    # FAISS 검색
    distances, indices = faiss_index.search(query_embedding, top_k)
    
    similar_cases = []
    for i, (dist, idx) in enumerate(zip(distances[0], indices[0])):
        if idx >= 0 and idx < len(documents):
            doc = documents[idx]
            content = doc.page_content if hasattr(doc, 'page_content') else str(doc)
            similar_cases.append(SimilarCase(
                content=content[:500],  # 500자 제한
                score=float(1 / (1 + dist))  # 거리를 유사도로 변환
            ))
    
    print(f"✅ 유사 케이스 {len(similar_cases)}개 검색 완료")
    return similar_cases

# ================================================================
# LLM 답변 생성 함수 (Ollama API 직접 호출)
# ================================================================

def generate_response(
    query: str, 
    dispute_type: str, 
    similar_cases: list
) -> str:
    """Ollama API로 법률 상담 답변 생성"""
    # 유사 케이스 컨텍스트 구성
    context = "\n\n".join([
        f"[참고 사례 {i+1}]\n{case.content}" 
        for i, case in enumerate(similar_cases)
    ])
    
    # 프롬프트 구성
    prompt = f"""당신은 친절한 법률 상담 AI입니다.

사용자의 상담 내용을 분석한 결과, 이 사건은 '{dispute_type}' 유형으로 분류되었습니다.

아래 참고 사례들을 바탕으로 사용자에게 도움이 되는 법률 조언을 제공해주세요.

---
[사용자 상담 내용]
{query}

---
{context}

---
위 내용을 참고하여 한국어로 친절하고 상세하게 답변해주세요.
법적 조언은 참고용이며, 정확한 판단을 위해 전문 변호사 상담을 권장한다는 점을 언급해주세요.
"""
    
    print("🤖 LLM 답변 생성 중...")
    
    try:
        # Ollama API 호출
        response = ollama_client.post(
            "/api/generate",
            json={
                "model": OLLAMA_MODEL,
                "prompt": prompt,
                "stream": False
            }
        )
        response.raise_for_status()
        result = response.json()
        answer = result.get("response", "답변 생성에 실패했습니다.")
    except Exception as e:
        print(f"❌ Ollama 호출 실패: {e}")
        answer = f"LLM 서버 연결 실패. Ollama가 실행 중인지 확인해주세요. (오류: {str(e)})"
    
    print("✅ LLM 답변 생성 완료")
    return answer

# ================================================================
# 통합 분석 함수 (분류 + RAG + 생성)
# ================================================================

def unified_analyze(text: str, top_k: int = 3) -> UnifiedAnalyzeResponse:
    """통합 분석: 분류 → 검색 → 생성"""
    print("\n" + "-" * 60)
    print("🔍 통합 분석 시작...")
    print("-" * 60)
    
    # 1. 분류
    classify_result = classify_dispute(text)
    
    # 2. RAG 검색
    similar_cases = search_similar_cases(text, top_k)
    
    # 3. LLM 답변 생성
    answer = generate_response(
        query=text,
        dispute_type=classify_result.dispute_type,
        similar_cases=similar_cases
    )
    
    print("-" * 60)
    print("✅ 통합 분석 완료!")
    print("-" * 60 + "\n")
    
    return UnifiedAnalyzeResponse(
        dispute_type=classify_result.dispute_type,
        confidence=classify_result.confidence,
        description=classify_result.description,
        similar_cases=similar_cases,
        answer=answer
    )
