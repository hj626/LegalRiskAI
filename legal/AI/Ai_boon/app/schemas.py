# boonAI/app/schemas.py
# ====================================================================
# Pydantic 스키마 정의
# 요청/응답 데이터 모델
# ====================================================================

from pydantic import BaseModel
from typing import Dict, List, Optional

# ================================================================
# 분류 API 스키마
# ================================================================

class ClassifyRequest(BaseModel):
    """분류 요청 스키마"""
    text: str  # 분류할 텍스트
    
class ClassifyResponse(BaseModel):
    """분류 응답 스키마"""
    dispute_type: str  # 분류된 분쟁 유형
    confidence: float  # 예측 신뢰도 (0.0 ~ 1.0)
    probabilities: Dict[str, float]  # 각 유형별 확률
    description: Optional[str] = None  # 분쟁 유형 설명

# ================================================================
# 통합 분석 API 스키마 (05-2 기반)
# ================================================================

class SimilarCase(BaseModel):
    """유사 케이스 정보"""
    content: str  # 케이스 내용
    score: float  # 유사도 점수

class UnifiedAnalyzeRequest(BaseModel):
    """통합 분석 요청 스키마"""
    text: str  # 상담 텍스트
    top_k: int = 3  # 검색할 유사 케이스 수

class UnifiedAnalyzeResponse(BaseModel):
    """통합 분석 응답 스키마"""
    # 1. 분류 결과
    dispute_type: str
    confidence: float
    description: Optional[str] = None
    
    # 2. 유사 케이스 (RAG)
    similar_cases: List[SimilarCase]
    
    # 3. LLM 생성 답변
    answer: str
