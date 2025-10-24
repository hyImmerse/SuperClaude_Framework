# SuperClaude Framework → Droid CLI 빠른 시작 가이드

> **5분 안에 설치하기** - 최소한의 단계로 SuperClaude Framework를 Droid CLI에서 즉시 사용

**버전**: 1.0
**대상**: 빠른 설치를 원하는 숙련된 사용자

---

## 📋 한눈에 보는 설치 과정

```
1. 시스템 요구사항 확인 (Bash 4.0+, Node.js 18+, Droid CLI)
   ↓
2. SuperClaude Framework 다운로드
   ↓
3. 자동 마이그레이션 스크립트 실행
   ↓
4. MCP 서버 설정 및 API 키 입력
   ↓
5. Droid 재시작 및 테스트
   ↓
✅ 완료! (총 5분)
```

---

## ⚡ 빠른 설치 (5분)

### 1단계: 사전 요구사항 확인 (30초)

```bash
# 버전 확인 (모두 통과해야 함)
bash --version    # 4.0 이상
node --version    # v18 이상
droid --version   # v0.22.2 이상
```

**모두 설치됨** → 다음 단계로
**하나라도 없음** → [상세 가이드](./Droid_Migration_Guide.md#시스템-요구사항) 참조

---

### 2단계: SuperClaude Framework 다운로드 (1분)

```bash
# 방법 1: Git Clone (권장)
cd ~
git clone https://github.com/YOUR_USERNAME/SuperClaude_Framework.git
cd SuperClaude_Framework

# 방법 2: ZIP 다운로드
curl -L https://github.com/YOUR_USERNAME/SuperClaude_Framework/archive/main.zip -o sc.zip
unzip sc.zip && cd SuperClaude_Framework-main
```

---

### 3단계: 자동 마이그레이션 실행 (2분)

```bash
# 실행 권한 부여
chmod +x migrate-to-droid.sh

# 드라이런 (선택, 시뮬레이션만)
./migrate-to-droid.sh --dry-run

# 실제 실행
./migrate-to-droid.sh
```

**성공 메시지**:
```
✅ SuperClaude → Droid 포팅 완료
📝 복사된 파일:
  • 슬래시 명령어: 26개
  • 모드 파일: 7개
  • 프레임워크: 6개
  • MCP 문서: 7개
```

---

### 4단계: MCP 서버 설정 (1분)

```bash
# mcp.json 복사
cp factory-mcp.json ~/.factory/mcp.json
chmod 600 ~/.factory/mcp.json

# API 키 입력 (선택사항, 나중에 설정 가능)
nano ~/.factory/mcp.json
# 또는
code ~/.factory/mcp.json
```

**API 키 필요한 서버** (선택사항):
- **context7**: Upstash Redis (공식 문서 검색용)
- **tavily**: Tavily API (웹 검색용)

**API 키 없이도 사용 가능**: 나머지 6개 MCP 서버는 API 키 없이 작동

---

### 5단계: Droid 재시작 및 테스트 (30초)

```bash
# Droid 재시작
pkill droid && droid
```

**Droid CLI 내에서 테스트**:

```
# 명령어 목록 확인
/commands

# 기본 테스트
/sc-help

# 프로젝트 분석
/sc-analyze .
```

**성공 지표**:
```
✅ **SC-FRAMEWORK**: sc-help | Droid-v2.0

## Available SuperClaude Commands
...
```

---

## 🎯 필수 명령어 블록 (복사-붙여넣기)

### 전체 프로세스 (한번에 실행)

```bash
# ===== 1. 다운로드 =====
cd ~
git clone https://github.com/YOUR_USERNAME/SuperClaude_Framework.git
cd SuperClaude_Framework

# ===== 2. 마이그레이션 =====
chmod +x migrate-to-droid.sh
./migrate-to-droid.sh

# ===== 3. MCP 설정 =====
cp factory-mcp.json ~/.factory/mcp.json
chmod 600 ~/.factory/mcp.json

# ===== 4. 완료 메시지 =====
echo "✅ 설치 완료! Droid를 재시작하세요: pkill droid && droid"
```

**Droid 재시작 후**:
```
/sc-help
/sc-analyze .
```

---

## 📊 설치 확인 체크리스트

### 필수 확인 사항

- [ ] migrate-to-droid.sh 성공 메시지 확인
- [ ] `~/.factory/commands/sc/` 디렉토리 생성 확인
- [ ] `~/.factory/mcp.json` 파일 존재 확인
- [ ] Droid 재시작 완료
- [ ] `/commands`에서 `/sc-` 명령어 26개 확인
- [ ] `/sc-help` 실행 시 Framework verification 메시지 출력
- [ ] `/sc-analyze .` 프로젝트 분석 성공

### 선택 확인 사항

- [ ] Context7 API 키 입력 (Upstash)
- [ ] Tavily API 키 입력
- [ ] AGENTS.md 생성 (선택)

---

## 🚀 즉시 사용 가능한 명령어

### 코드 분석

```
# 전체 프로젝트 분석
/sc-analyze .

# 특정 디렉토리 분석
/sc-analyze src/

# 특정 파일 분석
/sc-analyze package.json

# 심층 분석 (MCP 활성화)
/sc-analyze . --seq --think-hard
```

### 설계 및 구현

```
# 시스템 아키텍처 설계
/sc-design "사용자 인증 시스템" --type architecture

# API 설계
/sc-design "결제 API" --type api

# 컴포넌트 설계
/sc-design "대시보드 위젯" --type component
```

### 기능 구현

```
# React 컴포넌트 구현
/sc-implement "사용자 프로필 컴포넌트" --type component --framework react

# API 구현
/sc-implement "사용자 인증 API" --type api --safe --with-tests

# 전체 기능 구현
/sc-implement "결제 처리 시스템" --type feature --with-tests
```

### 프로젝트 관리

```
# 프로젝트 문서 생성
/sc-document "사용자 가이드" --focus user-guide

# 작업 추정
/sc-estimate "결제 시스템 구현"

# Git 커밋
/sc-git "Add payment processing feature"

# 테스트 실행
/sc-test --type integration --comprehensive
```

---

## ⚙️ API 키 설정 (선택사항)

API 키를 나중에 설정하려면:

### Context7 (Upstash Redis)

1. **가입**: https://upstash.com/
2. **Redis DB 생성**: 무료 티어
3. **키 복사**: REST API 탭에서 URL과 Token 복사
4. **입력**:

```bash
nano ~/.factory/mcp.json
```

```json
"context7": {
  "command": "npx",
  "args": ["-y", "@upstash/context7-mcp"],
  "env": {
    "UPSTASH_REDIS_REST_URL": "https://xxx.upstash.io",
    "UPSTASH_REDIS_REST_TOKEN": "AxxxxxxxxxxxA"
  },
  "disabled": false
}
```

### Tavily (웹 검색)

1. **가입**: https://tavily.com/
2. **API 키 발급**: 무료 1,000 검색/월
3. **입력**:

```json
"tavily": {
  "command": "npx",
  "args": ["-y", "@tavily/mcp-server"],
  "env": {
    "TAVILY_API_KEY": "tvly-xxxxxxxxxxxxxx"
  },
  "disabled": false
}
```

4. **Droid 재시작**: `pkill droid && droid`

---

## 🔧 빠른 트러블슈팅

### 명령어 인식 안됨

```bash
# 해결: Droid 재시작
pkill droid && droid
```

### MCP 서버 연결 실패

```bash
# 확인: Node.js 버전
node --version  # 18 이상

# 해결: Node.js 업그레이드
nvm install 20
nvm use 20
```

### API 키 오류

```bash
# 확인: mcp.json 문법
cat ~/.factory/mcp.json | jq .

# 해결: 공백/줄바꿈 제거, 따옴표 확인
nano ~/.factory/mcp.json
```

### $ARGUMENTS 파싱 문제

```
# ❌ 잘못됨
/sc-analyze TEST_TOKEN

# ✅ 올바름
/sc-analyze src/
/sc-analyze .
```

---

## 📚 추가 리소스

### 상세 가이드

전체 설명, 트러블슈팅, 고급 설정:
- **[Droid_Migration_Guide.md](./Droid_Migration_Guide.md)** - 완전한 마이그레이션 가이드

### 프로젝트 문서

- **TODO_MigDroid.md** - 마이그레이션 TODO 및 진행 상황
- **Analyze_Droid.md** - Droid CLI 아키텍처 분석
- **scUsage.md** - SuperClaude 명령어 사용 가이드

### MCP 서버 정보

8개 MCP 서버 설명:

| MCP | 기능 | API 키 |
|-----|------|--------|
| sequential-thinking | 다단계 추론 | ❌ |
| context7 | 공식 문서 검색 | ✅ |
| magic | UI 컴포넌트 생성 | ❌ |
| playwright | 브라우저 자동화 | ❌ |
| serena | 세션 관리 | ❌ |
| tavily | 웹 검색 | ✅ |
| chrome-devtools | Chrome DevTools | ❌ |
| morphllm | 패턴 기반 편집 | ❌ |

---

## ✅ 설치 완료!

**이제 사용 가능한 명령어**:

```
/sc-analyze      /sc-design       /sc-implement
/sc-test         /sc-document     /sc-git
/sc-help         /sc-brainstorm   /sc-troubleshoot
... 그 외 17개 명령어
```

**다음 단계**:
1. 실제 프로젝트에서 `/sc-analyze .` 실행해보기
2. `/sc-help`로 전체 명령어 목록 확인
3. `--seq`, `--think-hard` 플래그 활용하기

**Happy Coding with SuperClaude + Droid! 🚀**

---

## 🆘 도움이 필요하신가요?

- **상세 가이드**: [Droid_Migration_Guide.md](./Droid_Migration_Guide.md)
- **트러블슈팅**: [가이드 8장](./Droid_Migration_Guide.md#트러블슈팅)
- **GitHub Issues**: SuperClaude Framework 저장소
- **Droid CLI**: https://factory.ai/
