# AI_jogi/app/main.py
"""
위험도 / 조기 위험 감지 FastAPI 서버

포트: 8002
엔드포인트:
- GET  /           : 루트 (서버 정보)
- GET  /health     : 헬스체크
- POST /analyze    : 법적 위험도 분석
- POST /risk       : 위험도만 예측
- POST /early-warning : 조기 위험 감지
- POST /risk-analyze : 프론트엔드 호환

모델 없이도 Gemini API만으로 분석 가능
"""
import os
import sys
import re
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

# [경로 설정] llm 폴더와 app 폴더를 인식
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)


from app.config import HOST, PORT, ALLOWED_ORIGINS, MODEL_PATH, GEMINI_API_KEY
from app.schemas import AnalyzeRequest, AnalyzeResponse, StoryRequest, HealthResponse


# # Gemini 클라이언트 초기화
# import google.generativeai as genai
# genai.configure(api_key=GEMINI_API_KEY)
# gemini_model = genai.GenerativeModel('gemini-2.0-flash')

# AI모델이 메모리에 정상적으로 올라갔는지 관리용 / 싱글톤 또는 플래그라고 부름
_analyzer = None
MODEL_AVAILABLE = False


# def get_analyzer():
#     """LegalAnalyzer 싱글톤 반환 (모델이 있을 때만)"""
#     global _analyzer, MODEL_AVAILABLE
#     if _analyzer is None and not MODEL_AVAILABLE:
#         try:
#             from llm.jem_api import LegalAnalyzer
#             _analyzer = LegalAnalyzer(
#                 model_path=MODEL_PATH,
#                 gemini_api_key=GEMINI_API_KEY
#             )
#             MODEL_AVAILABLE = True
#             print("[OK] LegalAnalyzer (BERT) 로드 완료")
#         except Exception as e:
#             print(f"[INFO] BERT 모델 없음 - Gemini API 전용 모드: {e}")
#             MODEL_AVAILABLE = False
#             _analyzer = None
#     return _analyzer


# def analyze_with_gemini(case_text: str) -> dict:
#     """Gemini API만으로 분석 (모델 없어도 작동)"""
    
#     prompt = f"""당신은 법률 전문가입니다. 다음 사건을 분석해주세요.

# 사건 내용:
# {case_text}

# 다음 형식으로 분석해주세요:

# 1. **승소 가능성**: 0-100% 사이의 숫자 (예: 65)
# 2. **위험도**: 0-100 사이의 숫자 (높을수록 불리)
# 3. **예상 결과**: 승소/패소/합의 가능성
# 4. **핵심 조언**: 의뢰인에게 드리는 구체적인 법적 조언

# 간결하고 명확하게 답변해주세요."""

#     try:
#         response = gemini_model.generate_content(prompt)
#         text = response.text
        
#         # 숫자 추출 시도
#         win_rate = 50.0
#         risk = 50.0
        
#         win_match = re.search(r'승소[^0-9]*(\d+)', text)
#         if win_match:
#             win_rate = min(100, max(0, float(win_match.group(1))))
        
#         risk_match = re.search(r'위험[^0-9]*(\d+)', text)
#         if risk_match:
#             risk = min(100, max(0, float(risk_match.group(1))))
        
#         return {
#             "success": True,
#             "win_rate": win_rate,
#             "sentence": 0.0,
#             "fine": 0.0,
#             "risk": risk,
#             "feedback": text,
#             "case_type": "Gemini 분석"
#         }
#     except Exception as e:
#         error_msg = str(e)
        
#         # API 할당량 초과 시 폴백 응답
#         if "429" in error_msg or "quota" in error_msg.lower():
#             return {
#                 "success": True,
#                 "win_rate": 50.0,
#                 "sentence": 0.0,
#                 "fine": 0.0,
#                 "risk": 50.0,
#                 "feedback": "⚠️ API 할당량이 초과되었습니다.\n\n기본 분석: 입력하신 사건은 법적 검토가 필요합니다. 전문 변호사 상담을 권장합니다.\n\n잠시 후 다시 시도해주세요.",
#                 "case_type": "API 제한"
#             }
        
#         return {
#             "success": False,
#             "win_rate": 50.0,
#             "sentence": 0.0,
#             "fine": 0.0,
#             "risk": 50.0,
#             "feedback": "분석 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.",
#             "case_type": "오류"
#         }



@asynccontextmanager
async def lifespan(app: FastAPI):
    """앱 시작/종료 시 실행"""
    # print("\n" + "=" * 60)
    # print("[START] 위험도/조기 분석 AI 서버 (AI_jogi)")
    # print("=" * 60)
    
    global analyzer, MODEL_AVAILABLE
    try:
        # llm 폴더 안의 LegalAnalyzer 임포트
        from llm.jem_api import LegalAnalyzer
        analyzer = LegalAnalyzer(
            model_path=MODEL_PATH,
            gemini_api_key=GEMINI_API_KEY
        )
        MODEL_AVAILABLE = True
        print("✅ AI 모델 로딩 성공!")
    except Exception as e:
        print(f"❌ 모델 로딩 실패: {e}")
    yield
    
app = FastAPI(title="법률 AI 분석 서버", lifespan=lifespan)       

# CORS 설정 반영
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 핵심 API 로직 :endpoing 클라이언트 서버에 접근할수 있는 지점


 #사용자가 쓴 사연(reauest.stroy)를 받아서 모든아웃풋을 돌려주는곳
@app.post("/analyze", response_model=AnalyzeResponse)
async def analyze_case(request: StoryRequest):
    """기존 분석 로직"""
    try:
        result = analyzer.analyze(request.story)
        return { #결과데이터를 어떻게 붙여서 받을지 이름을 붙여주는 json 이름표
            "success": True, #분석 성공여부
            "win_rate": result.get('win_rate', 0.0), #승소 가능성
            "sentence": result.get('sentence', "정보 없음"), #예상형량
            "fine": result.get('fine', 0), #예상 벌금
            "risk": result.get('risk', 0),#법적 위험도
            "feedback": result.get('feedback', "분석 내용이 없습니다."), #제미나이 설명
            "case_type": result.get('case_type', "일반") #사건 종류
        }
    except Exception as e:
        return {
            "success": False,
            "win_rate": 0.0,
            "sentence": "에러 발생", "fine": 0, "risk": 0,
            "feedback": str(e), "case_type": "error"
        }

#사용자가 쓴 사연(reauest.stroy)를 받아서 승소율 및 피드백을 뽑아주는곳
@app.post("/analyze/win-rate")
async def analyze_win_rate(request: AnalyzeRequest):
    try:
        result = analyzer.analyze(request.case_text)
        return {
            "win_rate": result.get('win_rate'), #승소 가능성
            "win_rate_feedback": result.get('feedback'), #제미나이 설명
            "legal_list": result.get('legal_list', []) #관련 법률
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

#사용자가 쓴 사연(reauest.stroy)를 받아서 형량/벌금들을 뽑아주는곳
@app.post("/analyze/sentence")
async def analyze_sentence(request: AnalyzeRequest):
    try:
        result = analyzer.analyze(request.case_text)
        return {
            "predicted_sentence": result.get('sentence'), #형량
            "predicted_fine": result.get('fine'), #벌금
            "risk_analysis": result.get('risk') #위험도 분석
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# 헬스체크 : 서버가 준비되어있는지 체크하는거
@app.get("/health", response_model=HealthResponse)
async def health_check():
    return {"status": "healthy", "model_loaded": MODEL_AVAILABLE}


# 메인실행
if __name__ == "__main__":
    import uvicorn
    
    
    
    
#     uvicorn.run(app, host=HOST, port=PORT)        
    
#     # 모델 사전 로드 시도
#     analyzer = get_analyzer()
#     if analyzer:
#         print("[OK] BERT 모델 로드됨 - 고급 분석 가능")
#     else:
#         print("[OK] Gemini API 전용 모드 - 기본 분석 제공")
    
#     print(f"[INFO] Listening on http://{HOST}:{PORT}")
#     print("=" * 60 + "\n")
    
#     yield
    
#     print("\n[SHUTDOWN] Server stopped")


# # =====================
# # FastAPI 앱 생성
# # =====================
# app = FastAPI(
#     title="위험도/조기 분석 AI API",
#     description="Gemini 기반 법적 위험도 및 조기 위험 감지 서비스",
#     version="2.0.0",
#     lifespan=lifespan
# )

# # CORS 설정
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=ALLOWED_ORIGINS,
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"]
# )


# # =====================
# # 헬스체크
# # =====================
# @app.get("/", tags=["Health"])
# def root():
#     """루트 엔드포인트"""
#     return {
#         "service": "위험도/조기 분석 AI",
#         "version": "2.0.0",
#         "port": PORT,
#         "mode": "BERT+Gemini" if MODEL_AVAILABLE else "Gemini Only"
#     }


# @app.get("/health", response_model=HealthResponse, tags=["Health"])
# def health_check():
#     """헬스체크"""
#     return HealthResponse(
#         status="healthy",
#         model_loaded=MODEL_AVAILABLE
#     )


# # =====================
# # 분석 API
# # =====================
# @app.post("/analyze", response_model=AnalyzeResponse, tags=["Analysis"])
# def analyze(request: AnalyzeRequest):
#     """
#     법적 위험도 종합 분석
    
#     BERT 모델이 있으면 BERT+Gemini, 없으면 Gemini만 사용
#     """
#     if not request.case_text or not request.case_text.strip():
#         raise HTTPException(status_code=400, detail="case_text is required")
    
#     analyzer = get_analyzer()
    
#     if analyzer is not None:
#         # BERT 모델 사용
#         try:
#             result = analyzer.analyze(request.case_text)
#             return AnalyzeResponse(
#                 success=True,
#                 win_rate=result.get("win_rate", 50),
#                 sentence=result.get("sentence", 0),
#                 fine=result.get("fine", 0),
#                 risk=result.get("risk", 50),
#                 feedback=result.get("feedback", ""),
#                 case_type=result.get("case_type", "")
#             )
#         except Exception as e:
#             print(f"[WARN] BERT 분석 실패, Gemini로 대체: {e}")
    
#     # Gemini 전용 분석
#     result = analyze_with_gemini(request.case_text)
#     return AnalyzeResponse(**result)


# # 프론트엔드 호환 엔드포인트
# @app.post("/risk-analyze", response_model=AnalyzeResponse, tags=["Analysis"])
# def risk_analyze(request: AnalyzeRequest):
#     """프론트엔드 호환용 - /analyze와 동일"""
#     return analyze(request)


# @app.post("/risk", tags=["Analysis"])
# def risk_only(request: AnalyzeRequest):
#     """위험도만 예측 (빠른 응답)"""
#     if not request.case_text or not request.case_text.strip():
#         raise HTTPException(status_code=400, detail="case_text is required")
    
#     analyzer = get_analyzer()
    
#     if analyzer is not None:
#         try:
#             result = analyzer.predict_bert(request.case_text)
#             return {
#                 "risk": result.get("risk", 50.0),
#                 "win_rate": result.get("win_rate", 50.0)
#             }
#         except Exception:
#             pass
    
#     # Gemini로 간단 분석
#     result = analyze_with_gemini(request.case_text)
#     return {
#         "risk": result.get("risk", 50.0),
#         "win_rate": result.get("win_rate", 50.0)
#     }


# @app.post("/early-warning", tags=["Analysis"])
# def early_warning(request: AnalyzeRequest):
#     """조기 위험 감지"""
#     if not request.case_text or not request.case_text.strip():
#         raise HTTPException(status_code=400, detail="case_text is required")
    
#     # 위험도 계산
#     risk_result = risk_only(request)
#     risk = risk_result.get("risk", 50.0)
    
#     if risk >= 70:
#         warning_level = "high"
#         message = "⚠️ 높은 법적 위험이 감지되었습니다. 즉시 전문가 상담을 권장합니다."
#     elif risk >= 40:
#         warning_level = "medium"
#         message = "⚡ 중간 수준의 위험이 있습니다. 관련 증거를 확보해두세요."
#     else:
#         warning_level = "low"
#         message = "✅ 현재 법적 위험도는 낮은 편입니다."
    
#     return {
#         "warning_level": warning_level,
#         "risk": risk,
#         "win_rate": risk_result.get("win_rate", 50.0),
#         "message": message
#     }


# # =====================
# # 메인 실행
# # =====================
# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host=HOST, port=PORT)
