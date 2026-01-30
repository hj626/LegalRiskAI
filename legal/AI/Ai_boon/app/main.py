# boonAI/app/main.py
# ====================================================================
# FastAPI 기반 통합 법률 AI API 서버
# - 분류 API (/classify)
# - 통합 분석 API (/analyze) - 분류 + RAG + LLM
# ====================================================================

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.schemas import (
    ClassifyRequest, 
    ClassifyResponse,
    UnifiedAnalyzeRequest,
    UnifiedAnalyzeResponse
)
from app.service import classify_dispute, unified_analyze

# FastAPI 애플리케이션 인스턴스 생성
app = FastAPI(
    title="통합 법률 AI API",
    description="분류 + RAG + Ollama LLM 기반 법률 상담 서비스"
)

# ===============================================================
# CORS 설정 - React 프론트엔드에서 접근 허용
# ===============================================================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8484", "http://localhost:3000", "http://localhost:8000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ===============================================================
# 헬스 체크 엔드포인트
# ===============================================================
@app.get("/health")
def health_check():
    """서버 상태 확인"""
    return {
        "status": "healthy", 
        "model": "klue-bert-base",
        "features": ["classify", "rag", "ollama-llm"]
    }

# ===============================================================
# /classify 엔드포인트 - 분류만
# ===============================================================
@app.post("/classify", response_model=ClassifyResponse)
def classify(request: ClassifyRequest):
    """
    분쟁 유형 분류 API
    
    Args:
        request: ClassifyRequest 객체 (text 필드 포함)
        
    Returns:
        ClassifyResponse: 분류 결과 (유형, 신뢰도, 전체 확률)
    """
    if not request.text or not request.text.strip():
        raise HTTPException(status_code=400, detail="텍스트가 비어있습니다.")
    
    return classify_dispute(request.text)

# ===============================================================
# /analyze 엔드포인트 - 통합 분석 (분류 + RAG + LLM)
# ===============================================================
@app.post("/analyze", response_model=UnifiedAnalyzeResponse)
def analyze(request: UnifiedAnalyzeRequest):
    """
    통합 분석 API (05-2 기반)
    
    1. 분류: KLUE-BERT로 분쟁 유형 분류
    2. 검색: FAISS로 유사 케이스 검색
    3. 생성: Ollama LLM으로 법률 조언 생성
    
    Args:
        request: UnifiedAnalyzeRequest (text, top_k)
        
    Returns:
        UnifiedAnalyzeResponse: 분류 결과 + 유사 케이스 + LLM 답변
    """
    if not request.text or not request.text.strip():
        raise HTTPException(status_code=400, detail="텍스트가 비어있습니다.")
    
    return unified_analyze(request.text, request.top_k)
