# AI_jogi/app/schemas.py
"""
API 요청/응답 스키마
"""
from pydantic import BaseModel
from typing import Optional


class AnalyzeRequest(BaseModel):
    """분석 요청 스키마"""
    case_text: str

class StoryRequest(BaseModel):
    """분석 요청 스키마"""
    story: str



class AnalyzeResponse(BaseModel):
    """분석 응답 스키마"""
    success: bool = True
    win_rate: float  # 승소율 (0-100)
    sentence: str  # 예상 형량 (년)
    fine: int  # 예상 벌금 (원)
    risk: int  # 위험도 (0-100)
    feedback: str  # LLM 피드백
    case_type: str  # 소송 유형


class HealthResponse(BaseModel):
    """헬스체크 응답"""
    status: str
    model_loaded: bool
