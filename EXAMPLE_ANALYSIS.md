# 🎓 실전 분석 예제

이 문서는 실제로 bomb 바이너리를 분석하는 과정을 단계별로 보여줍니다.

## 📋 Phase 1 분석 예제

Phase 1은 일반적으로 가장 간단한 단계로, 문자열 비교를 수행합니다.

### Step 1: 문자열 힌트 찾기

```bash
strings bomb | grep -i "phase"
strings bomb | grep -E "^[a-zA-Z0-9 ]{10,50}$" | head -20
```

이 명령어는 bomb 바이너리에서 가능한 정답 문자열을 찾습니다.

### Step 2: Phase 1 함수 디스어셈블

```bash
objdump -d bomb | grep -A 30 "<phase_1>:"
```

**예상 출력 (예시):**
```asm
0000000000401234 <phase_1>:
  401234:	48 83 ec 08          	sub    $0x8,%rsp
  401238:	48 be 00 24 40 00 00 	movabs $0x402400,%rsi
  40123f:	00 00 00 
  401242:	e8 d9 04 00 00       	call   401720 <strings_not_equal>
  401247:	85 c0                	test   %eax,%eax
  401249:	75 05                	jne    401250 <phase_1+0x1c>
  40124b:	48 83 c4 08          	add    $0x8,%rsp
  40124f:	c3                   	ret    
  401250:	e8 b5 05 00 00       	call   40180a <explode_bomb>
```

**분석:**
1. `movabs $0x402400,%rsi` - 주소 0x402400을 rsi 레지스터에 로드
2. `call strings_not_equal` - 문자열 비교 함수 호출
3. `jne explode_bomb` - 같지 않으면 폭발

**핵심:** 0x402400 주소에 있는 문자열이 정답입니다!

### Step 3: GDB로 정답 확인

```bash
gdb bomb
```

**GDB 명령어:**
```gdb
(gdb) x/s 0x402400
0x402400: "Border relations with Canada have never been better."

(gdb) quit
```

### Step 4: 정답 테스트

```bash
echo "Border relations with Canada have never been better." | ./bomb
```

**성공 메시지:**
```
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
Phase 1 defused. How about the next one?
```

### Step 5: 정답 저장

```bash
echo "Border relations with Canada have never been better." > answers.txt
```

---

## 📊 Phase 2 분석 예제

Phase 2는 보통 숫자 시퀀스 또는 배열을 다룹니다.

### Step 1: Phase 2 디스어셈블

```bash
objdump -d bomb | grep -A 50 "<phase_2>:"
```

**예상 패턴:**
```asm
call   read_six_numbers    # 6개의 숫자를 읽음
cmp    $0x1,(%rsp)        # 첫 번째 숫자가 1인지 확인
...
lea    0x4(%rsp),%rbx     # 배열 탐색
...
```

### Step 2: GDB로 동적 분석

```bash
gdb bomb
(gdb) break phase_2
(gdb) run answers.txt
Border relations with Canada have never been better.
(gdb) disassemble
```

**테스트할 입력 패턴:**
- 등차수열: `1 2 3 4 5 6`
- 등비수열: `1 2 4 8 16 32`
- 피보나치: `1 1 2 3 5 8`
- 팩토리얼: `1 2 6 24 120 720`

### Step 3: 조건 확인

```gdb
(gdb) break phase_2
(gdb) run answers.txt
(gdb) ni                   # next instruction
(gdb) print $rax          # 레지스터 값 확인
(gdb) x/6wd $rsp          # 스택의 6개 정수 확인
```

어셈블리에서 비교 로직을 보고 올바른 시퀀스를 유추합니다.

---

## 🔍 일반적인 디버깅 워크플로우

### 1. 정적 분석 단계

```bash
# 문자열 추출
strings bomb > analysis/strings.txt

# 함수 디스어셈블
objdump -d bomb | grep -A 40 "<phase_X>:" > analysis/phase_X.asm

# 분석
vim analysis/phase_X.asm
```

### 2. 동적 분석 단계

```bash
gdb bomb
(gdb) break phase_X
(gdb) run answers.txt
(gdb) disassemble
(gdb) info registers
(gdb) x/10x $rsp
```

### 3. 가설 검증

```bash
# 테스트 입력 준비
cp answers.txt test_answers.txt
echo "테스트_정답" >> test_answers.txt

# 테스트 실행
./bomb test_answers.txt
```

### 4. 성공 시 저장

```bash
echo "확인된_정답" >> answers.txt
```

---

## 🎯 각 Phase 유형별 전략

### 문자열 비교 (Phase 1)
- `strings_not_equal` 함수 찾기
- 비교 대상 주소 확인
- GDB로 메모리 내용 확인

### 숫자 배열 (Phase 2)
- `read_six_numbers` 같은 함수 찾기
- 루프 로직 분석
- 수열 패턴 추측 (등차, 등비, 피보나치 등)

### Switch/조건문 (Phase 3)
- 점프 테이블 (`jmp *address`)
- 여러 조건 분기
- 특정 케이스 선택

### 재귀 함수 (Phase 4)
- 자기 자신을 호출하는 `call` 찾기
- 종료 조건 확인
- 재귀 깊이와 반환 값 분석

### 문자열 조작 (Phase 5)
- 문자 배열이나 테이블 참조
- 인덱싱 로직
- 변환 규칙 파악

### 복잡한 자료구조 (Phase 6)
- 연결 리스트, 트리 등
- 포인터 추적
- 정렬 또는 재배치 로직

---

## 💡 고급 분석 기법

### 1. 조건부 브레이크포인트

```gdb
(gdb) break phase_3 if $rdi == 7
```

특정 조건에서만 멈춥니다.

### 2. 메모리 워치포인트

```gdb
(gdb) watch *(int*)0x604200
```

특정 메모리가 변경될 때 멈춥니다.

### 3. 함수 반환 값 조작

```gdb
(gdb) break explode_bomb
(gdb) return 0
```

폭발을 방지하고 계속 진행할 수 있습니다.

### 4. 레지스터 값 변경

```gdb
(gdb) set $rax = 0
```

비교 결과를 강제로 변경합니다.

### 5. Radare2 비주얼 그래프

```bash
r2 bomb
[0x00000000]> aaa
[0x00000000]> s sym.phase_1
[0x00000000]> VV
```

함수의 제어 흐름을 시각적으로 볼 수 있습니다.

---

## 📝 팁 모음

### 시간 절약 팁

1. **answers.txt 사용**: 이미 푼 단계는 파일에 저장
2. **explode_bomb 브레이크포인트**: 틀려도 계속 진행 가능
3. **스크립트 활용**: 반복 작업 자동화

### 막힐 때

1. 다른 Phase를 먼저 풀어보기
2. 온라인에서 비슷한 예제 검색
3. 어셈블리 명령어 매뉴얼 참고
4. 동료와 아이디어 공유

### 주의할 점

1. **입력 형식**: 공백, 대소문자 정확히
2. **숫자 형식**: 10진수? 16진수?
3. **문자열 끝**: Null 문자 포함 여부
4. **숨겨진 조건**: 특정 순서나 조합

---

## 🏆 성공 체크리스트

- [ ] Phase 1 해제
- [ ] Phase 2 해제
- [ ] Phase 3 해제
- [ ] Phase 4 해제
- [ ] Phase 5 해제
- [ ] Phase 6 해제
- [ ] 숨겨진 Phase 찾기 (선택)
- [ ] 모든 정답 answers.txt에 저장

---

## 🎓 학습 목표

이 Lab을 통해 배우는 것:

1. **어셈블리 언어 읽기**
2. **함수 호출 규약 이해**
3. **디버거 사용법**
4. **메모리 구조 이해**
5. **리버스 엔지니어링 기법**
6. **문제 해결 능력**

행운을 빕니다! 🚀💣

