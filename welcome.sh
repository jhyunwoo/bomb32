#!/bin/bash

cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║              💣 Binary Bomb Lab 분석 환경 💣                  ║
║                                                               ║
║  완전 격리된 컨테이너에서 안전하게 분석할 수 있습니다!        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

📚 빠른 시작 가이드:

  1️⃣  자동 분석 실행:
      ./analyze.sh

  2️⃣  Bomb 실행:
      ./bomb

  3️⃣  GDB 디버깅:
      gdb bomb
      (gdb) break phase_1
      (gdb) run

  4️⃣  상세 가이드 보기:
      cat README_KR.md
      cat ANALYSIS_GUIDE.md

🔧 설치된 도구:
   - gdb, objdump, strings, radare2
   - vim, nano, xxd, file

💡 팁:
   - 정답을 찾으면 answers.txt에 저장하세요
   - ./bomb answers.txt 로 실행하면 이전 단계 스킵

🔒 보안:
   - 네트워크 완전 차단
   - 외부 접근 불가

행운을 빕니다! 🚀

EOF

