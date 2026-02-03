# Ai_boon/app/config.py
"""
분쟁 유형 분류 서버 설정
"""
import os
from pathlib import Path

# 프로젝트 루트 경로
BASE_DIR = Path(__file__).resolve().parent.parent

# 모델 경로
MODEL_DIR = BASE_DIR / "saved_models"

# 모델 파일 경로
LIGHTGBM_MODEL_PATH = MODEL_DIR / "best_ml_model_LightGBM.pkl"
TFIDF_VECTORIZER_PATH = MODEL_DIR / "tfidf_vectorizer.pkl"
LABEL_ENCODER_PATH = MODEL_DIR / "label_encoder.pkl"
LABEL_ENCODER_EXPLAIN_PATH = MODEL_DIR / "label_encoder_explain.pkl"
LE_MAJOR_PATH = MODEL_DIR / "le_major.pkl"
LE_CIVIL_PATH = MODEL_DIR / "le_civil.pkl"
LE_CRIMINAL_PATH = MODEL_DIR / "le_criminal.pkl"
DISPUTE_TEMPLATES_PATH = MODEL_DIR / "dispute_templates_full.json"

# 서버 설정
HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", 8001))

# Ollama 설정
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3")
USE_OLLAMA = os.getenv("USE_OLLAMA", "false").lower() == "true"

# CORS 설정
ALLOWED_ORIGINS = [
    "http://localhost:5173",  # React dev
    "http://localhost:8484",  # Spring Boot
    "http://localhost:8000",  # total_ai

    "*"  # 개발용
]
