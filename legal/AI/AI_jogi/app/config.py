# AI_jogi/app/config.py

import os
from dotenv import load_dotenv

load_dotenv()

# ========================
# 모델 경로 설정
# ========================
MODEL_PATH = os.getenv("MODEL_PATH", "./lerning/saved_mode3")

# ========================
# API 키
# ========================
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

# ========================
# 서버 설정
# ========================
HOST = "0.0.0.0"
PORT = 8002

ALLOWED_ORIGINS = os.getenv(
    "ALLOWED_ORIGINS",
    # "http://localhost:8484,http://localhost:3000"
    "http://localhost:8484,http://localhost:3000,http://localhost:5173"
# 개발 서버 포트 : 3000, 프론트엔드 vite 5173
# 백엔드/도커 8484
).split(",")
