# Ai_boon/app/main.py
"""
분쟁 유형 분류 FastAPI 서버

포트: 8001
엔드포인트:
- GET  /           : 루트 (서버 정보)
- GET  /health     : 헬스체크
- POST /classify   : 분쟁 유형 분류
- GET  /categories : 전체 카테고리 목록
"""
import os
import sys
import time
from contextlib import asynccontextmanager

# 현재 디렉토리를 Python 경로에 추가
BOON_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BOON_DIR not in sys.path:
    sys.path.insert(0, BOON_DIR)

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from app.config import HOST, PORT, ALLOWED_ORIGINS
from app.schemas import ClassifyRequest, ClassifyResponse, HealthResponse
from app.classifier import get_classifier


# =====================
# 앱 생명주기
# =====================
@asynccontextmanager
async def lifespan(app: FastAPI):
    """앱 시작/종료 시 실행"""
    print("\n" + "=" * 60)
    print("[START] 분쟁 유형 분류 AI 서버 (Ai_boon)")
    print("=" * 60)
    
    # 모델 사전 로드
    print("\n[INFO] Loading models...")
    classifier = get_classifier()
    
    if classifier._loaded:
        print("\n[OK] Server ready!")
        print(f"[INFO] Listening on http://{HOST}:{PORT}")
    else:
        print("\n[WARN] Some models failed to load")
    
    print("=" * 60 + "\n")
    
    yield
    
    print("\n[SHUTDOWN] Server stopped")


# =====================
# FastAPI 앱 생성
# =====================
app = FastAPI(
    title="분쟁 유형 분류 AI API",
    description="LightGBM + TF-IDF 기반 법적 분쟁 유형 자동 분류 서비스",
    version="1.0.0",
    lifespan=lifespan
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)


# =====================
# 헬스체크
# =====================
@app.get("/", tags=["Health"])
def root():
    """루트 엔드포인트"""
    return {
        "service": "분쟁 유형 분류 AI",
        "version": "1.0.0",
        "port": PORT
    }


@app.get("/health", response_model=HealthResponse, tags=["Health"])
def health_check():
    """헬스체크"""
    classifier = get_classifier()
    return HealthResponse(
        status="healthy" if classifier._loaded else "degraded",
        model_loaded=classifier.model is not None,
        vectorizer_loaded=classifier.vectorizer is not None
    )


# =====================
# 분류 API
# =====================
@app.post("/classify", response_model=ClassifyResponse, tags=["Classification"])
def classify_dispute(request: ClassifyRequest):
    """
    분쟁 유형 분류
    
    입력된 텍스트를 분석하여 분쟁 유형을 분류하고 관련 정보를 반환합니다.
    
    **반환 정보:**
    - 대분류: 민사/형사/행정
    - 세부분류: 상세 분류 (예: 민사 (손해배상))
    - 당사자: 분쟁 당사자 관계
    - 분쟁내용: 분쟁 요약
    - 법적성격: 법적 유형
    - 관련법조: 관련 법률 조항
    - 분류이유: AI 분류 근거
    """
    start = time.time()
    
    print("\n" + "-" * 40)
    print("[REQUEST] /classify")
    print(f"  Text length: {len(request.case_text)} chars")
    
    # 입력 검증
    if not request.case_text or not request.case_text.strip():
        raise HTTPException(status_code=400, detail="case_text is required")
    
    if len(request.case_text.strip()) < 10:
        raise HTTPException(status_code=400, detail="case_text too short (min 10 chars)")
    
    try:
        classifier = get_classifier()
        result = classifier.classify(request.case_text)
        
        elapsed = time.time() - start
        print(f"  Result: {result['대분류']} / {result['세부분류']}")
        print(f"  Elapsed: {elapsed:.3f}s")
        print("-" * 40 + "\n")
        
        return ClassifyResponse(
            success=True,
            대분류=result["대분류"],
            세부분류=result["세부분류"],
            당사자=result["당사자"],
            분쟁내용=result["분쟁내용"],
            법적성격=result["법적성격"],
            관련법조=result.get("관련법조"),
            분류이유=result.get("분류이유"),
            키워드=result.get("키워드"),
            confidence=result.get("confidence")
        )
        
    except Exception as e:
        print(f"  [ERROR] {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Classification failed: {str(e)}")


# =====================
# 카테고리 목록
# =====================
@app.get("/categories", tags=["Classification"])
def get_categories():
    """전체 분류 카테고리 목록"""
    classifier = get_classifier()
    categories = classifier.get_all_categories()
    
    return {
        "total": len(categories),
        "categories": categories
    }


# =====================
# 메인 실행
# =====================
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=HOST, port=PORT)
