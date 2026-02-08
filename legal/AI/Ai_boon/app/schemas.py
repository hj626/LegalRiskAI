# Ai_boon/app/schemas.py
"""
분쟁 유형 분류 API 스키마
"""
from typing import Optional, List
from pydantic import BaseModel


class ClassifyRequest(BaseModel):
    """분류 요청"""
    case_text: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "case_text": "계약 체결 후 상대방이 이행을 거부하고 있습니다. 계약금 500만원을 지불했으나..."
            }
        }


class ClassifyResponse(BaseModel):
    """분류 응답 - 분쟁 템플릿 형식"""
    success: bool
    
    # 기본 분류 정보
    대분류: str                    # 민사/형사/행정
    세부분류: str                  # 민사 (손해배상) 등
    당사자: str                    # 피해자 vs 가해자
    분쟁내용: str                  # 손해배상 청구
    법적성격: str                  # 불법행위
    
    # 추가 정보
    분류이유: Optional[str] = None  # 분류 근거 설명
    키워드: Optional[List[str]] = None  # 관련 키워드


class HealthResponse(BaseModel):
    """헬스체크 응답"""
    status: str
    model_loaded: bool
    vectorizer_loaded: bool