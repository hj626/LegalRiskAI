#!/bin/bash
# =================================================================
# Ollama 모델 다운로드 스크립트
# Docker Compose 실행 후 한 번 실행해주세요
# =================================================================

echo "🚀 Ollama 모델 다운로드 시작..."

# qwen2.5:7b 다운로드 (추천 - 한국어 지원 우수)
echo "📥 qwen2.5:7b 다운로드 중..."
docker exec boonai-ollama ollama pull qwen2.5:7b

echo "✅ 모델 다운로드 완료!"
echo ""
echo "사용 가능한 모델:"
docker exec boonai-ollama ollama list
