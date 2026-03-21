# ✅ 도커 이미지 빌드 성공!

## 🔍 문제 분석 및 해결

### 발생했던 오류
```
E: Package 'radare2' has no installation candidate
```

### 원인
1. **플랫폼 불일치**: bomb 파일은 x86-64 바이너리인데, 사용자가 ARM Mac (Apple Silicon)을 사용
2. **패키지 부재**: Ubuntu 22.04 ARM64 저장소에 `radare2` 패키지가 없음

### 해결 방법

#### 1. 플랫폼 명시
Dockerfile에 `--platform=linux/amd64` 추가:
```dockerfile
FROM --platform=linux/amd64 ubuntu:22.04
```

#### 2. 패키지 선택 변경
- ❌ 제거: `radare2` (ARM 저장소에 없음)
- ✅ 추가: `strace`, `ltrace` (더 기본적이고 안정적인 도구)

#### 3. 환경 변수 설정
```dockerfile
ENV DEBIAN_FRONTEND=noninteractive
```

#### 4. docker-compose.yml 및 run.sh 업데이트
실행 시에도 플랫폼 명시:
```yaml
platform: linux/amd64
```

## 📦 빌드 결과

### 설치된 도구들
- ✅ **gdb** - GNU 디버거
- ✅ **objdump** - 디스어셈블러  
- ✅ **strings** - 문자열 추출
- ✅ **file** - 파일 정보
- ✅ **vim/nano** - 텍스트 에디터
- ✅ **strace** - 시스템 콜 추적
- ✅ **ltrace** - 라이브러리 콜 추적
- ✅ **xxd** - 16진수 덤프
- ✅ **wget** - 다운로드 도구
- ✅ **binutils** - 바이너리 유틸리티

### 이미지 정보
- **이름**: `bomb32:isolated`
- **플랫폼**: `linux/amd64` (x86-64 에뮬레이션)
- **베이스**: Ubuntu 22.04
- **크기**: 약 180MB

## 🚀 사용 방법

### 방법 1: 스크립트 실행 (추천)
```bash
./run.sh
```

### 방법 2: docker-compose 사용
```bash
docker-compose up
```

### 방법 3: 직접 실행
```bash
docker run -it --rm \
    --name bomb32_isolated \
    --platform linux/amd64 \
    --network none \
    --cap-drop=ALL \
    --security-opt=no-new-privileges:true \
    bomb32:isolated
```

## 🔒 보안 기능

- ✅ **완전 네트워크 격리**: `--network none`
- ✅ **플랫폼 에뮬레이션**: Apple Silicon에서도 x86-64 실행
- ✅ **모든 capability 제거**: `--cap-drop=ALL`
- ✅ **권한 상승 방지**: `--security-opt=no-new-privileges:true`

## 💡 참고사항

### Apple Silicon (M1/M2/M3) Mac 사용자
- Docker Desktop의 Rosetta 에뮬레이션을 사용하여 x86-64 컨테이너 실행
- 성능은 네이티브보다 약간 느릴 수 있지만 분석에는 충분
- 완벽하게 작동합니다!

### 주의사항
- 첫 실행 시 에뮬레이션 초기화로 약간 느릴 수 있음
- 모든 분석 도구는 정상 작동
- 네트워크가 완전히 차단되어 있어 안전

## 🎓 다음 단계

1. 컨테이너 실행: `./run.sh`
2. 자동 분석: `./analyze.sh`
3. 가이드 확인: `cat README_KR.md`
4. GDB 시작: `gdb bomb`

행운을 빕니다! 💣🔍

