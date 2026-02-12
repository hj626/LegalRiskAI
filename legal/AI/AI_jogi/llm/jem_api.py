# jem_api.py
from google import genai
import torch
import pickle
from transformers import AutoTokenizer
import json
import os

from typing import Dict, Any
from .model import MultiTaskLegalBERT #같은 폴더안에 내가 만든 모델.py에서 모델 불러와





class LegalAnalyzer:
    """법률 사건 분석 클래스 (BERT + Gemini)"""
    
    def __init__(self, model_path: str, gemini_api_key: str):
        """
        Args:
            model_path: 학습된 BERT 모델 경로
            gemini_api_key: Gemini API 키
        """
        # BERT 모델 로드
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.tokenizer = AutoTokenizer.from_pretrained("klue/bert-base")
        
        #모델로드/딥러닝했던 모델 불러와 
        # 이건 자동화 실행
        # self.model = MultiTaskLegalBERT.from_pretrained( #from_pretrained허깅페이스에서 모델을 직관적으로가져오게 하는 거야
        #     model_path, num_labels=3).to(self.device)
        
        # 이건 직접 가서 내가 필요한 모델을 불러오겠다는것
        # self.model = MultiTaskLegalBERT(num_labels=3).to(self.device)
        self.model = MultiTaskLegalBERT(
        model_name="klue/bert-base",  # 👈 엔진 선택
        num_labels=3).to(self.device)
     
        
        model_file = os.path.join(model_path, "pytorch_model.bin")
        
        # 파일을 불러옵니다 (상자 가져오기)
        checkpoint = torch.load(model_file,
                                map_location=self.device,
                                weights_only=False #이건 안전한 파일이니까 보안 해제해도돼
                                )
        
        
        # 'model_state_dict'라는 알맹이가 있는지 확인하고 가중치만 추출
        if isinstance(checkpoint, dict) and 'model_state_dict' in checkpoint:
            state_dict = checkpoint['model_state_dict']
            print("✅ 딕셔너리 포장을 풀고 가중치를 추출했습니다.")
        else:
            state_dict = checkpoint
            print("✅ 일반 가중치 파일을 로드했습니다.")
            
        # 모델 뼈대에 추출한 가중치를 주입합니다.
        self.model.load_state_dict(state_dict)
        
        
        
        
        
        
        self.model.eval()
        
        # llm 불러와 / Gemini 설정
        # genai.configure(api_key=gemini_api_key)
        # self.gemini_model = genai.GenerativeModel('gemini-pro')
        self.client = genai.Client(api_key=gemini_api_key)
        self.model_name = "gemini-2.5-flash"
        
       
    def predict_bert(self, text: str) -> Dict[str, Any]:
        """BERT로 기본 수치 예측"""
        inputs = self.tokenizer(
            text, 
            return_tensors="pt", 
            truncation=True, 
            padding=True, 
            max_length=512
        )
        
         # token_type_ids 제거
        inputs = {k: v.to(self.device) for k, v in inputs.items()
                  if k != 'token_type_ids'}
        
        with torch.no_grad():
            outputs = self.model(**inputs)
        
        # # 소송 유형 예측
        # logits = outputs['logits']
        # case_type_idx = logits.argmax(-1).item()
        
        # 원본값
        raw_win_rate = outputs['win_rate'].item()
        print(f"🔍 원본값: {raw_win_rate}")
        print(f"🔍 10배값: {raw_win_rate * 10}")
        
        raw_sentence = outputs['sentence'].item()
        raw_fine = outputs['fine'].item()
        raw_risk = outputs['risk'].item()
        
          
        
        # 비정상 값을 현실적 범위로 변환
        # 승소율: 10배 후 0~100 제한
        win_rate = max(0, min(100, raw_win_rate * 10))
        print(f"🔍 최종값: {win_rate}")
        
        # 위험도: 10배 후 0~100 제한
        risk = max(0, min(100, raw_risk * 10))
        
        
        # 형량
        if raw_sentence < 0.5:  # 0.5년(6개월) 미만이면
            sentence = 0
        else:
            # sentence = max(0, min(30, raw_sentence * 10))
            sentence = max(0, min(30, raw_sentence))
    
    
        # 벌금
        if raw_fine < 10:  # 10 미만이면
            fine = 0
        else:
            # fine = max(0, min(100000000, raw_fine * 1000000))
            fine = max(0, min(100000000, raw_fine))
            
        return {
            'case_type': "법률 사건 분석",
            'win_rate': round(win_rate, 2),
            'sentence': round(sentence, 2),
            'fine': round(fine, 0),
            'risk': round(risk, 2)
    
        
        # return {
        #    'case_type': "법률 사건 분석", #self.class_names[case_type_idx],
        #     'win_rate': round(max(0, min(100, outputs['win_rate'].item())), 2),
        #     'sentence': round(max(0, outputs['sentence'].item()), 2),
        #     'fine': max(0, outputs['fine'].item()),
        #     'risk': max(0, min(100, outputs['risk'].item()))
        }
    
    def generate_feedback(self, story: str, bert_results: Dict) -> str:
        """Gemini로 상세 피드백 생성"""
        prompt = f"""
당신은 매우 유능한 법률전문가 입니다. 제공된 [AI 예측 수치]를 법률적 가이드라인으로 참고하여, 의뢰인의 [사연]에 대해 신뢰감 있고 객관적인 최종 분석을 제공하세요.

**작성 가이드라인**:
1. AI 수치는 참고용일 뿐입니다. 대한민국 형법과 실제 판례를 기준으로 현실적인 수치로 조정하세요.
2. AI 모델에 대한 평가(예: "오판이다", "부적절하다")나 본인 자랑(예: "매우 유능한")은 절대 하지 마세요.
3. AI 수치를 법률적 관점에서 재해석하여, 최종적으로 판단한 '승소 가능성'과 '대응 전략'만 정중하게 답변하세요.
4. 예상 형량이 없다면 '0', 벌금이 없다면 '0'으로 기재하세요.
5. 모든 답변은 완성된 문장으로 작성하세요.

【사연】
{story}

【AI 예측 결과】
- 소송 유형: {bert_results['case_type']}
- 승소율: {bert_results['win_rate']:.1f}%
- 예상 형량: {bert_results['sentence']:.1f}년
- 예상 벌금: {bert_results['fine']:,.0f}원
- 위험도: {bert_results['risk']:.1f}/100

**중요**: 위 AI 예측값을 검토하여, 형량/벌금/위험도를 고려했을 때 승소율이 적절한지 판단하세요.
- 사연을 작성한 사람은 당신의 의뢰인입니다. 사연을 분석한 후 AI예측값을 검토하여 형량과 벌금 그리고 승소율, 위험도가 적절하게 나왔는지 판단후, 적정치 않다면 당신의 의견을 기준으로 답변을 주세요.

다음 형식으로 답변해주세요:

- 최종승소율: [0-100 사이 숫자만]
- 최종형량: [숫자]
- 최종벌금: [숫자, 단위 제외]
- 최종위험도: [0-100 사이 숫자]

- 승소율 분석
[이 사건의 상황을 고려할 때 왜 이 정도의 승소 가능성이 있는지 200자 이내로 설명]

- 법률 검토 포인트
[의뢰인이 지금 당장 준비해야 할 핵심 법률 쟁점과 대응책을 200자 이내로 설명]
"""
        
        # response = self.gemini_model.generate_content(prompt)
        response = self.client.models.generate_content(
            model=self.model_name,
            contents=prompt
        )
        return response.text
    
    def analyze(self, story: str) -> Dict[str, Any]:
        """통합 분석 실행"""
        print("🔍 BERT 모델 분석 중...")
        bert_results = self.predict_bert(story)
        
        print("💬 Gemini 피드백 생성 중...")
        feedback = self.generate_feedback(story, bert_results)
        
        
        # 추가 2/11
        # Gemini 응답에서 최종 승소율 추출
        import re
        # match = re.search(r'최종승소율.*?(\d+(?:\.\d+)?)', feedback)
        
        # if match:
        #     final_win_rate = float(match.group(1))
        #     print(f"✅ Gemini가 승소율을 {bert_results['win_rate']}% → {final_win_rate}%로 조정")
        # else:
        #     final_win_rate = bert_results['win_rate']
        #     print(f"⚠️ Gemini 응답에서 숫자를 찾지 못함. (응답 서두: {feedback[:50]}...)")
        
        # # "최종승소율: XX" 부분은 피드백에서 제거
        # # feedback_cleaned = re.sub(r'최종승소율:\s*\d+(?:\.\d+)?\s*\n*', '', feedback).strip()
        # feedback_cleaned = re.sub(r'(\d+\.\s*)?(\*\*|__)?최종승소율(\*\*|__)?.*?\n', '', feedback, flags=re.IGNORECASE).strip()
        # 여기까지 추가했음.
        
        
        # 1. 승소율 추출 및 로그
        match_win = re.search(r'최종승소율.*?(\d+(?:\.\d+)?)', feedback)
        if match_win:
            final_win_rate = float(match_win.group(1))
            print(f"✅ 승소율 조정: {bert_results['win_rate']}% -> {final_win_rate}%")
        else:
            final_win_rate = bert_results['win_rate']
            print("⚠️ 승소율 추출 실패: BERT 기본값 유지")

        # 2. 형량 추출 및 로그
        match_sent = re.search(r'최종형량.*?(\d+(?:\.\d+)?)', feedback)
        final_sentence = float(match_sent.group(1)) if match_sent else bert_results['sentence']
        if match_sent: print(f"✅ 형량 조정: {bert_results['sentence']}년 -> {final_sentence}년")

        # 3. 벌금 추출 및 로그
        match_fine = re.search(r'최종벌금.*?(\d+(?:\.\d+)?)', feedback)
        final_fine = float(match_fine.group(1)) if match_fine else bert_results['fine']
        if match_fine: print(f"✅ 벌금 조정: {bert_results['fine']}원 -> {final_fine}원")

        # 4. 위험도 추출 및 로그
        match_risk = re.search(r'최종위험도.*?(\d+(?:\.\d+)?)', feedback)
        final_risk = float(match_risk.group(1)) if match_risk else bert_results['risk']
        if match_risk: print(f"✅ 위험도 조정: {bert_results['risk']} -> {final_risk}")
        
        
        # feedback_cleaned = re.sub(r'(\d+\.\s*)?(\*\*|__)?최종승소율(\*\*|__)?.*?\n', '', feedback, flags=re.IGNORECASE).strip()
        # 더 확실하게 지우는 버전
        feedback_cleaned = re.sub(r'-?\s*최종(승소율|형량|벌금|위험도).*?(\n|$)', '', feedback, flags=re.IGNORECASE).strip()
        
        
        
        
        
        
        return {
            **bert_results,
            'win_rate': round(final_win_rate, 2),  # Gemini가 결정한 최종 승소율
            # 'feedback': feedback,
            'sentence': round(final_sentence, 2),
            'fine': round(final_fine, 0),
            'risk': round(final_risk, 2),
            'feedback': feedback_cleaned,
            'original_story': story
        }
    
    def print_result(self, result: Dict[str, Any]):
        """결과를 보기 좋게 출력"""
        print("\n" + "="*70)
        print("⚖️  법률 사건 분석 결과")
        print("="*70)
        
        print(f"\n📋 소송 유형: {result['case_type']}")
        print(f"📊 예상 승소율: {result['win_rate']:.1f}%")
        
        if result['sentence'] > 0.1:
            print(f"⚖️  예상 형량: {result['sentence']:.1f}년")
        
        if result['fine'] > 10000:
            print(f"💰 예상 벌금: {result['fine']:,.0f}원")
        
        print(f"⚠️  위험도: {result['risk']:.1f}/100")
        
        print("\n" + "-"*70)
        print("💡 전문가 피드백:")
        print("-"*70)
        print(result['feedback'])
        print("="*70)