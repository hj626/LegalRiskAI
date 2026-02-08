# app/llm/summarizer.py

from .gemini_client import call_gemini
from .prompt_templates import build_summary_prompt


def generate_case_summary(
    user_case: str,
    results_df,
    overall_risk_level: str,
) -> str:
    """
    유사 판례 분석 결과를 바탕으로
    사용자용 종합 설명 요약 생성
    """
    
    try:
        # 1. DataFrame 검증
        print(f"📊 results_df 크기: {len(results_df)}")
        print(f"📊 results_df 컬럼: {results_df.columns.tolist()}")
        
        top_cases = (
            results_df
            .head(5)
            .to_dict(orient="records")
        )
        
        print(f"✅ top_cases 추출 완료: {len(top_cases)}건")
        
        # 2. Prompt 생성
        prompt = build_summary_prompt(
            user_case=user_case,
            cases=top_cases,
            overall_risk_level=overall_risk_level
        )
        
        print(f"✅ Prompt 생성 완료: {len(prompt)} chars")
        
        # 3. Gemini 호출
        print("🔄 Gemini API 호출 중...")
        result = call_gemini(prompt)
        
        print(f"✅ 요약 생성 완료: {len(result)} chars")
        return result
        
    except Exception as e:
        # 상세한 오류 로깅
        print(f"❌ 요약 생성 오류 발생!")
        print(f"   오류 타입: {type(e).__name__}")
        print(f"   오류 메시지: {str(e)}")
        
        import traceback
        print(f"   전체 스택:")
        traceback.print_exc()
        
        # 오류 정보를 포함한 fallback 메시지
        return f"요약 생성 중 오류가 발생했습니다. ({type(e).__name__}: {str(e)})"