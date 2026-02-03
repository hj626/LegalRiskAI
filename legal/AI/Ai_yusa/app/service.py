# app/service.py
"""
메인 서비스 로직
- Gemini API 전용 모드 (데이터 파일 없이 작동)
- 가상 유사 판례 생성
"""
import re
import json
from typing import Optional, List

# Gemini 클라이언트
import google.generativeai as genai
from app.schemas import CaseResponse, SimilarCase, CaseSummaryResponse, CaseFullTextResponse
from app.classifier import infer_case_type, get_case_type_label, get_case_type_description
from app.config import GEMINI_API_KEY

# Gemini 초기화
print("\n" + "=" * 80)
print("🚀 서비스 초기화 중...")
print("=" * 80)

genai.configure(api_key=GEMINI_API_KEY)
gemini_model = genai.GenerativeModel('gemini-2.0-flash')

print("✅ Gemini API 전용 모드 (gemini-2.0-flash)")
print("✅ 가상 유사 판례 생성 활성화")
print("=" * 80 + "\n")


def analyze_with_gemini(case_text: str) -> dict:
    """Gemini API로 종합 분석 + 가상 유사 판례 생성"""
    
    prompt = f"""당신은 한국 법률 전문가입니다. 다음 사건을 분석하고 유사 판례를 추천해주세요.

사건 내용:
{case_text}

다음 JSON 형식으로 정확히 응답해주세요 (다른 텍스트 없이 JSON만):
{{
    "risk_level": "낮음" 또는 "중간" 또는 "높음",
    "summary": "사건 요약 및 법적 조언 (3-5문장)",
    "similar_cases": [
        {{
            "case_name": "판례 제목 (예: 임대차보증금반환 사건)",
            "court": "법원명 (예: 대법원, 서울중앙지방법원)",
            "case_number": "사건번호 (예: 2023다12345)",
            "decision_result": "판결결과 (예: 원고승소, 기각, 합의)",
            "similarity": 0.85,
            "reason": "이 판례가 유사한 이유 (1-2문장)"
        }}
    ]
}}

유사 판례는 3-5개 생성해주세요. 실제 존재할 법한 현실적인 판례를 만들어주세요."""

    try:
        response = gemini_model.generate_content(prompt)
        text = response.text.strip()
        
        # JSON 추출
        json_match = re.search(r'\{[\s\S]*\}', text)
        if json_match:
            data = json.loads(json_match.group())
            return {
                "success": True,
                "risk_level": data.get("risk_level", "중간"),
                "summary": data.get("summary", "분석 결과를 생성했습니다."),
                "similar_cases": data.get("similar_cases", [])
            }
        else:
            return {
                "success": True,
                "risk_level": "중간",
                "summary": text[:500],
                "similar_cases": []
            }
    except Exception as e:
        error_msg = str(e)
        print(f"[ERROR] Gemini 분석 실패: {error_msg}")
        
        # API 할당량 초과 시 폴백 응답
        if "429" in error_msg or "quota" in error_msg.lower():
            return {
                "success": True,
                "risk_level": "중간",
                "summary": "⚠️ API 할당량이 초과되어 상세 분석을 제공할 수 없습니다.\n\n기본 분석: 입력하신 사건은 법적 검토가 필요한 사안입니다. 전문 변호사 상담을 권장합니다.",
                "similar_cases": [
                    {
                        "case_name": "유사 사례 분석 대기 중",
                        "court": "정보 없음",
                        "case_number": "API-LIMIT",
                        "decision_result": "분석 대기",
                        "similarity": 0.5,
                        "reason": "API 할당량 초과로 상세 분석이 제한되었습니다. 잠시 후 다시 시도해주세요."
                    }
                ]
            }
        
        return {
            "success": False,
            "risk_level": "중간",
            "summary": f"분석 중 오류 발생. 잠시 후 다시 시도해주세요.",
            "similar_cases": []
        }


def analyze_case(case_text: str, case_type: Optional[str] = None) -> CaseResponse:
    """사건 분석 메인 함수"""
    
    # 1. 사건 유형 추론
    inferred_type = case_type if case_type else infer_case_type(case_text)
    type_label = get_case_type_label(inferred_type)
    type_description = get_case_type_description(inferred_type)
    
    # 2. Gemini로 분석 + 가상 판례 생성
    gemini_result = analyze_with_gemini(case_text)
    
    # 3. 유사 판례 변환
    similar_cases = []
    for i, case in enumerate(gemini_result.get("similar_cases", [])):
        try:
            similar_cases.append(SimilarCase(
                case_id=f"AI-{i+1}",
                case_name=case.get("case_name", f"유사 사례 {i+1}"),
                court=case.get("court", "가상 법원"),
                case_number=case.get("case_number", f"2024가상{i+1}"),
                decision_type="판결",
                decision_result=case.get("decision_result", "판단불명"),
                similarity=float(case.get("similarity", 0.7)),
                case_type_label=type_label,
                xai_reason=case.get("reason", "AI가 생성한 가상 유사 사례입니다.")
            ))
        except Exception as e:
            print(f"[WARN] 판례 변환 실패: {e}")
    
    return CaseResponse(
        overall_risk_level=gemini_result.get("risk_level", "중간"),
        summary=gemini_result.get("summary", "분석 결과"),
        similar_cases=similar_cases,
        inferred_case_type=inferred_type,
        case_type_label=type_label,
        case_type_confidence=0.8,
        case_type_description=type_description
    )


def get_case_summary(case_id: str) -> CaseSummaryResponse:
    """판례 요약 조회 (가상)"""
    return CaseSummaryResponse(
        case_id=case_id,
        summary="AI가 생성한 가상 판례입니다. 실제 판례 데이터가 없어 상세 요약을 제공할 수 없습니다."
    )


def get_case_full_text(case_id: str) -> CaseFullTextResponse:
    """판례 전문 조회 (가상)"""
    return CaseFullTextResponse(
        case_id=case_id,
        case_name="AI 생성 가상 판례",
        full_text="이 판례는 AI가 분석을 위해 생성한 가상의 유사 사례입니다.\n\n실제 판례 데이터베이스가 연결되면 실제 판례 전문을 확인할 수 있습니다.",
        summary="가상 판례 - 실제 데이터 없음"
    )