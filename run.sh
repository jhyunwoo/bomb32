#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Bomb32 완전 격리 컨테이너 실행 ===${NC}\n"

# 도커 이미지 빌드
echo -e "${YELLOW}1. 도커 이미지 빌드 중...${NC}"
docker build --platform linux/amd64 -t bomb32:isolated .

if [ $? -ne 0 ]; then
    echo "도커 이미지 빌드 실패!"
    exit 1
fi

echo -e "\n${GREEN}✓ 도커 이미지 빌드 완료${NC}\n"

# 기존 컨테이너가 있다면 제거
echo -e "${YELLOW}2. 기존 컨테이너 정리 중...${NC}"
docker rm -f bomb32_isolated 2>/dev/null

echo -e "\n${GREEN}✓ 정리 완료${NC}\n"

# 완전 격리 상태로 컨테이너 실행
echo -e "${YELLOW}3. 완전 격리 컨테이너 실행 중...${NC}"
echo -e "${YELLOW}   - 네트워크: 완전 차단 (network_mode: none)${NC}"
echo -e "${YELLOW}   - 외부 인터넷: 접근 불가${NC}"
echo -e "${YELLOW}   - 내부 접근: 차단${NC}\n"

docker run -it --rm \
    --name bomb32_isolated \
    --platform linux/amd64 \
    --network none \
    bomb32:isolated

echo -e "\n${GREEN}컨테이너가 종료되었습니다.${NC}"

