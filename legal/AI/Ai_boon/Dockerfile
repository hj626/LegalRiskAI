# =================================================================
# BoonAI 통합 법률 AI FastAPI Dockerfile
# Python 3.10 기반
# =================================================================

FROM python:3.10-slim

# 작업 디렉토리 설정
WORKDIR /workspace

# 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드 복사
COPY app/ ./app/

# 모델/벡터스토어 디렉토리 (볼륨으로 마운트)
RUN mkdir -p /workspace/models /workspace/vector_store

# 포트 노출
EXPOSE 8000

# 서버 실행
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
