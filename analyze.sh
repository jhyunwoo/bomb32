#!/bin/bash

# Bomb 바이너리 자동 분석 스크립트

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}=== Bomb 바이너리 자동 분석 ===${NC}\n"

# 분석 디렉토리 생성
mkdir -p analysis

# 1. 파일 정보
echo -e "${YELLOW}[1] 파일 정보${NC}"
file bomb | tee analysis/file_info.txt
echo ""

# 2. 문자열 추출
echo -e "${YELLOW}[2] 문자열 추출 중...${NC}"
strings bomb > analysis/strings.txt
echo "   → analysis/strings.txt 저장 ($(wc -l < analysis/strings.txt) 줄)"

# 문자열에서 힌트 찾기
echo -e "${YELLOW}[3] 가능한 힌트 검색...${NC}"
echo -e "${BLUE}   - Phase 관련 문자열:${NC}"
strings bomb | grep -i phase | head -20

echo -e "\n${BLUE}   - 가능한 정답 문자열 (5-30자):${NC}"
strings bomb | grep -E "^[a-zA-Z0-9 ]{5,30}$" | head -10

# 3. 함수 목록
echo -e "\n${YELLOW}[4] Phase 함수 목록${NC}"
objdump -t bomb | grep -E "phase_|explode|defused" | tee analysis/functions.txt

# 4. 전체 디스어셈블
echo -e "\n${YELLOW}[5] 전체 디스어셈블 중...${NC}"
objdump -d bomb > analysis/disassembly.txt
echo "   → analysis/disassembly.txt 저장"

# 5. 각 Phase별 디스어셈블
echo -e "\n${YELLOW}[6] Phase별 디스어셈블 추출 중...${NC}"
for i in {1..6}; do
    echo "   - Phase $i"
    echo "=== Phase $i ===" >> analysis/phases_detailed.txt
    objdump -d bomb | sed -n "/<phase_$i>:/,/^$/p" >> analysis/phases_detailed.txt
    echo "" >> analysis/phases_detailed.txt
done

# 6. .rodata 섹션 (읽기 전용 데이터, 문자열 상수 등)
echo -e "\n${YELLOW}[7] Read-Only 데이터 섹션 추출 중...${NC}"
objdump -s -j .rodata bomb > analysis/rodata.txt 2>/dev/null || echo "   (rodata 섹션 없음)"

# 7. 심볼 테이블
echo -e "\n${YELLOW}[8] 심볼 테이블 저장 중...${NC}"
objdump -t bomb > analysis/symbols.txt

# 8. 헤더 정보
echo -e "\n${YELLOW}[9] ELF 헤더 정보${NC}"
readelf -h bomb | tee analysis/elf_header.txt

# 9. 분석 요약
echo -e "\n${GREEN}=== 분석 완료 ===${NC}\n"
echo -e "${BLUE}생성된 파일:${NC}"
ls -lh analysis/
echo ""

echo -e "${YELLOW}다음 단계:${NC}"
echo "1. analysis/strings.txt - 문자열 검토"
echo "2. analysis/phases_detailed.txt - 각 Phase 어셈블리 분석"
echo "3. GDB로 동적 분석: gdb bomb"
echo ""

echo -e "${YELLOW}GDB 사용 예시:${NC}"
cat << 'EOF'
gdb bomb
(gdb) break phase_1
(gdb) run
(gdb) disassemble
(gdb) x/s $rdi
EOF

echo ""
echo -e "${GREEN}자세한 분석 방법은 ANALYSIS_GUIDE.md를 참고하세요!${NC}"

