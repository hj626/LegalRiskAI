# Ai_yusa/app/config.py
"""
환경 설정 파일
- 모든 경로는 환경변수 또는 .env 파일에서 설정
"""
import os
from dotenv import load_dotenv

load_dotenv()

# ========================
# 데이터 경로 설정
# ========================
# 반드시 환경변수 또는 .env에서 설정 필요
PARQUET_PATH = os.getenv("PARQUET_PATH", "")
CSV_PATH = os.getenv("CSV_PATH", "")
FAISS_INDEX_PATH = os.getenv("FAISS_INDEX_PATH", "")

# ========================
# API 키
# ========================
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")

# ========================
# 서버 설정
# ========================
HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "8000"))
ALLOWED_ORIGINS = os.getenv(
    "ALLOWED_ORIGINS",
    "http://localhost:8484,http://localhost:3000"
).split(",")

# ========================
# 모델 설정
# ========================
SENTENCE_MODEL = os.getenv(
    "SENTENCE_MODEL",
    "snunlp/KR-SBERT-V40K-klueNLI-augSTS"
)
