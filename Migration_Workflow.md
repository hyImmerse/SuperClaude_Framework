# SuperClaude → Droid CLI 마이그레이션 워크플로우

## 📋 문서 정보

**버전**: 1.0
**작성일**: 2025-10-25
**목적**: SuperClaude_Framework를 Droid CLI로 포팅하기 위한 포괄적인 마이그레이션 가이드
**예상 소요 시간**: 1.5-2시간

---

## 1. 개요 및 목표

### 1.1 프로젝트 소개

SuperClaude_Framework는 Claude Code를 위한 강력한 확장 프레임워크로, 26개의 전문 슬래시 명령어, 7개의 행동 모드, 8개의 MCP 서버 통합을 제공합니다. 본 마이그레이션 프로젝트는 이 프레임워크를 Droid CLI에서도 사용 가능하도록 포팅하여, 양쪽 시스템에서 동일한 강력한 개발 환경을 구축합니다.

### 1.2 목표

**주요 목표**:
- SuperClaude의 모든 기능을 Droid CLI에서 사용 가능하도록 포팅
- Claude Code와 Droid 양쪽에서 동일한 `/sc:` 명령어 사용
- 설정의 독립성 유지 (각 시스템 별도 관리)

**세부 목표**:
1. 26개 슬래시 명령어 포팅 (텍스트 치환)
2. 프레임워크 문서 복사 (7개 모드 + 6개 프레임워크 + 7개 MCP 문서)
3. MCP 서버 설정 (~/.factory/mcp.json 생성)
4. 통합 AGENTS.md 생성 (Droid 최적화)
5. 완전한 검증 및 테스트

### 1.3 성공 지표

**필수 조건 (Must Have)**:
- ✅ ~/.factory/mcp.json 생성 및 JSON 유효성 검증
- ✅ 26개 슬래시 명령어 100% 변환 완료
- ✅ 모든 프레임워크 문서 (20개) 복사 완료
- ✅ AGENTS.md 통합 파일 생성 (150줄 이하)
- ✅ Droid에서 `/sc:help` 실행 성공

**품질 지표**:
- JSON 유효성: mcp.json lint 통과
- Markdown 유효성: 모든 .md 파일 lint 통과
- 텍스트 치환 정확도: 100% (0개 미치환)
- YAML frontmatter 유지율: 100%

---

## 2. 사전 준비

### 2.1 필수 조건

**시스템 요구사항**:
```bash
# SuperClaude_Framework 설치 확인
ls ~/.claude/commands/sc/  # 26개 명령어 파일 존재

# Droid CLI 설치 확인
droid --version  # v0.22.2 이상

# 필수 도구 확인
which sed  # 텍스트 치환
which jq   # JSON 검증 (선택적)
```

**파일 존재 확인**:
- ✅ ~/.claude/commands/sc/*.md (26개)
- ✅ ~/.claude/MODE_*.md (7개)
- ✅ ~/.claude/{PRINCIPLES,RULES,FLAGS,RESEARCH_CONFIG,BUSINESS_SYMBOLS,BUSINESS_PANEL_EXAMPLES}.md (6개)
- ✅ ~/.claude/MCP_*.md (7개)

### 2.2 백업 전략

```bash
# 백업 디렉토리 생성
BACKUP_DIR=~/.factory-backup-$(date +%Y%m%d-%H%M%S)
mkdir -p "$BACKUP_DIR"

# 기존 설정 백업 (있는 경우)
if [ -d ~/.factory ]; then
    cp -r ~/.factory/* "$BACKUP_DIR/"
    echo "✅ 백업 완료: $BACKUP_DIR"
fi
```

### 2.3 환경 확인

```bash
# Droid 디렉토리 확인
ls -la ~/.factory/

# 디스크 공간 확인 (최소 10MB 필요)
df -h ~ | grep -v Filesystem
```

---

## 3. 디렉토리 구조 설계

### 3.1 소스 → 타겟 매핑

```
SuperClaude (Claude Code)          Droid CLI (타겟)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
~/.claude/                         ~/.factory/
├── commands/sc/ (26개)       →   ├── commands/sc/ (26개) *치환*
├── MODE_*.md (7개)           →   ├── superclaude/modes/ (7개)
├── PRINCIPLES.md             →   ├── superclaude/framework/
├── RULES.md                  →   │   ├── PRINCIPLES.md
├── FLAGS.md                  →   │   ├── RULES.md
├── RESEARCH_CONFIG.md        →   │   ├── FLAGS.md
├── BUSINESS_SYMBOLS.md       →   │   ├── RESEARCH_CONFIG.md
├── BUSINESS_PANEL_EXAMPLES.md→   │   ├── BUSINESS_SYMBOLS.md
└── MCP_*.md (7개)            →   │   └── BUSINESS_PANEL_EXAMPLES.md
                                   ├── superclaude/mcp/ (7개)
                                   ├── mcp.json *신규*
                                   └── AGENTS.md *신규*
```

### 3.2 파일 목록 (총 40개)

**슬래시 명령어** (26개):
```
analyze.md, implement.md, brainstorm.md, research.md, task.md,
design.md, document.md, explain.md, build.md, test.md,
troubleshoot.md, cleanup.md, improve.md, workflow.md, git.md,
save.md, load.md, reflect.md, estimate.md, spec-panel.md,
business-panel.md, help.md, index.md, select-tool.md, spawn.md, pm.md
```

**모드 파일** (7개):
```
MODE_Brainstorming.md, MODE_DeepResearch.md, MODE_Introspection.md,
MODE_Orchestration.md, MODE_Task_Management.md, MODE_Token_Efficiency.md,
MODE_Business_Panel.md
```

**프레임워크 문서** (6개):
```
PRINCIPLES.md, RULES.md, FLAGS.md, RESEARCH_CONFIG.md,
BUSINESS_SYMBOLS.md, BUSINESS_PANEL_EXAMPLES.md
```

**MCP 문서** (7개):
```
MCP_Sequential.md, MCP_Context7.md, MCP_Magic.md, MCP_Playwright.md,
MCP_Serena.md, MCP_Tavily.md, MCP_Morphllm.md
```

---

## 4. 파일 변환 규칙

### 4.1 텍스트 치환 규칙

**명령어 파일에만 적용** (~/.factory/commands/sc/*.md):

| 원본 텍스트 | 치환 텍스트 |
|------------|-----------|
| `Claude Code` | `Droid CLI` |
| `~/.claude/` | `~/.factory/` |
| `claude_desktop_config.json` | `mcp.json` |

**프레임워크 문서는 치환 불필요**:
- MODE, PRINCIPLES, RULES 등은 시스템 독립적
- 그대로 복사만 수행

### 4.2 YAML Frontmatter 유지

```markdown
---
description: 원래 설명 유지
argument-hint: 원래 힌트 유지
---

본문 내용에서만 텍스트 치환
```

### 4.3 sed 명령어

```bash
# 단일 파일 변환
sed 's/Claude Code/Droid CLI/g; s|~/.claude/|~/.factory/|g' input.md > output.md

# 여러 파일 일괄 변환
for file in ~/.claude/commands/sc/*.md; do
    filename=$(basename "$file")
    sed 's/Claude Code/Droid CLI/g; s|~/.claude/|~/.factory/|g' \
        "$file" > ~/.factory/commands/sc/"$filename"
done
```

---

## 5. MCP 서버 설정

### 5.1 8개 MCP 서버

~/.factory/mcp.json 파일 구조:

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "disabled": false
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "env": {
        "UPSTASH_REDIS_REST_URL": "",
        "UPSTASH_REDIS_REST_TOKEN": ""
      },
      "disabled": false
    },
    "magic": {
      "command": "npx",
      "args": ["-y", "@21st-dev/magic"],
      "disabled": false
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@executeautomation/playwright-mcp-server"],
      "disabled": false
    },
    "serena": {
      "command": "npx",
      "args": ["-y", "@serenaai/mcp-server"],
      "disabled": false
    },
    "tavily": {
      "command": "npx",
      "args": ["-y", "@tavily/mcp-server"],
      "env": {
        "TAVILY_API_KEY": ""
      },
      "disabled": false
    },
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-chrome-devtools"],
      "disabled": false
    },
    "morphllm": {
      "command": "npx",
      "args": ["-y", "@morphllm/mcp-server"],
      "disabled": false
    }
  }
}
```

### 5.2 환경 변수 관리

**API 키가 필요한 서버**:
1. **context7**: Upstash Redis 설정 필요
   - UPSTASH_REDIS_REST_URL
   - UPSTASH_REDIS_REST_TOKEN

2. **tavily**: Tavily API 키 필요
   - TAVILY_API_KEY

**설정 방법**:
```bash
# mcp.json 편집
vim ~/.factory/mcp.json

# 환경 변수 값 입력 (빈 문자열을 실제 값으로 교체)
"env": {
  "UPSTASH_REDIS_REST_URL": "https://your-url.upstash.io",
  "UPSTASH_REDIS_REST_TOKEN": "your-token"
}
```

---

## 6. 실행 단계

### Phase 1: 기반 설정 (5-10분)

**Task 1.1: 디렉토리 구조 생성**

```bash
# 디렉토리 생성
mkdir -p ~/.factory/commands/sc
mkdir -p ~/.factory/superclaude/modes
mkdir -p ~/.factory/superclaude/framework
mkdir -p ~/.factory/superclaude/mcp

# 검증
ls -la ~/.factory/
```

**완료 조건**:
- [ ] 4개 디렉토리 모두 생성됨

---

### Phase 2: MCP 서버 설정 (5-10분)

**Task 2.1: mcp.json 생성**

```bash
# mcp.json 생성 (위의 JSON 구조 사용)
cat > ~/.factory/mcp.json << 'EOF'
{
  "mcpServers": {
    ...  # 위의 5.1 JSON 내용
  }
}
EOF

# JSON 유효성 검증
jq empty ~/.factory/mcp.json && echo "✅ JSON 유효" || echo "❌ JSON 오류"
```

**완료 조건**:
- [ ] mcp.json 생성됨
- [ ] JSON 문법 유효

---

### Phase 3: 슬래시 명령어 포팅 (10-15분)

**Task 3.1: 명령어 파일 변환 (26개)**

```bash
# 일괄 변환 스크립트
SOURCE_DIR=~/.claude/commands/sc
TARGET_DIR=~/.factory/commands/sc

for file in "$SOURCE_DIR"/*.md; do
    filename=$(basename "$file")
    echo "  변환 중: $filename"

    sed 's/Claude Code/Droid CLI/g; s|~/.claude/|~/.factory/|g' \
        "$file" > "$TARGET_DIR/$filename"
done

echo "✅ 명령어 변환 완료"
```

**완료 조건**:
- [ ] 26개 파일 모두 변환
- [ ] YAML frontmatter 유지
- [ ] 텍스트 치환 완료

---

### Phase 4: 프레임워크 문서 복사 (5-10분)

**Task 4.1: 모드 파일 복사 (7개)**

```bash
# 모드 파일 복사
cp ~/.claude/MODE_*.md ~/.factory/superclaude/modes/

# 검증
ls ~/.factory/superclaude/modes/ | wc -l  # 7이어야 함
```

**Task 4.2: 프레임워크 문서 복사 (6개)**

```bash
# 프레임워크 문서 복사
FRAMEWORK_FILES=(
    "PRINCIPLES.md"
    "RULES.md"
    "FLAGS.md"
    "RESEARCH_CONFIG.md"
    "BUSINESS_SYMBOLS.md"
    "BUSINESS_PANEL_EXAMPLES.md"
)

for file in "${FRAMEWORK_FILES[@]}"; do
    cp ~/.claude/"$file" ~/.factory/superclaude/framework/
done

# 검증
ls ~/.factory/superclaude/framework/ | wc -l  # 6이어야 함
```

**Task 4.3: MCP 문서 복사 (7개)**

```bash
# MCP 문서 복사
cp ~/.claude/MCP_*.md ~/.factory/superclaude/mcp/

# 검증
ls ~/.factory/superclaude/mcp/ | wc -l  # 7이어야 함
```

**완료 조건**:
- [ ] 모드 파일 7개
- [ ] 프레임워크 문서 6개
- [ ] MCP 문서 7개

---

### Phase 5: 통합 AGENTS.md 생성 (20-30분)

**Task 5.1: AGENTS.md 작성**

이 작업은 `/sc:implement` 명령어를 사용하여 수행합니다:

```bash
/sc:implement "Droid CLI용 통합 AGENTS.md 파일(~/.factory/AGENTS.md) 생성: SuperClaude 프레임워크 전체를 하나의 통합 파일로 병합, 다음 내용 포함 - (1) 핵심 원칙(PRINCIPLES.md 요약), (2) 주요 행동 규칙(RULES.md 핵심 사항), (3) MCP 서버 통합 가이드(8개 서버 설명 및 사용법), (4) 슬래시 명령어 목록(26개 명령어 설명), (5) 행동 모드 시스템(7개 모드 트리거 및 효과), (6) 플래그 시스템(--think, --seq, --magic 등), (7) 사용 예시, Markdown 형식, Droid 최적화, 한국어 작성, 150줄 이하로 간결하게" --persona-scribe=ko --comprehensive
```

**완료 조건**:
- [ ] AGENTS.md 생성됨
- [ ] 150줄 이하
- [ ] 모든 섹션 포함

---

### Phase 6: 검증 및 테스트 (10-15분)

진행하기 전에 Phase 6 검증으로 넘어갑니다 (다음 섹션).

---

## 7. 검증 및 테스트

### 7.1 자동 검증

**검증 스크립트**:

```bash
#!/bin/bash
# verify-migration.sh

echo "=== SuperClaude → Droid 포팅 검증 ==="
echo ""

# 1. 디렉토리 구조 확인
echo "1️⃣ 디렉토리 구조 확인"
DIRS=(
    "~/.factory/commands/sc"
    "~/.factory/superclaude/modes"
    "~/.factory/superclaude/framework"
    "~/.factory/superclaude/mcp"
)

for dir in "${DIRS[@]}"; do
    expanded_dir="${dir/#\~/$HOME}"
    if [ -d "$expanded_dir" ]; then
        echo "  ✅ $dir"
    else
        echo "  ❌ $dir (누락)"
    fi
done

# 2. 파일 개수 확인
echo ""
echo "2️⃣ 파일 개수 확인"
COMMANDS_COUNT=$(ls ~/.factory/commands/sc/*.md 2>/dev/null | wc -l)
MODES_COUNT=$(ls ~/.factory/superclaude/modes/*.md 2>/dev/null | wc -l)
FRAMEWORK_COUNT=$(ls ~/.factory/superclaude/framework/*.md 2>/dev/null | wc -l)
MCP_COUNT=$(ls ~/.factory/superclaude/mcp/*.md 2>/dev/null | wc -l)

echo "  슬래시 명령어: $COMMANDS_COUNT / 26"
echo "  모드 파일: $MODES_COUNT / 7"
echo "  프레임워크 문서: $FRAMEWORK_COUNT / 6"
echo "  MCP 문서: $MCP_COUNT / 7"

# 3. JSON 유효성 확인
echo ""
echo "3️⃣ JSON 유효성 확인"
if jq empty ~/.factory/mcp.json 2>/dev/null; then
    echo "  ✅ mcp.json 유효"
else
    echo "  ❌ mcp.json 오류"
fi

# 4. 텍스트 치환 확인
echo ""
echo "4️⃣ 텍스트 치환 확인"
CLAUDE_COUNT=$(grep -r "Claude Code" ~/.factory/commands/sc/ 2>/dev/null | wc -l)
DROID_COUNT=$(grep -r "Droid CLI" ~/.factory/commands/sc/ 2>/dev/null | wc -l)

if [ "$CLAUDE_COUNT" -eq 0 ]; then
    echo "  ✅ 'Claude Code' 미존재"
else
    echo "  ❌ 'Claude Code' $CLAUDE_COUNT개 발견"
fi

if [ "$DROID_COUNT" -gt 0 ]; then
    echo "  ✅ 'Droid CLI' 존재"
else
    echo "  ❌ 'Droid CLI' 미존재"
fi

# 5. AGENTS.md 확인
echo ""
echo "5️⃣ AGENTS.md 확인"
if [ -f ~/.factory/AGENTS.md ]; then
    LINES=$(wc -l < ~/.factory/AGENTS.md)
    echo "  ✅ AGENTS.md 존재 ($LINES 줄)"
    if [ "$LINES" -le 150 ]; then
        echo "  ✅ 줄 수 적합 (≤ 150)"
    else
        echo "  ⚠️  줄 수 초과 (> 150)"
    fi
else
    echo "  ❌ AGENTS.md 누락"
fi

echo ""
echo "=== 검증 완료 ==="
```

### 7.2 수동 테스트

**Droid 실행 테스트**:

```bash
# 1. Droid 실행
droid

# 2. 명령어 목록 확인
/commands
# → sc/ 디렉토리에 26개 명령어 확인

# 3. SuperClaude 헬프 명령어
/sc:help

# 4. 간단한 명령어 테스트
/sc:explain "포팅 완료 확인"
```

### 7.3 체크리스트

**완료 체크리스트**:

- [ ] **디렉토리 구조**
  - [ ] ~/.factory/commands/sc/ 존재
  - [ ] ~/.factory/superclaude/modes/ 존재
  - [ ] ~/.factory/superclaude/framework/ 존재
  - [ ] ~/.factory/superclaude/mcp/ 존재

- [ ] **파일 개수**
  - [ ] 슬래시 명령어: 26개
  - [ ] 모드 파일: 7개
  - [ ] 프레임워크 문서: 6개
  - [ ] MCP 문서: 7개
  - [ ] mcp.json: 1개
  - [ ] AGENTS.md: 1개

- [ ] **파일 내용**
  - [ ] mcp.json: JSON 유효
  - [ ] 모든 .md 파일: Markdown 유효
  - [ ] 명령어 파일: YAML frontmatter 유지

- [ ] **텍스트 치환**
  - [ ] "Claude Code" 미존재 (명령어 파일)
  - [ ] "Droid CLI" 존재
  - [ ] "~/.claude/" 미존재
  - [ ] "~/.factory/" 존재

- [ ] **기능 테스트**
  - [ ] Droid 실행 성공
  - [ ] /commands에서 sc/ 확인
  - [ ] /sc:help 실행 성공

---

## 8. 품질 게이트

### Gate 1: 소스 파일 존재 확인

**검증 항목**:
- SuperClaude 명령어 26개 파일 존재
- MODE 파일 7개 존재
- Framework 파일 6개 존재
- MCP 문서 7개 존재

**통과 조건**: 모든 파일 존재

**실패 시 조치**:
- SuperClaude_Framework 설치 확인
- 파일 경로 확인
- 포팅 중단

---

### Gate 2: 디렉토리 생성 검증

**검증 항목**:
- ~/.factory/commands/sc/ 생성됨
- ~/.factory/superclaude/{modes,framework,mcp}/ 생성됨

**통과 조건**: 모든 디렉토리 생성

**실패 시 조치**:
- 권한 확인 (`ls -la ~/.factory/`)
- 디렉토리 재생성 시도
- 백업에서 복원

---

### Gate 3: 파일 복사 검증

**검증 항목**:
- 모든 파일이 타겟 디렉토리에 존재
- 파일 크기 > 0

**통과 조건**: 40개 파일 모두 복사

**실패 시 조치**:
- 누락된 파일 확인
- 부분 롤백 후 재시도
- 복사 명령어 재실행

---

### Gate 4: 텍스트 치환 검증

**검증 항목**:
- grep으로 "Claude Code" 문자열 미존재 확인
- grep으로 "Droid CLI" 문자열 존재 확인

**통과 조건**: 치환 100% 완료

**실패 시 조치**:
- sed 명령어 재실행
- 수동 치환
- 파일별 검증

---

### Gate 5: JSON 문법 검증

**검증 항목**:
- jq 또는 python으로 mcp.json 유효성 확인

**통과 조건**: JSON 파서 통과

**실패 시 조치**:
- 문법 오류 수정
- JSON 재생성
- 온라인 validator 사용

---

### Gate 6: 기능 테스트

**검증 항목**:
- Droid 실행 가능
- /sc:help 실행 성공

**통과 조건**: 명령어 정상 작동

**실패 시 조치**:
- Droid 재시작
- 명령어 새로고침 (/commands → Reload)
- 설정 파일 확인

---

## 9. 리스크 및 완화

### 9.1 리스크 매트릭스

| 리스크 | 영향도 | 발생 확률 | 우선순위 |
|--------|--------|----------|---------|
| 기존 Droid 설정 덮어쓰기 | High | Low | 🔴 Critical |
| API 키 노출 | High | Low | 🔴 Critical |
| 텍스트 치환 오류 | Medium | Medium | 🟡 High |
| MCP 서버 연결 실패 | Medium | Medium | 🟡 High |
| 파일 복사 실패 | Low | Low | 🟢 Medium |
| AGENTS.md 줄 수 초과 | Low | Low | 🟢 Low |

### 9.2 완화 전략

**🔴 Critical 리스크**:

1. **기존 설정 덮어쓰기**
   - 완화: 백업 필수, 확인 프롬프트
   - 복구: 백업에서 복원

2. **API 키 노출**
   - 완화: 빈 플레이스홀더 사용, .gitignore 확인
   - 복구: 키 재발급

**🟡 High 리스크**:

3. **텍스트 치환 오류**
   - 완화: 검증 Gate, 수동 확인
   - 복구: 재치환 또는 수동 수정

4. **MCP 서버 연결 실패**
   - 완화: disabled 플래그, 트러블슈팅 가이드
   - 복구: 서버 재설정

### 9.3 롤백 절차

```bash
# 전체 롤백
rm -rf ~/.factory/commands/sc
rm -rf ~/.factory/superclaude
rm ~/.factory/mcp.json ~/.factory/AGENTS.md

# 백업 복원
BACKUP_DIR=~/.factory-backup-YYYYMMDD-HHMMSS
cp -r "$BACKUP_DIR"/* ~/.factory/

# Droid 재시작
pkill droid
droid
```

---

## 10. 트러블슈팅

### 10.1 일반적인 문제

**문제 1: 명령어 인식 안됨**

증상:
```
/sc:help 실행 시 "명령어를 찾을 수 없음"
```

해결:
```bash
# Droid 내에서
/commands
# → "Reload Commands" 선택

# 디렉토리 확인
ls -la ~/.factory/commands/sc/
```

---

**문제 2: MCP 연결 실패**

증상:
```
MCP 도구 사용 불가 오류
```

해결:
```bash
# Droid 내에서
/mcp list

# 서버 활성화
/mcp enable sequential-thinking
/mcp enable tavily

# mcp.json 확인
cat ~/.factory/mcp.json
```

---

**문제 3: API 키 오류**

증상:
```
Context7, Tavily 인증 실패
```

해결:
```bash
# mcp.json 편집
vim ~/.factory/mcp.json

# 환경 변수 설정 (빈 문자열을 실제 값으로)
"env": {
  "UPSTASH_REDIS_REST_URL": "https://your-url.upstash.io",
  "UPSTASH_REDIS_REST_TOKEN": "your-token"
}

# Droid 재시작
pkill droid
droid
```

---

**문제 4: JSON 문법 오류**

증상:
```
mcp.json 파싱 실패
```

해결:
```bash
# JSON 검증
jq empty ~/.factory/mcp.json

# 오류 확인
jq . ~/.factory/mcp.json

# 온라인 validator 사용
# https://jsonlint.com/
```

### 10.2 FAQ

**Q: SuperClaude와 Droid 설정을 동기화하려면?**

A: 수동 동기화 또는 스크립트 재실행:
```bash
# 변경된 파일만 복사
rsync -av ~/.claude/commands/sc/ ~/.factory/commands/sc/
sed -i 's/Claude Code/Droid CLI/g' ~/.factory/commands/sc/*.md
```

**Q: Droid에서 특정 MCP 서버를 비활성화하려면?**

A: mcp.json에서 disabled: true 설정:
```json
"sequential-thinking": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
  "disabled": true  // 비활성화
}
```

**Q: AGENTS.md가 150줄을 초과하면?**

A: 핵심 내용만 남기고 상세 내용은 별도 파일 링크:
```markdown
## MCP 서버 통합
상세 가이드: ~/.factory/superclaude/mcp/
```

---

## 11. 유지보수 및 향후 계획

### 11.1 정기 업데이트 (월 1회)

```bash
# 1. SuperClaude_Framework 업데이트 확인
cd ~/SuperClaude_Framework
git pull

# 2. 변경된 파일 확인
git diff --name-only HEAD@{1}

# 3. Droid로 동기화
# 변경된 파일만 복사 후 치환
```

### 11.2 동기화 방법

**Option 1: 전체 재포팅**
```bash
# 포팅 스크립트 재실행 (백업 포함)
./migrate-to-droid.sh
```

**Option 2: 선택적 업데이트**
```bash
# 특정 파일만 업데이트
cp ~/.claude/commands/sc/analyze.md ~/.factory/commands/sc/
sed -i 's/Claude Code/Droid CLI/g' ~/.factory/commands/sc/analyze.md
```

### 11.3 변경 추적

```bash
# 변경 로그 기록
echo "$(date): Updated analyze.md" >> ~/.factory/migration-log.txt
```

### 11.4 향후 개선 사항

1. **자동 동기화 스크립트**
   - Git hook 기반 자동 포팅
   - 변경 감지 및 자동 업데이트

2. **통합 설정 관리**
   - 양쪽 시스템 설정 중앙 관리
   - 환경 변수 통합

3. **커뮤니티 기여**
   - Droid용 SuperClaude 포팅 가이드 공유
   - 베스트 프랙티스 문서화

---

## 12. 요약 및 다음 단계

### 12.1 워크플로우 요약

```
Phase 1: 기반 설정 (5-10분)
  → 디렉토리 생성

Phase 2: MCP 설정 (5-10분)
  → mcp.json 생성

Phase 3: 명령어 포팅 (10-15분)
  → 26개 파일 변환

Phase 4: 문서 복사 (5-10분)
  → 20개 파일 복사

Phase 5: AGENTS.md (20-30분)
  → 통합 파일 생성

Phase 6: 검증 (10-15분)
  → 자동/수동 테스트

총 예상 시간: 1.5-2시간
```

### 12.2 즉시 실행 명령어

```bash
# 1. 백업
BACKUP_DIR=~/.factory-backup-$(date +%Y%m%d-%H%M%S)
mkdir -p "$BACKUP_DIR"
[ -d ~/.factory ] && cp -r ~/.factory/* "$BACKUP_DIR/"

# 2. 디렉토리 생성
mkdir -p ~/.factory/commands/sc
mkdir -p ~/.factory/superclaude/{modes,framework,mcp}

# 3. 명령어 변환
for file in ~/.claude/commands/sc/*.md; do
    filename=$(basename "$file")
    sed 's/Claude Code/Droid CLI/g; s|~/.claude/|~/.factory/|g' \
        "$file" > ~/.factory/commands/sc/"$filename"
done

# 4. 문서 복사
cp ~/.claude/MODE_*.md ~/.factory/superclaude/modes/
cp ~/.claude/{PRINCIPLES,RULES,FLAGS,RESEARCH_CONFIG,BUSINESS_SYMBOLS,BUSINESS_PANEL_EXAMPLES}.md \
   ~/.factory/superclaude/framework/
cp ~/.claude/MCP_*.md ~/.factory/superclaude/mcp/

# 5. MCP 설정 (별도 생성 필요)
# 6. AGENTS.md (별도 생성 필요)

echo "✅ 기본 포팅 완료! 이제 mcp.json과 AGENTS.md를 생성하세요."
```

### 12.3 다음 단계

1. ✅ **워크플로우 문서 완성** ← 현재 단계
2. ⏭️ **Phase 2 실행**: /sc:implement로 포팅 스크립트 작성
3. ⏭️ **Phase 3 실행**: /sc:implement로 mcp.json 생성
4. ⏭️ **Phase 4-5 실행**: 파일 포팅 (병렬 가능)
5. ⏭️ **Phase 6 실행**: /sc:implement로 AGENTS.md 생성
6. ⏭️ **Phase 7 실행**: /sc:test로 검증
7. ⏭️ **Phase 8 실행**: /sc:document로 사용자 가이드 작성
8. ⏭️ **Phase 9 실행**: /sc:reflect로 회고

---

**문서 종료**

이 워크플로우 문서는 SuperClaude_Framework를 Droid CLI로 포팅하기 위한 포괄적인 가이드입니다.
모든 단계를 순차적으로 따르면 안전하고 효율적인 마이그레이션을 완료할 수 있습니다.
