from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.schemas import CaseRequest, CaseResponse, CaseSummaryResponse, CaseFullTextResponse
from app.service import analyze_case, get_case_summary, get_case_full_text
from app.config import ALLOWED_ORIGINS

app = FastAPI(
    title="유사 판례 분석 API",
    description="Gemini API 기반 법률 사건 분석 서비스",
    version="2.0.0"
)

# -------------------------------
# CORS 허용
# -------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# 0️⃣ 루트 & 헬스체크
@app.get("/")
def root():
    return {
        "service": "유사 판례 분석 AI",
        "version": "2.0.0",
        "status": "running"
    }


@app.get("/health")
def health():
    return {"status": "healthy"}


# 1️⃣ /analyze - 사건 분석
@app.post("/analyze", response_model=CaseResponse)
def analyze(request: CaseRequest):
    """사건 분석 API"""
    return analyze_case(
        case_text=request.case_text,
        case_type=request.case_type
    )


# 1️⃣-2 /precedent/analyze - 프론트엔드 호환용
@app.post("/precedent/analyze", response_model=CaseResponse)
def precedent_analyze(request: CaseRequest):
    """사건 분석 API (프론트엔드 호환)"""
    return analyze_case(
        case_text=request.case_text,
        case_type=request.case_type
    )


# 2️⃣ /case/{case_id}/summary
@app.get("/case/{case_id}/summary", response_model=CaseSummaryResponse)
def case_summary(case_id: str):
    try:
        return get_case_summary(case_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


# 2️⃣-2 /precedent/case/{case_id}/summary - 프론트엔드 호환용
@app.get("/precedent/case/{case_id}/summary", response_model=CaseSummaryResponse)
def precedent_case_summary(case_id: str):
    try:
        return get_case_summary(case_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


# 3️⃣ /case/{case_id}/full
@app.get("/case/{case_id}/full", response_model=CaseFullTextResponse)
def case_full(case_id: str):
    try:
        return get_case_full_text(case_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


# 3️⃣-2 /precedent/case/{case_id}/full - 프론트엔드 호환용
@app.get("/precedent/case/{case_id}/full", response_model=CaseFullTextResponse)
def precedent_case_full(case_id: str):
    try:
        return get_case_full_text(case_id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


# 4️⃣ /risk-analyze - 프론트엔드 호환용 (ai-jogi 대체)
@app.post("/risk-analyze")
def risk_analyze(request: CaseRequest):
    """위험도 분석 (Gemini API)"""
    result = analyze_case(
        case_text=request.case_text,
        case_type=request.case_type
    )
    # ai-jogi 형식으로 변환
    return {
        "success": True,
        "win_rate": 50.0,
        "sentence": 0.0,
        "fine": 0.0,
        "risk": 50.0 if result.overall_risk_level == "중간" else (25.0 if result.overall_risk_level == "낮음" else 75.0),
        "feedback": result.summary,
        "case_type": result.case_type_label
    }

