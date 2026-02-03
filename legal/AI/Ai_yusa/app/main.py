# app/main.py

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.schemas import CaseRequest, CaseResponse, CaseSummaryResponse, CaseFullTextResponse
from app.service import analyze_case, get_case_summary, get_case_full_text

# ✅ 환경변수 로드 추가
from dotenv import load_dotenv
load_dotenv()  # .env 파일에서 환경변수 로드

app = FastAPI(title="Legal AI Analysis API")

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8484"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 1️⃣ /analyze
@app.post("/analyze", response_model=CaseResponse)
def analyze(request: CaseRequest):
    return analyze_case(request)

# 2️⃣ /case/{case_id}/summary
@app.get("/case/{case_id}/summary", response_model=CaseSummaryResponse)
def case_summary(case_id: str):
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
    
@app.get("/health")
def health():
    return {"status": "ok"}
