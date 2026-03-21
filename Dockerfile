# x64 리눅스 환경 제공
# ARM Mac에서도 x86-64 에뮬레이션으로 실행
FROM --platform=linux/amd64 ubuntu:22.04

# 환경 변수 설정 (apt 인터랙티브 프롬프트 방지)
ENV DEBIAN_FRONTEND=noninteractive

# 필요한 라이브러리 및 바이너리 분석 도구 설치
RUN apt-get update && \
    apt-get install -y \
    libc6 \
    gdb \
    binutils \
    file \
    vim \
    nano \
    xxd \
    wget \
    strace \
    ltrace \
    && rm -rf /var/lib/apt/lists/*

# 작업 디렉토리 생성
WORKDIR /bomb

# bomb 파일 및 분석 도구 복사
COPY bomb /bomb/bomb
COPY bomb.c /bomb/bomb.c
COPY README /bomb/README
COPY README_KR.md /bomb/README_KR.md
COPY ANALYSIS_GUIDE.md /bomb/ANALYSIS_GUIDE.md
COPY EXAMPLE_ANALYSIS.md /bomb/EXAMPLE_ANALYSIS.md
COPY analyze.sh /bomb/analyze.sh
COPY gdb_example.txt /bomb/gdb_example.txt
COPY welcome.sh /bomb/welcome.sh

# 실행 권한 부여
RUN chmod +x /bomb/bomb /bomb/analyze.sh /bomb/welcome.sh

# 보안을 위해 일반 사용자 생성 및 전환
RUN useradd -m -s /bin/bash bombuser && \
    chown -R bombuser:bombuser /bomb

# Welcome 메시지를 .bashrc에 추가
RUN echo '/bomb/welcome.sh' >> /home/bombuser/.bashrc

USER bombuser

# 기본 명령
CMD ["/bin/bash"]

