# 🔍 Binary Bomb 분석 가이드

## 📚 목차
1. [분석 도구 소개](#분석-도구-소개)
2. [기본 분석 방법](#기본-분석-방법)
3. [단계별 분석 전략](#단계별-분석-전략)
4. [GDB 디버깅 가이드](#gdb-디버깅-가이드)
5. [유용한 팁](#유용한-팁)

---

## 분석 도구 소개

컨테이너에 설치된 도구들:

### 1. **strings** - 문자열 추출
바이너리 내의 문자열을 추출합니다.
```bash
strings bomb
strings bomb | grep -i "phase"
```

### 2. **objdump** - 디스어셈블러
바이너리를 어셈블리 코드로 변환합니다.
```bash
# 전체 디스어셈블
objdump -d bomb

# 특정 함수만 보기
objdump -d bomb | grep -A 50 "<phase_1>:"
```

### 3. **gdb** - 디버거
실시간으로 프로그램을 실행하며 분석합니다.
```bash
gdb bomb
```

### 4. **radare2** - 고급 리버스 엔지니어링 도구
강력한 디스어셈블러 및 디버거입니다.
```bash
r2 bomb
```

### 5. **file** - 파일 정보 확인
```bash
file bomb
```

### 6. **xxd** - 16진수 덤프
```bash
xxd bomb | less
```

---

## 기본 분석 방법

### Step 1: 초기 정보 수집

```bash
# 파일 타입 확인
file bomb

# 문자열 검색
strings bomb > strings.txt
cat strings.txt | less

# 함수 목록 확인
objdump -t bomb | grep phase

# 디스어셈블 결과 저장
objdump -d bomb > bomb_disasm.txt
```

### Step 2: 주요 함수 찾기

```bash
# phase 함수들 찾기
objdump -d bomb | grep "<phase_[0-9]>:"

# explode_bomb 함수 찾기 (틀렸을 때 호출되는 함수)
objdump -d bomb | grep -A 20 "<explode_bomb>:"
```

### Step 3: 문자열 단서 찾기

```bash
# 가능한 정답 문자열 찾기
strings bomb | grep -E "^[a-zA-Z0-9 ]{5,30}$"

# 숫자 패턴 찾기
strings bomb | grep -E "^[0-9 ]+$"
```

---

## 단계별 분석 전략

### Phase 1 분석 예시

```bash
# 1. phase_1 함수 디스어셈블
objdump -d bomb | grep -A 30 "<phase_1>:"

# 2. 문자열 비교 부분 찾기
# phase_1은 보통 단순 문자열 비교입니다.
# "cmp" 또는 "call" 명령어를 주목하세요.

# 3. 참조된 메모리 주소 확인
# 예: 0x402400 같은 주소가 보이면 해당 주소의 내용 확인
gdb bomb
(gdb) x/s 0x402400
```

### 일반적인 Phase 패턴

- **Phase 1**: 문자열 비교 (`strcmp`)
- **Phase 2**: 숫자 시퀀스 (배열, 루프)
- **Phase 3**: Switch 문 또는 조건문
- **Phase 4**: 재귀 함수
- **Phase 5**: 문자열 조작, 테이블 참조
- **Phase 6**: 연결 리스트, 복잡한 자료구조

---

## GDB 디버깅 가이드

### 기본 명령어

```bash
# GDB 시작
gdb bomb

# 브레이크포인트 설정
(gdb) break phase_1
(gdb) break explode_bomb

# 프로그램 실행
(gdb) run

# 입력 파일 사용
(gdb) run answers.txt

# 다음 명령어 실행
(gdb) next          # 한 줄 실행 (함수 건너뜀)
(gdb) step          # 한 줄 실행 (함수 내부 진입)
(gdb) continue      # 다음 브레이크포인트까지 실행

# 레지스터 확인
(gdb) info registers
(gdb) print $rax
(gdb) print $rdi

# 메모리 확인
(gdb) x/s 0x402400        # 문자열로 출력
(gdb) x/d 0x402400        # 10진수로 출력
(gdb) x/x 0x402400        # 16진수로 출력
(gdb) x/10x $rsp          # 스택 10개 워드 출력

# 디스어셈블
(gdb) disassemble phase_1
(gdb) disassemble

# 변수 값 확인
(gdb) print input
(gdb) print/x $rdi

# 종료
(gdb) quit
```

### 고급 GDB 기법

```bash
# 조건부 브레이크포인트
(gdb) break phase_2 if $rax == 6

# 메모리 워치포인트
(gdb) watch variable_name

# 함수 호출 인자 확인 (x86-64)
# 첫 6개 인자: rdi, rsi, rdx, rcx, r8, r9
(gdb) break phase_1
(gdb) run
(gdb) print (char*)$rdi    # 첫 번째 인자 (입력 문자열)

# 백트레이스
(gdb) backtrace

# 어셈블리 모드로 보기
(gdb) layout asm
(gdb) layout regs

# GDB 스크립트 작성
echo "break phase_1\nrun\nx/s $rdi" > gdb_commands.txt
gdb -x gdb_commands.txt bomb
```

---

## Radare2 사용법

```bash
# Radare2 시작
r2 bomb

# 분석 수행
[0x00000000]> aaa

# 함수 목록
[0x00000000]> afl

# phase_1으로 이동
[0x00000000]> s sym.phase_1

# 디스어셈블
[0x00000000]> pdf

# 문자열 검색
[0x00000000]> iz

# 시각적 모드
[0x00000000]> VV

# 종료
[0x00000000]> q
```

---

## 유용한 팁

### 1. 정답 파일 생성하기
```bash
# answers.txt 파일 생성
echo "첫번째_정답" > answers.txt
echo "두번째_정답" >> answers.txt
echo "세번째_정답" >> answers.txt

# 실행
./bomb answers.txt
```

### 2. objdump 결과 필터링
```bash
# phase_1 함수만 상세히 보기
objdump -d bomb | sed -n '/<phase_1>/,/^$/p'

# 모든 phase 함수 추출
for i in {1..6}; do
    echo "=== Phase $i ===" >> phases.txt
    objdump -d bomb | sed -n "/<phase_$i>/,/^$/p" >> phases.txt
done
```

### 3. 문자열 주소 매칭
```bash
# 문자열과 주소 함께 보기
objdump -s -j .rodata bomb

# 또는
readelf -p .rodata bomb
```

### 4. 안전한 테스트
```bash
# 틀려도 폭발하지 않도록 explode_bomb에 브레이크포인트
gdb bomb
(gdb) break explode_bomb
(gdb) run
# 만약 explode_bomb에 도달하면
(gdb) return  # 함수에서 빠져나옴
(gdb) continue  # 계속 진행
```

### 5. 어셈블리 읽기 팁

**함수 호출 규약 (x86-64)**
- 인자 전달: `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9` (순서대로)
- 반환 값: `rax`
- 스택 포인터: `rsp`
- 베이스 포인터: `rbp`

**주요 명령어**
- `mov`: 값 이동
- `cmp`: 비교
- `je/jne`: 같으면/다르면 점프
- `call`: 함수 호출
- `ret`: 함수 반환
- `lea`: 주소 계산
- `push/pop`: 스택 조작

### 6. 일반적인 분석 흐름

```bash
# 1단계: 정적 분석
strings bomb | tee strings.txt
objdump -d bomb | tee disasm.txt

# 2단계: 함수별 분석
vim disasm.txt
# phase_1 찾기 -> 문자열 주소 확인

# 3단계: 동적 분석
gdb bomb
(gdb) break phase_1
(gdb) run
(gdb) x/s $rdi

# 4단계: 정답 테스트
echo "추측한_정답" | ./bomb

# 5단계: 정답 저장
echo "확인된_정답" >> answers.txt
```

---

## 🎯 분석 워크플로우 요약

```
1. 문자열 추출 (strings) → 가능한 정답 힌트 찾기
2. 함수 목록 확인 (objdump -t) → 어떤 phase가 있는지 확인
3. 각 phase 디스어셈블 (objdump -d) → 로직 이해
4. GDB로 동적 분석 → 실제 비교값 확인
5. 정답 추측 및 테스트 → 검증
6. 정답 파일에 저장 → 다음 phase 진행
```

---

## 📖 참고 자료

- **x86-64 어셈블리**: https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf
- **GDB 치트시트**: https://darkdust.net/files/GDB%20Cheat%20Sheet.pdf
- **Radare2 튜토리얼**: https://book.rada.re/

---

## ⚠️ 주의사항

1. 이 분석은 **교육 목적**으로만 사용하세요.
2. bomb 프로그램은 네트워크 접근이 차단된 환경에서 실행하세요.
3. 실수로 폭발해도 실제 피해는 없습니다 (프로그램이 종료될 뿐).
4. 인내심을 가지고 차근차근 분석하세요!

Good luck! 💣🔍

