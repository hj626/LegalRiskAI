# Python 베이스 이미지
FROM python:3.10-slim

# 작업 폴더
WORKDIR /app

# requirements 먼저 복사 (캐시 최적화)
COPY requirements.txt .

# 패키지 설치
RUN pip install --no-cache-dir -r requirements.txt

# 프로젝트 전체 복사
COPY . .

# 포트 오픈
EXPOSE 8002

# 실행 명령
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8002"]
