# Ai_yusa Dockerfile
# 유사 판례 검색 AI 서버

FROM python:3.11-slim

WORKDIR /app

# 시스템 패키지 설치 (LLM / 벡터 대비)
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 복사 (Ai_boon과 동일 전략)
COPY . .

# 포트 노출
EXPOSE 8002

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8002/health')" || exit 1

# 실행
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8002"]
