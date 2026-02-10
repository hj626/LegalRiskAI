# AI_jogi/app/schemas.py
"""
API 요청/응답 스키마
"""
from pydantic import BaseModel
from typing import Optional, List


class AnalyzeRequest(BaseModel):
    """분석 요청 스키마"""
    case_text: str

class StoryRequest(BaseModel):
    """분석 요청 스키마"""
    story: str



class AnalyzeResponse(BaseModel):
    """total 분석 응답 스키마"""
    success: bool = True
    win_rate: float  # 승소율 (0-100)
    sentence: str  # 예상 형량 (년)
    fine: int  # 예상 벌금 (원)
    risk: int  # 위험도 (0-100)
    feedback: str  # LLM 피드백
    case_type: str  # 소송 유형


class LegalRiskResponse(BaseModel):
    """법적 리스크 분석 응답 스키마"""
    success: bool = True
    risk: int  # 위험도 (0-100)
    sentence: str  # 예상 형량 (년)
    fine: int  # 예상 벌금 (원)
    case_type: str  # 사건 유형


class WinRateResponse(BaseModel):
    """승소율 분석 응답 스키마"""
    success: bool = True
    win_rate: float  # 승소율 (0-100)
    feedback: str  # LLM 피드백
    legal_list: List[str] = []  # 관련 법률 목록


class HealthResponse(BaseModel):
    """헬스체크 응답"""
    status: str
    model_loaded: bool
