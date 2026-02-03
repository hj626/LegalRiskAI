# Ai_boon/app/classifier.py
"""
분쟁 유형 분류기
- LightGBM + TF-IDF 기반 분류 (기본)
- Ollama LLM 기반 분류 (옵션)
"""
import pickle
import json
import re
import os
import requests
from pathlib import Path
from typing import Tuple, Dict, Optional, Any

import numpy as np

from app.config import (
    LIGHTGBM_MODEL_PATH,
    TFIDF_VECTORIZER_PATH,
    LABEL_ENCODER_PATH,
    LE_MAJOR_PATH,
    LE_CIVIL_PATH,
    LE_CRIMINAL_PATH,
    DISPUTE_TEMPLATES_PATH
)

# Ollama 설정
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3")
USE_OLLAMA = os.getenv("USE_OLLAMA", "false").lower() == "true"


class DisputeClassifier:
    """
    분쟁 유형 분류기
    
    LightGBM 모델을 사용하여 입력 텍스트의 분쟁 유형을 분류하고,
    해당 유형에 맞는 템플릿 정보를 반환합니다.
    Ollama LLM 사용 옵션도 지원합니다.
    """
    
    _instance: Optional['DisputeClassifier'] = None
    
    def __init__(self):
        self.model = None
        self.vectorizer = None
        self.label_encoder = None
        self.le_major = None
        self.le_civil = None
        self.le_criminal = None
        self.templates = None
        self._loaded = False
        self._use_ollama = USE_OLLAMA
    
    @classmethod
    def get_instance(cls) -> 'DisputeClassifier':
        """싱글톤 인스턴스 반환"""
        if cls._instance is None:
            cls._instance = cls()
            cls._instance.load_models()
        return cls._instance
    
    def load_models(self) -> bool:
        """모델 및 벡터라이저 로드"""
        if self._loaded:
            return True
        
        try:
            print("[INFO] Loading dispute classifier models...")
            
            # 분쟁 템플릿 먼저 로드 (항상 필요)
            if DISPUTE_TEMPLATES_PATH.exists():
                with open(DISPUTE_TEMPLATES_PATH, 'r', encoding='utf-8') as f:
                    self.templates = json.load(f)
                print(f"  [OK] Dispute templates loaded ({len(self.templates)} types)")
            
            # Ollama 사용 모드
            if self._use_ollama:
                print("[INFO] Using Ollama LLM mode")
                if self._check_ollama_connection():
                    self._loaded = True
                    print("[OK] Ollama connection verified!")
                    return True
                else:
                    print("[WARN] Ollama not available, falling back to ML model")
                    self._use_ollama = False
            
            # LightGBM 모델 로드
            if LIGHTGBM_MODEL_PATH.exists():
                with open(LIGHTGBM_MODEL_PATH, 'rb') as f:
                    self.model = pickle.load(f)
                print("  [OK] LightGBM model loaded")
            else:
                print(f"  [X] Model not found: {LIGHTGBM_MODEL_PATH}")
                return False
            
            # TF-IDF 벡터라이저 로드
            if TFIDF_VECTORIZER_PATH.exists():
                with open(TFIDF_VECTORIZER_PATH, 'rb') as f:
                    self.vectorizer = pickle.load(f)
                print("  [OK] TF-IDF vectorizer loaded")
            else:
                print(f"  [X] Vectorizer not found: {TFIDF_VECTORIZER_PATH}")
                return False
            
            # 라벨 인코더 로드
            if LABEL_ENCODER_PATH.exists():
                with open(LABEL_ENCODER_PATH, 'rb') as f:
                    self.label_encoder = pickle.load(f)
                print("  [OK] Label encoder loaded")
            
            # 대분류 라벨 인코더
            if LE_MAJOR_PATH.exists():
                with open(LE_MAJOR_PATH, 'rb') as f:
                    self.le_major = pickle.load(f)
                print("  [OK] Major label encoder loaded")
            
            # 민사 라벨 인코더
            if LE_CIVIL_PATH.exists():
                with open(LE_CIVIL_PATH, 'rb') as f:
                    self.le_civil = pickle.load(f)
                print("  [OK] Civil label encoder loaded")
            
            # 형사 라벨 인코더
            if LE_CRIMINAL_PATH.exists():
                with open(LE_CRIMINAL_PATH, 'rb') as f:
                    self.le_criminal = pickle.load(f)
                print("  [OK] Criminal label encoder loaded")
            
            self._loaded = True
            print("[OK] All models loaded successfully!")
            return True
            
        except Exception as e:
            print(f"[ERROR] Failed to load models: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    def _check_ollama_connection(self) -> bool:
        """Ollama 서버 연결 확인"""
        try:
            response = requests.get(f"{OLLAMA_URL}/api/tags", timeout=5)
            return response.status_code == 200
        except Exception:
            return False
    
    def _classify_with_ollama(self, text: str) -> Dict[str, Any]:
        """Ollama LLM을 사용한 분류"""
        prompt = f"""다음 법적 분쟁 내용을 분석하여 JSON 형식으로 분류해주세요.

분쟁 내용:
{text}

다음 형식으로만 응답하세요 (JSON만, 다른 텍스트 없이):
{{
    "대분류": "민사" 또는 "형사" 또는 "행정",
    "세부분류": "구체적인 분류 (예: 민사 (손해배상), 형사 (사기))",
    "당사자": "분쟁 당사자 관계",
    "분쟁내용": "분쟁 요약 (10자 이내)",
    "법적성격": "법적 유형",
    "관련법조": "관련 법률 조항",
    "분류이유": "왜 이렇게 분류했는지 간단한 설명"
}}"""
        
        try:
            response = requests.post(
                f"{OLLAMA_URL}/api/generate",
                json={
                    "model": OLLAMA_MODEL,
                    "prompt": prompt,
                    "stream": False,
                    "format": "json"
                },
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                llm_response = result.get("response", "{}")
                
                # JSON 파싱
                try:
                    parsed = json.loads(llm_response)
                    parsed["confidence"] = 0.85
                    parsed["키워드"] = []
                    return parsed
                except json.JSONDecodeError:
                    print(f"  [WARN] Failed to parse LLM response: {llm_response[:100]}")
            
        except Exception as e:
            print(f"  [ERROR] Ollama request failed: {e}")
        
        # 실패 시 기본값 반환
        return self._get_template_info("민사_기타")
    
    def preprocess_text(self, text: str) -> str:
        """텍스트 전처리"""
        # 소문자 변환
        text = text.lower()
        # 특수문자 제거 (한글, 숫자, 공백 유지)
        text = re.sub(r'[^\w\s가-힣]', ' ', text)
        # 연속 공백 제거
        text = re.sub(r'\s+', ' ', text).strip()
        return text
    
    def classify(self, text: str) -> Dict[str, Any]:
        """
        텍스트 분류 수행 및 템플릿 정보 반환
        
        Args:
            text: 분류할 텍스트
            
        Returns:
            분쟁 템플릿 형식의 딕셔너리
        """
        if not self._loaded:
            self.load_models()
        
        # Ollama 모드
        if self._use_ollama:
            print("  Using Ollama LLM for classification")
            return self._classify_with_ollama(text)
        
        # ML 모델 모드
        if self.model is None or self.vectorizer is None:
            raise RuntimeError("Model or vectorizer not loaded")
        
        # 🔍 디버깅 로그 추가
        print(f"\n🔍 [DEBUG] 입력 텍스트 (원본): {text[:100]}...")
        
        # 전처리
        processed_text = self.preprocess_text(text)
        print(f"🔍 [DEBUG] 전처리 후 텍스트: {processed_text[:100]}...")
        
        # TF-IDF 변환
        text_vector = self.vectorizer.transform([processed_text])
        print(f"🔍 [DEBUG] TF-IDF 벡터 shape: {text_vector.shape}")
        print(f"🔍 [DEBUG] TF-IDF 벡터 non-zero elements: {text_vector.nnz}")
        
        # 예측
        prediction = self.model.predict(text_vector)[0]
        print(f"🔍 [DEBUG] 모델 예측 결과 (raw): {prediction} (type: {type(prediction)})")
        
        # 확률 계산 (LightGBM은 predict_proba 지원)
        confidence = 0.8  # 기본값
        try:
            probabilities = self.model.predict_proba(text_vector)[0]
            confidence = float(np.max(probabilities))
            print(f"🔍 [DEBUG] 예측 확률 분포: {probabilities}")
            print(f"🔍 [DEBUG] 최대 확률 (confidence): {confidence:.4f}")
        except AttributeError:
            print(f"🔍 [DEBUG] predict_proba not available")
            pass
        
        # 라벨 디코딩
        if self.label_encoder is not None:
            try:
                print(f"🔍 [DEBUG] Label Encoder classes: {self.label_encoder.classes_}")
                category_key = self.label_encoder.inverse_transform([prediction])[0]
                print(f"🔍 [DEBUG] 디코딩된 카테고리: {category_key}")
            except Exception as e:
                print(f"🔍 [DEBUG] 라벨 디코딩 실패: {e}")
                category_key = str(prediction)
        else:
            category_key = str(prediction)
        
        print(f"  ✅ Predicted category: {category_key}")
        
        # 템플릿에서 정보 가져오기 (원본 텍스트로 키워드 매칭)
        template = self._get_template_info(category_key, text)
        template["confidence"] = confidence
        
        print(f"🔍 [DEBUG] 최종 템플릿: {template}")
        
        return template
    
    def _get_template_info(self, category_key: str, original_text: str = "") -> Dict[str, Any]:
        """
        분류 키에 해당하는 템플릿 정보 반환
        
        Args:
            category_key: 분류 키 (예: "민사", "형사", 또는 "민사_손해배상")
            original_text: 원본 입력 텍스트 (키워드 기반 세부분류에 사용)
            
        Returns:
            템플릿 정보 딕셔너리
        """
        # 기본값
        default_template = {
            "대분류": "민사",
            "세부분류": "민사 (일반)",
            "당사자": "원고 vs 피고",
            "분쟁내용": "민사 분쟁",
            "법적성격": "민사",
            "관련법조": "민법 일반 조항",
            "분류이유": "일반적인 민사상 권리·의무 관계에 관한 분쟁입니다.",
            "키워드": []
        }
        
        if self.templates is None:
            print("  [WARN] Templates not loaded, using default")
            return default_template
        
        # 정확히 일치하는 템플릿 찾기 (예: "민사_손해배상")
        if category_key in self.templates:
            template = self.templates[category_key]
            return {
                "대분류": template.get("대분류", "기타"),
                "세부분류": template.get("분류", category_key),
                "당사자": template.get("당사자", "원고 vs 피고"),
                "분쟁내용": template.get("분쟁내용", "분쟁"),
                "법적성격": template.get("법적성격", "기타"),
                "관련법조": template.get("관련법조"),
                "분류이유": template.get("분류이유"),
                "키워드": template.get("키워드", [])
            }
        
        # 카테고리 키가 대분류만 있는 경우 (예: "민사", "형사")
        # 키워드 기반으로 세부분류 찾기
        print(f"  🔍 [DEBUG] 대분류 '{category_key}'에서 세부분류 탐색 중...")
        
        # 해당 대분류에 속하는 템플릿들 수집
        matching_templates = []
        for key, template in self.templates.items():
            if template.get("대분류") == category_key or key.startswith(category_key + "_"):
                matching_templates.append((key, template))
        
        # 키워드 매칭으로 가장 적합한 세부분류 찾기
        if original_text and matching_templates:
            best_match = None
            best_score = 0
            
            for key, template in matching_templates:
                keywords = template.get("키워드", [])
                score = sum(1 for kw in keywords if kw in original_text)
                print(f"    템플릿 '{key}': 키워드 매칭 점수 = {score}")
                
                if score > best_score:
                    best_score = score
                    best_match = (key, template)
            
            # 키워드 매칭 결과 반환
            if best_match and best_score > 0:
                key, template = best_match
                print(f"  ✅ [DEBUG] 키워드 매칭 성공: '{key}' (점수: {best_score})")
                return {
                    "대분류": template.get("대분류", category_key),
                    "세부분류": template.get("분류", key),
                    "당사자": template.get("당사자", "원고 vs 피고"),
                    "분쟁내용": template.get("분쟁내용", "분쟁"),
                    "법적성격": template.get("법적성격", "기타"),
                    "관련법조": template.get("관련법조"),
                    "분류이유": template.get("분류이유"),
                    "키워드": template.get("키워드", [])
                }
        
        # 부분 매칭 시도 (예: "민사" -> "민사_기타")
        fallback_key = f"{category_key}_기타"
        if fallback_key in self.templates:
            template = self.templates[fallback_key]
            print(f"  ⚠️ [DEBUG] 기본 템플릿 사용: '{fallback_key}'")
            return {
                "대분류": template.get("대분류", category_key),
                "세부분류": template.get("분류", fallback_key),
                "당사자": template.get("당사자", "원고 vs 피고"),
                "분쟁내용": template.get("분쟁내용", "분쟁"),
                "법적성격": template.get("법적성격", "기타"),
                "관련법조": template.get("관련법조"),
                "분류이유": template.get("분류이유"),
                "키워드": template.get("키워드", [])
            }
        
        # 대분류로 기본 템플릿 반환
        if "형사" in category_key:
            return {
                "대분류": "형사",
                "세부분류": "형사 (일반)",
                "당사자": "검사 vs 피고인",
                "분쟁내용": "형사 사건",
                "법적성격": "형사",
                "관련법조": "형법 일반 조항",
                "분류이유": "일반적인 형사 범죄에 관한 사건입니다.",
                "키워드": []
            }
        elif "행정" in category_key or "일반행정" in category_key:
            return {
                "대분류": "행정",
                "세부분류": "행정",
                "당사자": "국민 vs 행정청",
                "분쟁내용": "행정 처분",
                "법적성격": "행정소송",
                "관련법조": "행정소송법 제1조",
                "분류이유": "행정청의 처분에 대한 취소 또는 무효확인 소송입니다.",
                "키워드": []
            }
        elif "민사" in category_key:
            return {
                "대분류": "민사",
                "세부분류": "민사 (일반)",
                "당사자": "원고 vs 피고",
                "분쟁내용": "민사 분쟁",
                "법적성격": "민사",
                "관련법조": "민법 일반 조항",
                "분류이유": "일반적인 민사상 권리·의무 관계에 관한 분쟁입니다.",
                "키워드": []
            }
        elif "가사" in category_key:
            return {
                "대분류": "가사",
                "세부분류": "가사 (일반)",
                "당사자": "당사자 쌍방",
                "분쟁내용": "가사 분쟁",
                "법적성격": "가사",
                "관련법조": "가사소송법 일반 조항",
                "분류이유": "가정 내 법률관계에 관한 분쟁입니다.",
                "키워드": []
            }
        elif "세무" in category_key:
            return {
                "대분류": "세무",
                "세부분류": "세무 (일반)",
                "당사자": "납세자 vs 과세관청",
                "분쟁내용": "세무 분쟁",
                "법적성격": "세무",
                "관련법조": "국세기본법 일반 조항",
                "분류이유": "세금 부과 및 징수에 관한 분쟁입니다.",
                "키워드": []
            }
        elif "특허" in category_key:
            return {
                "대분류": "특허",
                "세부분류": "특허 (일반)",
                "당사자": "권리자 vs 침해자",
                "분쟁내용": "특허 분쟁",
                "법적성격": "지식재산권",
                "관련법조": "특허법 일반 조항",
                "분류이유": "지식재산권에 관한 분쟁입니다.",
                "키워드": []
            }
        
        return default_template
    
    def get_all_categories(self) -> list:
        """모든 분류 카테고리 반환"""
        if self.label_encoder is not None:
            return list(self.label_encoder.classes_)
        return []
    
    def set_use_ollama(self, use_ollama: bool):
        """Ollama 사용 여부 설정"""
        self._use_ollama = use_ollama
        if use_ollama and not self._check_ollama_connection():
            print("[WARN] Ollama not available")
            self._use_ollama = False


def get_classifier() -> DisputeClassifier:
    """분류기 인스턴스 반환"""
    return DisputeClassifier.get_instance()
