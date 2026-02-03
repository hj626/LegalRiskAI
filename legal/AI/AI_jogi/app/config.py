# AI_jogi/app/config.py
"""
환경 설정 파일
"""
import os
from dotenv import load_dotenv

load_dotenv()

# ========================
# 모델 경로 설정
# ========================
MODEL_PATH = os.getenv("MODEL_PATH", "")

# ========================
# API 키
# ========================
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")

# ========================
# 서버 설정
# ========================
HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "8002"))
ALLOWED_ORIGINS = os.getenv(
    "ALLOWED_ORIGINS",
    "http://localhost:8484,http://localhost:3000"
).split(",")
