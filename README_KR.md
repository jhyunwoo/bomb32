# 💣 Binary Bomb Lab - 분석 환경

## 📦 프로젝트 구조

```
bomb32/
├── bomb                    # 실행 파일 (64-bit ELF)
├── bomb.c                  # 소스 코드 (참고용)
├── README                  # 원본 README
├── Dockerfile              # 도커 이미지 설정
├── docker-compose.yml      # 도커 컴포즈 설정
├── run.sh                  # 컨테이너 실행 스크립트
├── analyze.sh              # 바이너리 자동 분석 스크립트
├── gdb_example.txt         # GDB 예제 명령어
├── ANALYSIS_GUIDE.md       # 상세 분석 가이드
└── README_KR.md            # 이 파일
```

## 🚀 빠른 시작

### 1. 도커 컨테이너 실행

```bash
./run.sh
```

### 2. 컨테이너 내부에서 분석 시작

```bash
# 자동 분석 실행
./analyze.sh

# 수동으로 bomb 실행
./bomb

# GDB로 디버깅
gdb bomb
```

## 🔧 설치된 분석 도구

컨테이너에는 다음 도구들이 설치되어 있습니다:

- **gdb**: GNU 디버거
- **objdump**: 디스어셈블러
- **strings**: 문자열 추출
- **radare2**: 고급 리버스 엔지니어링 도구
- **file**: 파일 타입 확인
- **xxd**: 16진수 덤프
- **vim/nano**: 텍스트 에디터

## 📖 분석 방법

### 방법 1: 자동 분석 스크립트 사용

```bash
./analyze.sh
```

이 스크립트는 자동으로:
- 파일 정보 추출
- 문자열 추출 및 힌트 검색
- 함수 목록 추출
- 전체 디스어셈블
- Phase별 분석 파일 생성

모든 결과는 `analysis/` 디렉토리에 저장됩니다.

### 방법 2: 수동 분석

#### 기본 정보 수집
```bash
# 파일 타입 확인
file bomb

# 문자열 추출
strings bomb | less

# 함수 목록
objdump -t bomb | grep phase
```

#### GDB 디버깅
```bash
# GDB 시작
gdb bomb

# 브레이크포인트 설정
(gdb) break phase_1

# 실행
(gdb) run

# 입력 예시
test string

# 디스어셈블
(gdb) disassemble

# 레지스터 확인
(gdb) info registers

# 메모리 확인
(gdb) x/s $rdi

# 종료
(gdb) quit
```

#### Radare2 사용
```bash
r2 bomb
[0x00000000]> aaa          # 분석
[0x00000000]> afl          # 함수 목록
[0x00000000]> s sym.phase_1  # phase_1로 이동
[0x00000000]> pdf          # 디스어셈블
[0x00000000]> VV           # 비주얼 모드
```

## 💡 팁과 힌트

### 정답 파일 사용하기

```bash
# answers.txt 생성
echo "phase 1 answer" > answers.txt
echo "phase 2 answer" >> answers.txt

# 파일로 실행
./bomb answers.txt
```

이렇게 하면 이미 푼 단계를 다시 입력할 필요가 없습니다.

### 안전하게 테스트하기

```bash
gdb bomb
(gdb) break explode_bomb
(gdb) run
# 틀린 답을 입력하면 explode_bomb에서 멈춤
(gdb) return  # 폭발 방지!
(gdb) continue
```

### Phase 분석 순서

1. **문자열 추출**: `strings bomb | grep -i hint`
2. **함수 디스어셈블**: `objdump -d bomb | grep -A 50 "<phase_1>:"`
3. **동적 분석**: `gdb bomb`에서 브레이크포인트 설정
4. **메모리 검사**: 레지스터와 메모리 값 확인
5. **정답 추측**: 논리적으로 유추
6. **검증**: 실제로 실행해서 확인

## 📚 상세 가이드

자세한 분석 방법은 `ANALYSIS_GUIDE.md`를 참고하세요:

```bash
cat ANALYSIS_GUIDE.md
# 또는
vim ANALYSIS_GUIDE.md
```

## 🔒 보안 정보

이 도커 컨테이너는 완전히 격리되어 있습니다:

- ✅ 네트워크 완전 차단 (`--network none`)
- ✅ 외부 인터넷 접근 불가
- ✅ 외부에서 컨테이너 접근 불가
- ✅ 모든 Linux capability 제거
- ✅ 권한 상승 방지

안전하게 분석할 수 있습니다!

## 🎯 목표

6개의 Phase를 모두 해제하세요:

1. Phase 1: 문자열 비교
2. Phase 2: 숫자 시퀀스
3. Phase 3: 조건문/Switch
4. Phase 4: 재귀 함수
5. Phase 5: 문자열 조작
6. Phase 6: 복잡한 자료구조

**+ 숨겨진 Phase도 있을 수 있습니다!**

## ⚠️ 주의사항

- 이 Lab은 **교육 목적**입니다
- 리버스 엔지니어링 기술을 배우는 것이 목표입니다
- 인내심을 가지고 차근차근 분석하세요
- 막히면 힌트를 찾아보세요!

## 🤝 도움말

막히면 다음을 시도해보세요:

1. `./analyze.sh` 실행
2. `analysis/strings.txt`에서 힌트 찾기
3. `analysis/phases_detailed.txt`에서 해당 Phase 어셈블리 분석
4. GDB로 실제 비교되는 값 확인
5. `ANALYSIS_GUIDE.md`의 예제 참고

행운을 빕니다! 💣🔍

