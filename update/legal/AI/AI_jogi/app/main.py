# legal/AI/AI_jogi/app/main.py
"""
위험도 / 조기 위험 감지 FastAPI 서버
포트: 8002
"""
import traceback
import os
import sys
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# 경로 설정 최적화
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

from app.config import HOST, PORT, ALLOWED_ORIGINS, MODEL_PATH, GEMINI_API_KEY
from app.schemas import StoryRequest, AnalyzeResponse, LegalRiskResponse, WinRateResponse, HealthResponse

analyzer = None
MODEL_AVAILABLE = False

@asynccontextmanager
async def lifespan(app: FastAPI):
    global analyzer, MODEL_AVAILABLE
    try:
        from llm.jem_api import LegalAnalyzer
        analyzer = LegalAnalyzer(model_path=MODEL_PATH, gemini_api_key=GEMINI_API_KEY)
        MODEL_AVAILABLE = True
        print("✅ AI 모델 로딩 성공!")
    except Exception as e:
        print(f"❌ 모델 로딩 실패: {e}")
        MODEL_AVAILABLE = False
    yield

app = FastAPI(title="법률 AI 분석 서버", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/analyze", response_model=AnalyzeResponse)
async def analyze_case(request: StoryRequest):
    try:
        result = analyzer.analyze(request.story)
        return {
            "success": True,
            "win_rate": float(result.get('win_rate', 0.0)),
            "sentence": f"{float(result.get('sentence', 0)):.1f}년",
            "fine": int(round(float(result.get('fine', 0)))),
            "risk": int(round(float(result.get('risk', 0)))),
            "feedback": result.get('feedback', "분석 내용이 없습니다."),
            "case_type": result.get('case_type', "일반")
        }
    except Exception as e:
        print(f"❌ 분석 에러: {e}")
        return {"success": False, "win_rate": 0.0, "feedback": str(e), "case_type": "error"}

@app.get("/health", response_model=HealthResponse)
async def health_check():
    return {"status": "healthy", "model_loaded": MODEL_AVAILABLE}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=HOST, port=PORT)
