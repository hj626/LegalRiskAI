# Legal AI 통합 시스템

법률 분쟁 분석을 위한 AI 서비스 모음입니다.

## 📦 서비스 구성

| 서비스 | 포트 | 기능 |
|--------|------|------|
| **ai-boon** | 8001 | 분쟁 유형 분류 (LightGBM + TF-IDF) |
| **ai-yusa** | 8000 | 유사 판례 검색 (FAISS + Gemini) |
| **ai-jogi** | 8002 | 위험도/조기 분석 (BERT + Gemini) |

---

## 🚀 시작하기

### 1단계: 사전 요구사항

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) 설치
- [Gemini API 키](https://aistudio.google.com/) 발급

### 2단계: 환경변수 설정

```powershell
# .env.example을 .env로 복사
cp .env.example .env

# .env 파일 열어서 자신의 API 키 입력
notepad .env
```

**필수 수정 항목:**
```
GEMINI_API_KEY=your-actual-api-key
```

### 3단계: 데이터 파일 배치

아래 파일들이 필요합니다 (팀 드라이브에서 다운로드):

| 파일 | 위치 | 용도 |
|------|------|------|
| `korean_precedents_embedded.parquet` | `Ai_yusa/notebooks/` | 임베딩된 판례 데이터 |
| `korean_precedents_clean.csv` | `Ai_yusa/notebooks/` | 판례 원본 데이터 |
| `case_index.faiss` | `Ai_yusa/notebooks/` | FAISS 벡터 인덱스 |
| `saved_mode3/` | `AI_jogi/lerning/` | 학습된 BERT 모델 |

> 📁 파일이 없는 경우: `notebooks/` 폴더의 Jupyter 노트북을 순서대로 실행하세요.

### 4단계: Docker 실행

```powershell
# AI 폴더로 이동
cd legal/AI

# 모든 서비스 빌드 및 실행
docker-compose up --build

# 백그라운드 실행 (선택)
docker-compose up -d --build
```

### 5단계: 동작 확인

| 서비스 | Health Check URL |
|--------|------------------|
| 분쟁 분류 | http://localhost:8001/health |
| 유사 판례 | http://localhost:8000/ |
| 위험도 분석 | http://localhost:8002/health |

---

## 📋 API 사용법

### 분쟁 유형 분류 (Ai_boon)

```bash
curl -X POST "http://localhost:8001/classify" \
  -H "Content-Type: application/json" \
  -d '{"case_text": "친구에게 빌려준 100만원을 돌려받지 못하고 있습니다."}'
```

### 유사 판례 검색 (Ai_yusa)

```bash
curl -X POST "http://localhost:8000/analyze" \
  -H "Content-Type: application/json" \
  -d '{"case_text": "임대차 계약 만료 후 보증금을 돌려받지 못했습니다."}'
```

### 위험도 분석 (AI_jogi)

```bash
curl -X POST "http://localhost:8002/analyze" \
  -H "Content-Type: application/json" \
  -d '{"case_text": "회사에서 부당해고를 당했습니다."}'
```

---

## 🔧 트러블슈팅

### 1. "Dockerfile not found" 오류
```powershell
# 해당 폴더에 Dockerfile이 있는지 확인
ls Ai_yusa/Dockerfile
ls AI_jogi/Dockerfile
```

### 2. "GEMINI_API_KEY not found"
- `.env` 파일이 있는지 확인
- API 키가 올바르게 입력되었는지 확인

### 3. 데이터 파일 오류
- `notebooks/` 폴더에 `.parquet`, `.csv`, `.faiss` 파일 존재 확인
- 없으면 노트북 실행하여 생성

### 4. 포트 충돌
```powershell
# 사용 중인 포트 확인
netstat -ano | findstr :8000
netstat -ano | findstr :8001
netstat -ano | findstr :8002
```

---

## 📁 폴더 구조

```
AI/
├── docker-compose.yml    # 통합 실행 설정
├── .env                  # 환경변수 (Git 제외)
├── .env.example          # 환경변수 예시
├── README.md             # 이 파일
│
├── Ai_boon/              # 분쟁 분류 서비스
│   ├── Dockerfile
│   ├── app/
│   └── saved_models/
│
├── Ai_yusa/              # 유사 판례 서비스
│   ├── Dockerfile
│   ├── app/
│   ├── llm/
│   └── notebooks/        # 데이터 파일 위치
│
└── AI_jogi/              # 위험도 분석 서비스
    ├── Dockerfile
    ├── app/
    ├── llm/
    └── lerning/          # 모델 파일 위치
```

---

## 👥 팀 협업 가이드

### Git에 올리지 말 것 ⚠️
- `.env` (API 키 포함)
- `*.parquet`, `*.faiss`, `*.csv` (대용량)
- `*.bin`, `*.pt` (모델 파일)
- `venv/`, `__pycache__/`

### 새 팀원 온보딩 체크리스트
- [ ] Docker Desktop 설치
- [ ] Gemini API 키 발급
- [ ] `.env.example` → `.env` 복사 후 키 입력
- [ ] 데이터 파일 다운로드 (팀 드라이브)
- [ ] `docker-compose up --build` 실행
- [ ] Health Check 확인
