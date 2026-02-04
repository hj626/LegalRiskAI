# api 연결 서비스용 / 스프링부트와 통신할 API 서버 호출하여 실행
# app.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import json
from jem_api import LegalAnalyzer
import uvicorn
import os
from dotenv import load_dotenv
from google import genai
from fastapi.middleware.cors import CORSMiddleware


# 1. .env 파일의 내용을 시스템 환경 변수로 불러옵니다.
load_dotenv()

# 2. 클라이언트 생성 (환경 변수에서 키를 읽어옴)
# os.getenv("GEMINI_API_KEY")는 .env 파일에 적힌 값을 가져옵니다.
client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

# fastAPI및 CORS설정
app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # 실무에서는 스프링 서버 주소만 허용하도록 수정
    allow_methods=["*"],
    allow_headers=["*"],
)

# 추가
class AnalyzeResponse(BaseModel):
    success: bool
    win_rate: float
    sentence: str
    fine: int
    risk: int
    feedback: str
    case_type: str



# 사연작성하는거 받는 부분 변수 설정
# 스프링부트 AiDto.AnalyzeRequest와 모양을 맞춥니다.
class AnalyzeRequest(BaseModel):
    case_text: str


# 승소율
# @app.post("/analyze/win-rate")
@app.post("/analyze/win-rate") # 주소 수정
async def analyze_win_rate(request: AnalyzeRequest):
    try:
        result = analyzer.analyze(request.case_text)
        return {
            "win_rate": result.get('win_rate'),
            "win_rate_feedback": result.get('feedback'),
            "legal_list": result.get('legal_list', [])
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# 형량/벌금/위험도
@app.post("/analyze/sentence")
async def analyze_sentence(request: AnalyzeRequest):
    try:
        result = analyzer.analyze(request.case_text)
        return {
            "predicted_sentence": result.get('sentence'),
            "predicted_fine": result.get('fine'),
            "risk_analysis": result.get('risk')
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))






# 1. 분석기 초기화 (모델 경로를 실제 경로에 맞게 수정)
try:
    analyzer = LegalAnalyzer(
        model_path="../lerning/saved_mode3", 
        gemini_api_key=os.getenv("GEMINI_API_KEY")
        # 환경 변수에서 가져온 진짜 키를 전달
    )
    print("AI 모델 로딩 성공!")
except Exception as e:
    print(f"모델 로딩 실패: {e}")
    # return 함수내에서만 사용가능


# 2. 요청 데이터 구조 정의
class StoryRequest(BaseModel):
    story: str



#여기가 스프링부트랑 연결하는 지점
# 3. 분석 API 엔드포인트
# @app.post("/analyze")
@app.post("/analyze", response_model=AnalyzeResponse) # <- response_model 연결
async def analyze_case(request: StoryRequest):
    try:
        # 사용자가 보낸 사연(story)을 분석기로 전달
        result = analyzer.analyze(request.story)
        
        return {
            "success": True,
            "win_rate": result.get('win_rate', 0.0),
            "sentence": result.get('sentence', "정보 없음"),
            "fine": result.get('fine', 0),
            "risk": result.get('risk', 0),
            "feedback": result.get('feedback', "분석 내용이 없습니다."),
            "case_type": result.get('case_type', "일반")
        }
    except Exception as e:
        # 에러 발생 시 처리
        return {
            "success": False,
            "win_rate": 0.0,
            "sentence": "에러 발생",
            "fine": 0,
            "risk": 0,
            "feedback": str(e),
            "case_type": "error"
        }
    #     return result  # 분석 결과(JSON)를 스프링부트에 반환
    # except Exception as e:
    #     raise HTTPException(status_code=500, detail=str(e))

print("\n💾 테스트 결과가 'test_input_result.json'에 저장되었습니다.") 




def main():
    print("⚖️  법률 AI 분석 시스템 테스트 모드")
   
    # 2. 실시간 사용자 입력 받기
    print("\n" + "="*50)
    print("분석하고 싶은 사연을 입력해 주세요.")
    print("(입력을 마치려면 엔터를 두 번(빈 줄 입력) 눌러주세요)")
    print("="*50)
    
    lines = []
    while True:
        line = input("> ") # 여기서 직접 타이핑하시면 됩니다
        if line == "":
            break
        lines.append(line)
    
    user_story = "\n".join(lines)

    if not user_story.strip():
        print("⚠️  입력된 내용이 없습니다. 프로그램을 종료합니다.")
        return





    # 3. 통합 분석 실행 (BERT + Gemini)
    print("\n🔍 입력을 확인했습니다. 분석을 시작합니다...")
    result = analyzer.analyze(user_story)  #이부분이 결과받는 부분이야.

    # 4. 결과 출력
    analyzer.print_result(result)

    # 5. 파일로 기록 (추후 확인용)
    with open('test_input_result.json', 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    print(result['win_rate'])     # 승소율
    print(result['sentence'])     # 형량
    print(result['fine'])         # 벌금
    print(result['risk'])         # 위험도
    print(result['feedback'])     # Gemini 피드백

if __name__ == "__main__":
     #이거는 터미널에서 내가 입력해서 테스트 할때
        # main()
        
        
    # 서버 실행: 8002번 포트에서 대기 / 이건 스프링부트하고 연결할때 쓰는거야
    # '서버'에서 띄우는거야
    # 도커 포트 8002사용함
    uvicorn.run(app, host="0.0.0.0", port=8002)
       