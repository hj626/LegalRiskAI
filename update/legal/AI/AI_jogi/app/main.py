# legal/AI/AI_jogi/app/main.py
"""
위험도 / 조기 위험 감지 FastAPI 서버
포트: 8002
"""
//프로젝트 원본

import traceback
import os
import sys
import re
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

# 경로 설정: llm/jem_api.py를 찾기 위함
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# AI_jogi폴더
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

# 2. lerning 폴더 등록 (모델있는 곳)
LERNING_DIR = os.path.join(BASE_DIR, "lerning")
if LERNING_DIR not in sys.path:
    sys.path.insert(0, LERNING_DIR)



from app.config import HOST, PORT, ALLOWED_ORIGINS, MODEL_PATH, GEMINI_API_KEY
from app.schemas import (
    # AnalyzeRequest, AnalyzeResponse, StoryRequest, HealthResponse
    StoryRequest, 
    AnalyzeRequest,
    AnalyzeResponse,
    LegalRiskResponse, 
    WinRateResponse, 
    HealthResponse
)


# # Gemini 클라이언트 초기화

# AI모델이 메모리에 정상적으로 올라갔는지 관리용 / 싱글톤 또는 플래그라고 부름
analyzer = None
MODEL_AVAILABLE = False



@asynccontextmanager
async def lifespan(app: FastAPI):
    # 서버 시작 시 모델 로딩
    #lifespan(eager loading): 사용되는 모델을 서버가 켜질때 불러와서 실행 준비함.
    # 레이지로딩은 해당기능이 실행될때 모델을 불러옴
    
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
        MODEL_AVAILABLE = False
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
            "win_rate": float(result.get('win_rate', 0.0)), #승소 가능성
            
            "sentence": f"{float(result.get('sentence', 0)):.1f}년", #예상형량
            "fine": int(round(float(result.get('fine', 0)))), #예상 벌금
            "risk": int(round(float(result.get('risk', 0)))), #법적 위험도
            
            "feedback": result.get('feedback', "분석 내용이 없습니다."), #제미나이 설명
            "case_type": result.get('case_type', "일반") #사건 종류
        }
    except Exception as e:
        # 터미널(서버창)에 아주 상세한 에러 로그 보이게하기
        error_details = traceback.format_exc()
        print("❌ 분석 중 에러 발생!")
        print(error_details)
        
        return {
            "success": False,
            "win_rate": 0.0,
            "sentence": "error",
            "fine": 0,
            "risk": 0,
            "feedback": f"Error: {str(e)}\n\nDetails:\n{error_details}", # 상세 로그 포함
            "case_type": "error"
        }
    # except Exception as e:
    #     return {
    #         "success": False,
    #         "win_rate": 0.0,
    #         "sentence": "에러 발생", "fine": 0, "risk": 0,
    #         "feedback": str(e), "case_type": "error"
    #     }
    

#사용자가 쓴 사연(reauest.stroy)를 받아서 승소율 및 피드백을 뽑아주는곳
@app.post("/analyze/win-rate", response_model=WinRateResponse)
async def analyze_win_rate(request: StoryRequest):
    
    try:
        result = analyzer.analyze(request.story) 
        
        return {
            "success": True,
            "win_rate": float(result.get('win_rate', 0.0)),  # 승소 가능성
            "feedback": result.get('feedback', "분석 내용이 없습니다."),  # 제미나이 설명
            "legal_list": result.get('legal_list', [])  # 관련 법률 목록
        }
    except Exception as e:
        error_details = traceback.format_exc()
        print("❌ 승소율 분석 중 에러 발생!")
        print(error_details)
        
        return {
            "success": False,
            "win_rate": 0.0,
            "feedback": f"분석 중 오류가 발생했습니다: {str(e)}",
            "legal_list": []
        }




#사용자가 쓴 사연(reauest.stroy)를 받아서 위험율, 형량/벌금들을 뽑아주는곳
@app.post("/analyze/legal-risk", response_model=LegalRiskResponse)
async def analyze_legal_risk(request: StoryRequest):
    
    try:
        result = analyzer.analyze(request.story)
        
        return {
            "success": True,
            "risk": int(round(float(result.get('risk', 0)))),  # 법적 위험도
            "sentence": f"{float(result.get('sentence', 0)):.1f}년",  # 예상형량
            "fine": int(round(float(result.get('fine', 0)))),  # 예상 벌금
            "case_type": result.get('case_type', "일반")  # 사건 종류
        }
    except Exception as e:
        # 터미널(서버창)에 아주 상세한 에러 로그 보이게하기       
        
        error_details = traceback.format_exc()
        print("❌ 법적 리스크 분석 중 에러 발생!")
        print(error_details)
        
        return {
            "success": False,
            "risk": 0,
            "sentence": "error",
            "fine": 0,
            "case_type": "error"
        }




# 헬스체크 : 서버가 준비되어있는지 체크하는거
@app.get("/health", response_model=HealthResponse)
async def health_check():
    return {"status": "healthy", "model_loaded": MODEL_AVAILABLE}


# 메인실행
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=HOST, port=PORT)
