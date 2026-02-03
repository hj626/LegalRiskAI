# app/schemas.py
from pydantic import BaseModel
from typing import List, Optional, Dict, Any


# -----------------------------
# 요청 모델
# -----------------------------
class CaseRequest(BaseModel):
    case_type: Optional[str] = None
    case_text: str


# -----------------------------
# /analyze 관련 모델
# -----------------------------
class SimilarCase(BaseModel):
    case_id: Optional[str]
    case_name: str
    court: str
    case_number: str
    decision_type: str
    decision_result: str
    similarity: float
    case_type_label: str
    xai_reason: str


class SearchResultTypes(BaseModel):
    """검색 결과 기반 유형 분포"""
    distribution: Dict[str, int]      # {"민사": 3, "일반행정": 2}
    percentages: Dict[str, float]     # {"민사": 0.6, "일반행정": 0.4}
    is_mixed: bool                    # 복수 유형 여부
    primary_type: str                 # 주요 유형
    significant_types: List[str]      # 유의미한 유형들
    note: str                         # 특별 메시지


class CaseResponse(BaseModel):
    overall_risk_level: str
    summary: str
    similar_cases: List[SimilarCase]
    
    # 자동 분류 정보
    inferred_case_type: str
    case_type_label: str
    case_type_confidence: float
    case_type_description: str
    
    # ✅ 추가: 검색 기반 유형 분포
    search_result_types: SearchResultTypes


# -----------------------------
# /case/{case_id}/summary 관련 모델
# -----------------------------
class CaseSummaryResponse(BaseModel):
    case_id: str
    summary: str


# -----------------------------
# /case/{case_id}/full 관련 모델
# -----------------------------
class CaseFullTextResponse(BaseModel):
    case_id: str
    case_name: str
    full_text: str
    summary: Optional[str] = ""