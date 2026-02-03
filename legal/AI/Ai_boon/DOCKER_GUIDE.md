아래는 분쟁 유형 분류 AI 서버를 Docker로 실행할 때 꼭 필요한 명령어 정리
이 순서대로 진행해보세요

- 도커 데스크톱 / wsl 리눅스 서버안에 필히 도커가 있어야 한다 -> 빌드 전에 켜야 함 안그럼 아래와 같은 에러를 발생시킴
- error during connect: this error may indicate that the docker daemon is not running: Get 

- 도커 데스크톱 켜도 되지만 귀찮다 이러면  파워쉘에서 해당 도커 데스크톱 경로로 실행하면 실행이 된다
- 아래는 내 현재 도커 데스크톱 설치된 경로이다
- # Docker Desktop 실행
`Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"`

-방법 2: Windows 서비스로 시작
관리자 권한 PowerShell에서:

powershell
# Docker 서비스 시작
Start-Service -Name "com.docker.service"
# 또는 net 명령어로
net start com.docker.service
방법 3: WSL2 기반 Docker 직접 시작
powershell
# WSL 내에서 Docker 데몬 시작 (WSL2 백엔드 사용 시)
wsl -d docker-desktop


WSL2에서 Docker 설치 & 실행하기 (Docker Desktop 없이)
1단계: WSL 터미널 열기
powershell
wsl
2단계: Docker 설치 (WSL Ubuntu 안에서)
bash
# 패키지 업데이트
sudo apt update
# Docker 설치
sudo apt install -y docker.io
# Docker 서비스 시작
sudo service docker start
# 현재 사용자에게 docker 권한 부여
sudo usermod -aG docker $USER
3단계: Docker 작동 확인
bash
sudo docker run hello-world
4단계: 프로젝트 폴더로 이동 후 실행
bash
# Windows 경로를 WSL에서 접근하는 방법
cd /mnt/c/바탕\ 화면/legal/legal/AI/Ai_boon
# Docker Compose 설치 (없는 경우)
sudo apt install -y docker-compose
# 실행
sudo docker-compose up --build


1. 폴더 이동
    `cd E:\teme_Project0202\LegalRiskAI\legal\AI\Ai_boon`
2. Docker 이미지 빌드 및 실행
    ```
      docker-compose up --build
      # 또는 백그라운드 실행
      docker-compose up -d --build
    ```
3. 컨테이너 상태 확인
    `docker ps`
4. 서버 헬스체크
    `curl http://localhost:8001/health`
5. 컨테이너 중지
    `docker-compose down`
7. 컨테이너 로그 확인
    `docker logs -f legal-ai-boonjang`
이렇게 정리하면 실행과 운영에 꼭 필요한 명령어만 빠르게 확인할 수 있습니다.