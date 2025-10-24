# SuperClaude Framework → Droid CLI 마이그레이션 가이드

> **완전한 설치 가이드** - 다른 PC에서 Droid CLI로 SuperClaude Framework를 포팅하는 전체 프로세스

**버전**: 1.0
**날짜**: 2025-10-25
**대상**: Droid CLI 사용자

---

## 📑 목차

1. [개요](#개요)
2. [시스템 요구사항](#시스템-요구사항)
3. [사전 준비](#사전-준비)
4. [자동 마이그레이션 실행](#자동-마이그레이션-실행)
5. [MCP 서버 설정](#mcp-서버-설정)
6. [API 키 설정](#api-키-설정)
7. [검증 및 테스트](#검증-및-테스트)
8. [트러블슈팅](#트러블슈팅)
9. [추가 설정](#추가-설정-선택사항)
10. [참고자료](#참고자료)

---

## 개요

### SuperClaude Framework란?

SuperClaude Framework는 Claude AI의 능력을 극대화하는 통합 프레임워크입니다:

- **26개 슬래시 명령어**: `/sc-analyze`, `/sc-design`, `/sc-implement` 등 전문화된 명령어
- **7개 행동 모드**: Brainstorming, Introspection, Task Management 등
- **8개 MCP 서버**: Sequential Thinking, Context7, Magic, Playwright 등
- **프레임워크 문서**: PRINCIPLES.md, RULES.md, FLAGS.md 등

### Droid CLI 포팅의 이점

- ✅ Claude Code와 동일한 강력한 기능을 Droid에서 사용
- ✅ 26개의 전문화된 슬래시 명령어 활용
- ✅ MCP 서버 통합으로 확장된 기능
- ✅ 프로젝트 분석, 설계, 구현, 테스트 자동화

### 예상 소요 시간

| 단계 | 예상 시간 |
|------|-----------|
| 사전 준비 | 10-15분 |
| 자동 마이그레이션 실행 | 2-3분 |
| MCP 서버 설정 | 5-10분 |
| API 키 설정 | 5-10분 |
| 검증 및 테스트 | 5분 |
| **전체** | **30-45분** |

---

## 시스템 요구사항

### 운영체제

- ✅ **Linux** (Ubuntu, Debian, Fedora, Arch 등)
- ✅ **macOS** (10.15 이상)
- ✅ **Windows WSL2** (Ubuntu 20.04 이상 권장)

### 필수 소프트웨어

#### Bash 4.0 이상

```bash
# 버전 확인
bash --version

# 출력 예시: GNU bash, version 5.1.16
```

#### Node.js 18 이상

```bash
# 버전 확인
node --version

# 출력 예시: v20.11.0
```

**설치 (Node.js 없을 경우)**:
```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS
brew install node

# 또는 nvm 사용 (권장)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
```

#### 필수 명령어 도구

```bash
# 필수 도구 확인
command -v git && echo "✅ git 설치됨" || echo "❌ git 필요"
command -v curl && echo "✅ curl 설치됨" || echo "❌ curl 필요"
command -v sed && echo "✅ sed 설치됨" || echo "❌ sed 필요"
```

**설치 (누락된 도구가 있을 경우)**:
```bash
# Ubuntu/Debian
sudo apt install git curl sed

# Fedora/RHEL
sudo dnf install git curl sed

# macOS
# 기본 설치됨, 또는 brew로 설치
brew install git curl gnu-sed
```

### 디스크 공간

- 최소 **50MB** 여유 공간 필요
- 백업 포함 시 **100MB** 권장

---

## 사전 준비

### 1단계: SuperClaude Framework 다운로드

#### 옵션 A: Git Clone (권장)

```bash
# GitHub에서 복제
cd ~
git clone https://github.com/YOUR_USERNAME/SuperClaude_Framework.git

# 또는 특정 위치에 복제
git clone https://github.com/YOUR_USERNAME/SuperClaude_Framework.git ~/superclaude
```

#### 옵션 B: ZIP 다운로드

```bash
# ZIP 파일 다운로드
curl -L https://github.com/YOUR_USERNAME/SuperClaude_Framework/archive/refs/heads/main.zip -o superclaude.zip

# 압축 해제
unzip superclaude.zip
mv SuperClaude_Framework-main SuperClaude_Framework
```

#### 디렉토리 구조 확인

```bash
cd SuperClaude_Framework
ls -la

# 다음 파일들이 있어야 함:
# - migrate-to-droid.sh       (자동 마이그레이션 스크립트)
# - factory-mcp.json          (MCP 서버 설정)
# - superclaude/              (프레임워크 문서)
# - TODO_MigDroid.md          (마이그레이션 TODO)
```

**체크리스트**:
- [ ] SuperClaude_Framework 디렉토리 생성 완료
- [ ] migrate-to-droid.sh 파일 존재 확인
- [ ] factory-mcp.json 파일 존재 확인

---

### 2단계: Droid CLI 설치

#### macOS / Linux 설치

```bash
# Droid CLI 자동 설치 스크립트
curl -fsSL https://app.factory.ai/cli | sh
```

**설치 스크립트 동작**:
1. 플랫폼 및 아키텍처 자동 감지 (x64/arm64)
2. Droid CLI v0.22.2 바이너리 다운로드
3. Ripgrep (rg) 검색 도구 설치
4. `~/.local/bin/droid` 설치
5. 실행 권한 부여

#### Windows (WSL2)

```powershell
# WSL2 내에서 Linux 설치 명령어 사용
curl -fsSL https://app.factory.ai/cli | sh
```

#### PATH 환경변수 설정

설치 후 `~/.local/bin`이 PATH에 포함되지 않았다면:

```bash
# zsh 사용자
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# bash 사용자
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# sh 사용자
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
source ~/.profile
```

#### Linux 추가 요구사항

Ubuntu/Debian 사용자는 xdg-utils 설치 필요:

```bash
# Ubuntu/Debian
sudo apt install xdg-utils

# Fedora/RHEL
sudo dnf install xdg-utils

# Arch Linux
sudo pacman -S xdg-utils
```

#### 설치 확인

```bash
# Droid 버전 확인
droid --version

# 출력 예시: droid 0.22.2
```

**체크리스트**:
- [ ] Droid CLI 설치 완료
- [ ] PATH 환경변수 설정 완료
- [ ] `droid --version` 명령어 작동 확인
- [ ] Linux: xdg-utils 설치 완료 (해당 시)

---

## 자동 마이그레이션 실행

`migrate-to-droid.sh` 스크립트가 다음 작업을 자동으로 수행합니다:

### 스크립트가 처리하는 것

✅ **디렉토리 구조 생성**:
- `~/.factory/commands/sc/` (26개 슬래시 명령어)
- `~/.factory/superclaude/modes/` (7개 모드 파일)
- `~/.factory/superclaude/framework/` (6개 프레임워크 문서)
- `~/.factory/superclaude/mcp/` (7개 MCP 문서)

✅ **파일 변환 및 복사**:
- 슬래시 명령어: 텍스트 치환 (Claude Code → Droid CLI)
- 프레임워크 문서: 그대로 복사
- 경로 변환: `~/.claude/` → `~/.factory/`

✅ **백업 생성**:
- 기존 `~/.factory/` 내용을 `~/.factory-backup-TIMESTAMP/`에 백업

✅ **검증**:
- 파일 개수 확인 (26개 명령어, 7개 모드 등)
- 텍스트 치환 확인 ("Claude Code" 문자열 미존재)

### 스크립트가 처리하지 않는 것 (수동 필요)

❌ `~/.factory/mcp.json` 생성 → [5단계](#mcp-서버-설정)에서 수동 설정
❌ API 키 설정 → [6단계](#api-키-설정)에서 수동 설정
❌ `~/.factory/AGENTS.md` 생성 → [9단계](#추가-설정-선택사항)에서 선택사항

---

### 1단계: 스크립트 권한 설정

```bash
cd ~/SuperClaude_Framework

# 실행 권한 부여
chmod +x migrate-to-droid.sh
```

---

### 2단계: 드라이런 모드 (선택사항, 권장)

실제 변경 없이 시뮬레이션만 실행:

```bash
./migrate-to-droid.sh --dry-run
```

**출력 예시**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SuperClaude → Droid CLI 자동 포팅 스크립트
  버전: 1.0
  날짜: 2025-10-25 14:30:00
  모드: DRY RUN (시뮬레이션)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ 사전 조건 확인 중...
✅ 사전 조건 확인 완료

ℹ 소스 파일 존재 여부 확인 중...
✅ 소스 파일 확인 완료

ℹ [DRY RUN] 백업 디렉토리 생성: ~/.factory-backup-20251025-143000

ℹ [DRY RUN] 디렉토리 생성: ~/.factory/commands/sc
ℹ [DRY RUN] 디렉토리 생성: ~/.factory/superclaude/modes
ℹ [DRY RUN] 디렉토리 생성: ~/.factory/superclaude/framework
ℹ [DRY RUN] 디렉토리 생성: ~/.factory/superclaude/mcp
✅ 디렉토리 구조 생성 완료

ℹ [DRY RUN] 변환: sc-analyze.md
...
```

---

### 3단계: 실제 마이그레이션 실행

```bash
./migrate-to-droid.sh
```

**실행 과정**:
1. 사전 조건 확인 (Bash 4.0+, 필수 명령어, SuperClaude 설치)
2. 소스 파일 존재 확인
3. 기존 설정 백업 생성
4. 디렉토리 구조 생성
5. 슬래시 명령어 파일 변환 (26개)
6. 모드 파일 복사 (7개)
7. 프레임워크 문서 복사 (6개)
8. MCP 문서 복사 (7개)
9. 파일 권한 설정
10. 포팅 결과 검증

**성공 출력**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ SuperClaude → Droid 포팅 완료
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 생성된 디렉토리:
  • ~/.factory/commands/sc/
  • ~/.factory/superclaude/modes/
  • ~/.factory/superclaude/framework/
  • ~/.factory/superclaude/mcp/

📝 복사된 파일:
  • 슬래시 명령어: 26개
  • 모드 파일: 7개
  • 프레임워크: 6개
  • MCP 문서: 7개

💾 백업 위치: ~/.factory-backup-20251025-143000

📋 다음 단계:
  1. MCP 서버 설정: ~/.factory/mcp.json 생성
  2. AGENTS.md 생성: ~/.factory/AGENTS.md
  3. API 키 설정: context7, tavily 환경 변수
  4. Droid 재시작: pkill droid && droid
  5. 명령어 테스트: /sc-help

📄 로그 파일: migration-20251025-143000.log
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### 4단계: 결과 확인

#### 디렉토리 구조 확인

```bash
# 생성된 디렉토리 확인
tree ~/.factory -L 3

# tree 명령어가 없다면:
find ~/.factory -type d | head -20
```

**예상 구조**:
```
~/.factory/
├── commands/
│   └── sc/
│       ├── sc-analyze.md
│       ├── sc-brainstorm.md
│       ├── sc-build.md
│       ├── sc-cleanup.md
│       ├── sc-design.md
│       ├── sc-document.md
│       ├── sc-estimate.md
│       ├── sc-explain.md
│       ├── sc-git.md
│       ├── sc-help.md
│       ├── sc-implement.md
│       ├── sc-improve.md
│       ├── sc-index.md
│       ├── sc-load.md
│       ├── sc-pm.md
│       ├── sc-reflect.md
│       ├── sc-research.md
│       ├── sc-save.md
│       ├── sc-select-tool.md
│       ├── sc-spawn.md
│       ├── sc-spec-panel.md
│       ├── sc-task.md
│       ├── sc-test.md
│       ├── sc-troubleshoot.md
│       └── sc-workflow.md
├── superclaude/
│   ├── modes/
│   │   ├── MODE_Brainstorming.md
│   │   ├── MODE_Business_Panel.md
│   │   ├── MODE_DeepResearch.md
│   │   ├── MODE_Introspection.md
│   │   ├── MODE_Orchestration.md
│   │   ├── MODE_Task_Management.md
│   │   └── MODE_Token_Efficiency.md
│   ├── framework/
│   │   ├── BUSINESS_PANEL_EXAMPLES.md
│   │   ├── BUSINESS_SYMBOLS.md
│   │   ├── FLAGS.md
│   │   ├── PRINCIPLES.md
│   │   ├── RESEARCH_CONFIG.md
│   │   └── RULES.md
│   └── mcp/
│       ├── MCP_Context7.md
│       ├── MCP_Magic.md
│       ├── MCP_Morphllm.md
│       ├── MCP_Playwright.md
│       ├── MCP_Sequential.md
│       ├── MCP_Serena.md
│       └── MCP_Tavily.md
```

#### 파일 개수 확인

```bash
# 슬래시 명령어 개수
ls ~/.factory/commands/sc/*.md | wc -l
# 출력: 26

# 모드 파일 개수
ls ~/.factory/superclaude/modes/*.md | wc -l
# 출력: 7

# 프레임워크 문서 개수
ls ~/.factory/superclaude/framework/*.md | wc -l
# 출력: 6

# MCP 문서 개수
ls ~/.factory/superclaude/mcp/*.md | wc -l
# 출력: 7
```

#### 텍스트 치환 확인

```bash
# "Claude Code" 문자열이 남아있는지 확인 (0이어야 함)
grep -r "Claude Code" ~/.factory/commands/sc/ | wc -l
# 출력: 0

# "Droid CLI" 문자열이 있는지 확인 (>0이어야 함)
grep -r "Droid CLI" ~/.factory/commands/sc/ | wc -l
# 출력: 52 (예시)
```

**체크리스트**:
- [ ] migrate-to-droid.sh 실행 성공
- [ ] 26개 슬래시 명령어 파일 생성 확인
- [ ] 7개 모드 파일 복사 확인
- [ ] 6개 프레임워크 문서 복사 확인
- [ ] 7개 MCP 문서 복사 확인
- [ ] 텍스트 치환 완료 ("Claude Code" → "Droid CLI")
- [ ] 백업 디렉토리 생성 확인

---

## MCP 서버 설정

### MCP (Model Context Protocol)란?

MCP는 AI 에이전트가 외부 도구와 통합하기 위한 프로토콜입니다. SuperClaude Framework는 8개의 강력한 MCP 서버를 사용합니다.

---

### 1단계: mcp.json 파일 복사

```bash
# factory-mcp.json을 ~/.factory/mcp.json으로 복사
cp ~/SuperClaude_Framework/factory-mcp.json ~/.factory/mcp.json

# 권한 설정 (보안을 위해 600 권장)
chmod 600 ~/.factory/mcp.json
```

---

### 2단계: MCP 서버 설정 확인

`~/.factory/mcp.json` 파일 내용:

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

---

### 3단계: 8개 MCP 서버 설명

| MCP 서버 | 패키지 | 기능 | API 키 필요 |
|----------|--------|------|-------------|
| **sequential-thinking** | @modelcontextprotocol/server-sequential-thinking | 다단계 추론 및 체계적 분석 | ❌ |
| **context7** | @upstash/context7-mcp | 라이브러리 공식 문서 검색 | ✅ |
| **magic** | @21st-dev/magic | UI 컴포넌트 자동 생성 | ❌ |
| **playwright** | @executeautomation/playwright-mcp-server | 브라우저 자동화 및 테스트 | ❌ |
| **serena** | @serenaai/mcp-server | 시맨틱 코드 이해 및 세션 관리 | ❌ |
| **tavily** | @tavily/mcp-server | 웹 검색 및 최신 정보 수집 | ✅ |
| **chrome-devtools** | @modelcontextprotocol/server-chrome-devtools | Chrome DevTools 통합 | ❌ |
| **morphllm** | @morphllm/mcp-server | 패턴 기반 코드 일괄 편집 | ❌ |

---

### 4단계: MCP 서버 설치 확인

MCP 서버는 `npx -y` 명령어를 통해 자동으로 설치됩니다. Node.js 18+ 버전이 설치되어 있으면 됩니다.

```bash
# Node.js 버전 확인
node --version

# 출력: v20.11.0 (18 이상이면 OK)
```

**체크리스트**:
- [ ] mcp.json 파일 복사 완료
- [ ] 파일 권한 600 설정 완료
- [ ] Node.js 18+ 버전 확인
- [ ] 8개 MCP 서버 설정 확인

---

## API 키 설정

2개의 MCP 서버가 API 키를 필요로 합니다:

### Context7 (Upstash Redis)

**용도**: 공식 라이브러리 문서 검색 (React, Vue, Next.js 등)

#### 1단계: Upstash 계정 생성

```bash
# 브라우저에서 접속
open https://upstash.com/
```

또는 직접 방문: https://upstash.com/

1. **Sign Up** 클릭
2. GitHub 또는 Google 계정으로 가입
3. 무료 티어 선택 (Free Plan)

#### 2단계: Redis 데이터베이스 생성

1. 대시보드에서 **Create Database** 클릭
2. 데이터베이스 이름 입력 (예: `context7-db`)
3. 리전 선택 (가까운 지역, 예: `ap-northeast-1` for 한국)
4. **Create** 클릭

#### 3단계: API 키 복사

1. 생성된 데이터베이스 클릭
2. **REST API** 탭 선택
3. 다음 값을 복사:
   - **UPSTASH_REDIS_REST_URL**: `https://xxx.upstash.io`
   - **UPSTASH_REDIS_REST_TOKEN**: `AxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxA`

#### 4단계: mcp.json에 키 입력

```bash
# mcp.json 파일 편집
nano ~/.factory/mcp.json
# 또는
vi ~/.factory/mcp.json
# 또는
code ~/.factory/mcp.json
```

`context7` 섹션을 다음과 같이 수정:

```json
"context7": {
  "command": "npx",
  "args": ["-y", "@upstash/context7-mcp"],
  "env": {
    "UPSTASH_REDIS_REST_URL": "https://xxx.upstash.io",
    "UPSTASH_REDIS_REST_TOKEN": "AxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxA"
  },
  "disabled": false
}
```

⚠️ **주의**: 따옴표 안에 값을 입력하고, 공백이나 줄바꿈이 없도록 주의하세요.

---

### Tavily (웹 검색)

**용도**: 실시간 웹 검색, 최신 정보 수집

#### 1단계: Tavily 계정 생성

```bash
# 브라우저에서 접속
open https://tavily.com/
```

또는 직접 방문: https://tavily.com/

1. **Sign Up** 클릭
2. 이메일 또는 GitHub 계정으로 가입
3. 무료 티어 선택 (1,000 검색/월)

#### 2단계: API 키 발급

1. 대시보드에서 **API Keys** 섹션으로 이동
2. **Create New Key** 클릭
3. API 키 복사 (예: `tvly-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`)

#### 3단계: mcp.json에 키 입력

`tavily` 섹션을 다음과 같이 수정:

```json
"tavily": {
  "command": "npx",
  "args": ["-y", "@tavily/mcp-server"],
  "env": {
    "TAVILY_API_KEY": "tvly-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  },
  "disabled": false
}
```

---

### API 키 없이 사용하기 (선택사항)

API 키를 아직 설정하지 않았다면, 해당 MCP 서버를 일시적으로 비활성화할 수 있습니다:

```json
"context7": {
  ...
  "disabled": true
},
"tavily": {
  ...
  "disabled": true
}
```

⚠️ **참고**: Context7과 Tavily를 비활성화하면 공식 문서 검색과 웹 검색 기능을 사용할 수 없습니다.

**체크리스트**:
- [ ] Upstash 계정 생성 완료
- [ ] Upstash Redis 데이터베이스 생성
- [ ] UPSTASH_REDIS_REST_URL 복사 및 입력
- [ ] UPSTASH_REDIS_REST_TOKEN 복사 및 입력
- [ ] Tavily 계정 생성 완료
- [ ] TAVILY_API_KEY 복사 및 입력
- [ ] mcp.json 파일 저장 및 닫기

---

## 검증 및 테스트

### 1단계: Droid 재시작

```bash
# 실행 중인 Droid 종료
pkill droid

# 프로젝트 디렉토리로 이동
cd ~/your-project

# Droid 시작
droid
```

---

### 2단계: 명령어 목록 확인

Droid CLI 내에서:

```
/commands
```

**예상 출력**:
```
Available commands:
  /sc-analyze
  /sc-brainstorm
  /sc-build
  /sc-cleanup
  /sc-design
  /sc-document
  ...
  (26개 /sc- 명령어 표시)
```

✅ **확인**: `sc-` 디렉토리 또는 26개의 `/sc-` 명령어가 표시되어야 합니다.

---

### 3단계: 기본 테스트 - /sc-help

```
/sc-help
```

**예상 출력**:
```
✅ **SC-FRAMEWORK**: sc-help | Droid-v2.0

## Available SuperClaude Commands

Here is a complete list of all available SuperClaude (`/sc-`) commands for Droid CLI.

| Command | Description |
|---|---|
| `/sc-analyze` | Comprehensive code analysis... |
| `/sc-brainstorm` | Interactive requirements discovery... |
...
```

✅ **확인**:
- `✅ **SC-FRAMEWORK**: sc-help | Droid-v2.0` 메시지 출력
- 26개 명령어 목록 표시
- 플래그 시스템 설명 포함

---

### 4단계: 디렉토리 분석 테스트

```
/sc-analyze src/
```

**예상 동작**:
1. `src/` 디렉토리의 파일 목록 탐색
2. 코드 분석 수행 (보안, 성능, 아키텍처)
3. 상세 분석 리포트 생성
4. 점수 및 권장사항 제시

**성공 지표**:
- ✅ `LIST DIRECTORY (src)` 또는 `GLOB` 도구 사용
- ✅ 파일들이 정확히 발견됨
- ✅ 분석 리포트 생성 (Security Score, Performance 등)
- ✅ 즉시 실행 가능한 개선 권장사항 제시

---

### 5단계: 전체 프로젝트 분석 테스트

```
/sc-analyze .
```

**예상 동작**:
1. 현재 디렉토리 (전체 프로젝트) 분석
2. 백엔드/프론트엔드 모두 분석
3. 종합 품질 점수 산출
4. 배포 준비 상태 평가

**성공 지표**:
- ✅ 수백 개 파일 발견 및 분석
- ✅ 전체 시스템 아키텍처 분석
- ✅ 종합 등급 (A-F) 또는 점수 (0-100) 표시

---

### 6단계: 파일 분석 테스트

```
/sc-analyze package.json
```

**예상 동작**:
1. `package.json` 파일 읽기
2. 파일 내용이 minimal할 경우 자동 확장 분석
3. 전체 프로젝트 컨텍스트 분석

**성공 지표**:
- ✅ `READ (package.json)` 도구 사용
- ✅ 파일 내용 읽기 성공
- ✅ 기술 스택 분석 또는 확장 분석 수행

---

### 7단계: MCP 서버 연결 확인

MCP 서버가 정상 작동하는지 확인:

```
/sc-analyze . --seq --think-hard
```

**플래그 설명**:
- `--seq`: Sequential Thinking MCP 활성화
- `--think-hard`: 심층 분석 모드

**성공 지표**:
- ✅ Sequential Thinking MCP 사용 (구조화된 분석 단계)
- ✅ 더 상세한 분석 결과 생성
- ✅ MCP 서버 연결 오류 없음

---

### 트러블슈팅이 필요한 경우

위의 테스트 중 하나라도 실패하면 [트러블슈팅](#트러블슈팅) 섹션을 참조하세요.

**체크리스트**:
- [ ] Droid 재시작 완료
- [ ] /commands로 26개 /sc- 명령어 확인
- [ ] /sc-help 실행 성공 (Framework verification 메시지 출력)
- [ ] /sc-analyze src/ 디렉토리 분석 성공
- [ ] /sc-analyze . 전체 프로젝트 분석 성공
- [ ] /sc-analyze package.json 파일 분석 성공
- [ ] --seq 플래그로 MCP 서버 연결 확인

---

## 트러블슈팅

### 문제 1: 명령어가 인식되지 않음

**증상**:
```
/sc-help
Unknown command: /sc-help
```

**원인**:
- 명령어 파일이 제대로 복사되지 않음
- Droid가 명령어를 아직 인식하지 못함

**해결 방법**:

#### 1.1 Droid 재시작

```bash
# Droid 종료
pkill droid

# Droid 재시작
droid
```

#### 1.2 명령어 파일 존재 확인

```bash
# 명령어 파일 확인
ls ~/.factory/commands/sc/

# 26개 .md 파일이 있어야 함
```

파일이 없다면:
```bash
# migrate-to-droid.sh 재실행
cd ~/SuperClaude_Framework
./migrate-to-droid.sh
```

#### 1.3 파일 권한 확인

```bash
# 권한 확인
ls -la ~/.factory/commands/sc/*.md

# 출력 예시: -rw-r--r-- (644 권한)
```

권한이 잘못되었다면:
```bash
# 권한 수정
chmod 644 ~/.factory/commands/sc/*.md
```

---

### 문제 2: MCP 서버 연결 실패

**증상**:
```
Error: Failed to connect to MCP server 'sequential-thinking'
```

**원인**:
- Node.js 미설치 또는 버전 낮음
- npx 명령어 미작동
- mcp.json 문법 오류

**해결 방법**:

#### 2.1 Node.js 버전 확인

```bash
node --version

# 18 이상이어야 함
```

18 미만이라면:
```bash
# nvm으로 업그레이드
nvm install 20
nvm use 20

# 또는 시스템 패키지로 업그레이드
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

#### 2.2 npx 작동 확인

```bash
# npx 버전 확인
npx --version

# 출력: 10.x.x
```

#### 2.3 mcp.json 문법 검증

```bash
# JSON 문법 검증
cat ~/.factory/mcp.json | jq .

# 오류가 있다면 수정
nano ~/.factory/mcp.json
```

일반적인 JSON 오류:
- 마지막 항목 뒤의 쉼표 (,)
- 따옴표 누락
- 중괄호 {} 불균형

---

### 문제 3: API 키 오류

**증상**:
```
Error: UPSTASH_REDIS_REST_URL is not set
Error: Invalid TAVILY_API_KEY
```

**원인**:
- API 키가 입력되지 않음
- API 키 값에 공백/줄바꿈 포함
- API 키가 유효하지 않음

**해결 방법**:

#### 3.1 API 키 값 확인

```bash
# mcp.json에서 API 키 확인
cat ~/.factory/mcp.json | grep -A2 "env"
```

**올바른 형식**:
```json
"env": {
  "UPSTASH_REDIS_REST_URL": "https://xxx.upstash.io",
  "UPSTASH_REDIS_REST_TOKEN": "AxxxxxxxxxxxA"
}
```

**잘못된 형식**:
```json
"env": {
  "UPSTASH_REDIS_REST_URL": "",  ← 빈 문자열
  "UPSTASH_REDIS_REST_TOKEN": "Axxx
  xxxA"  ← 줄바꿈 포함
}
```

#### 3.2 API 키 재입력

```bash
# mcp.json 편집
nano ~/.factory/mcp.json
```

1. 따옴표 안에 API 키 붙여넣기
2. 공백/줄바꿈 제거
3. 저장 후 Droid 재시작

#### 3.3 API 키 유효성 확인

**Upstash**:
```bash
# REST API 테스트
curl https://YOUR_UPSTASH_URL \
  -H "Authorization: Bearer YOUR_TOKEN"

# 200 OK 응답이 와야 함
```

**Tavily**:
```bash
# API 키 테스트
curl -X POST https://api.tavily.com/search \
  -H "Content-Type: application/json" \
  -d '{"api_key":"YOUR_KEY","query":"test"}'

# 검색 결과가 반환되어야 함
```

---

### 문제 4: $ARGUMENTS 파싱 문제

**증상**:
```
/sc-analyze TEST_TOKEN
→ "TEST_TOKEN이 비어 있어서..."
```

**원인**:
- `TEST_TOKEN`은 존재하지 않는 파일/디렉토리
- $ARGUMENTS 파싱은 정상이나, 파일을 찾을 수 없음

**해결 방법**:

#### 4.1 실제 파일/디렉토리 사용

```
# ❌ 잘못된 사용
/sc-analyze TEST_TOKEN
/sc-analyze DUMMY_VALUE

# ✅ 올바른 사용
/sc-analyze src/
/sc-analyze package.json
/sc-analyze .
```

#### 4.2 파일 존재 확인

```bash
# 분석할 파일/디렉토리 확인
ls -la src/
ls -la package.json
```

---

### 문제 5: Framework Verification 메시지 없음

**증상**:
```
/sc-help
→ 도움말은 표시되지만 "✅ **SC-FRAMEWORK**" 메시지 없음
```

**원인**:
- 텍스트 치환이 완전하지 않음
- 중간 티어 명령어가 변환되지 않음

**해결 방법**:

#### 5.1 파일 내용 확인

```bash
# sc-help.md 파일 내용 확인
cat ~/.factory/commands/sc/sc-help.md | head -20

# "Droid-v2.0" 문자열이 있어야 함
```

#### 5.2 수동 수정

파일에 "Droid-v2.0" 문자열이 없다면:

```bash
# sc-help.md 편집
nano ~/.factory/commands/sc/sc-help.md

# 다음 라인 추가 (8번째 줄 근처):
✅ **SC-FRAMEWORK**: sc-help | Droid-v2.0
```

#### 5.3 전체 명령어 재변환

```bash
cd ~/SuperClaude_Framework
./migrate-to-droid.sh
```

---

### 문제 6: 권한 거부 오류

**증상**:
```bash
./migrate-to-droid.sh
bash: ./migrate-to-droid.sh: Permission denied
```

**해결 방법**:

```bash
# 실행 권한 부여
chmod +x migrate-to-droid.sh

# 재실행
./migrate-to-droid.sh
```

---

### 문제 7: Droid가 시작되지 않음

**증상**:
```bash
droid
-bash: droid: command not found
```

**해결 방법**:

#### 7.1 PATH 확인

```bash
echo $PATH | grep ".local/bin"
```

`.local/bin`이 없다면:

```bash
# PATH에 추가
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 또는 zsh 사용자
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### 7.2 Droid 재설치

```bash
curl -fsSL https://app.factory.ai/cli | sh
```

---

### 추가 도움말

위의 해결 방법으로 해결되지 않는 경우:

1. **로그 파일 확인**:
   ```bash
   cat ~/SuperClaude_Framework/migration-*.log
   ```

2. **GitHub Issues 검색**:
   - SuperClaude Framework Issues
   - Droid CLI Issues

3. **커뮤니티 지원**:
   - Droid CLI Discord
   - Factory.ai 포럼

---

## 추가 설정 (선택사항)

### AGENTS.md 생성

`AGENTS.md`는 SuperClaude Framework의 모든 설정을 하나의 통합 파일로 제공합니다.

#### 자동 생성 (권장)

Droid CLI에서:

```
/sc-implement "Droid CLI용 통합 AGENTS.md 파일(~/.factory/AGENTS.md) 생성: SuperClaude 프레임워크 전체를 하나의 통합 파일로 병합, 다음 내용 포함 - (1) 핵심 원칙(PRINCIPLES.md 요약), (2) 주요 행동 규칙(RULES.md 핵심 사항), (3) MCP 서버 통합 가이드(8개 서버 설명 및 사용법), (4) 슬래시 명령어 목록(26개 명령어 설명), (5) 행동 모드 시스템(7개 모드 트리거 및 효과), (6) 플래그 시스템(--think, --seq, --magic 등), (7) 사용 예시, Markdown 형식, Droid 최적화, 한국어 작성, 150줄 이하로 간결하게" --persona-scribe=ko --comprehensive
```

#### 수동 생성

기존 프레임워크 문서를 참조하여 직접 작성:

```bash
# 편집기로 생성
nano ~/.factory/AGENTS.md
```

**포함할 내용**:
1. 핵심 원칙 (PRINCIPLES.md 요약)
2. 주요 규칙 (RULES.md 핵심)
3. MCP 서버 가이드
4. 슬래시 명령어 목록
5. 행동 모드 시스템
6. 플래그 시스템
7. 사용 예시

**권장 길이**: 150줄 이하

---

### 커스터마이징

#### 특정 MCP 서버 비활성화

사용하지 않는 MCP 서버 비활성화:

```bash
# mcp.json 편집
nano ~/.factory/mcp.json
```

```json
"morphllm": {
  "command": "npx",
  "args": ["-y", "@morphllm/mcp-server"],
  "disabled": true  ← false → true로 변경
}
```

#### 명령어 프리픽스 변경

현재: `/sc-analyze`, `/sc-help` 등
변경 원하는 경우: `/sc:analyze`, `/sc:help` 등

⚠️ **주의**: Droid CLI의 슬러그화 규칙에 따라 `:` 문자는 제거될 수 있습니다.

**심볼릭 링크 방식** (복잡, 비권장):
```bash
cd ~/.factory/commands/
ln -s sc-analyze.md "sc:analyze.md"
ln -s sc-help.md "sc:help.md"
# ... 26개 모두
```

**권장**: 현재 `/sc-` 프리픽스 유지 (완벽하게 작동)

---

### 업데이트 방법

SuperClaude Framework 업데이트 시:

```bash
# 1. SuperClaude Framework 업데이트
cd ~/SuperClaude_Framework
git pull origin main

# 2. 백업 생성
cp -r ~/.factory ~/.factory-backup-manual

# 3. 재마이그레이션
./migrate-to-droid.sh

# 4. mcp.json 복사
cp factory-mcp.json ~/.factory/mcp.json

# 5. API 키 재입력 (필요 시)
nano ~/.factory/mcp.json

# 6. Droid 재시작
pkill droid && droid
```

---

## 참고자료

### 프로젝트 문서

- **TODO_MigDroid.md**: 전체 마이그레이션 TODO 및 진행 상황
- **Analyze_Droid.md**: Droid CLI 아키텍처 분석
- **Migration_Workflow.md**: 마이그레이션 워크플로우
- **scUsage.md**: SuperClaude 명령어 사용 가이드

### 외부 리소스

#### Droid CLI

- 공식 사이트: https://factory.ai/
- 설치 가이드: https://app.factory.ai/cli
- Discord 커뮤니티: (링크 필요 시 추가)

#### MCP 서버

- MCP 프로토콜: https://modelcontextprotocol.io/
- Sequential Thinking: https://github.com/modelcontextprotocol/servers
- Context7: https://github.com/upstash/context7-mcp
- Magic: https://21st.dev/
- Playwright: https://playwright.dev/
- Tavily: https://tavily.com/

#### API 키

- Upstash: https://upstash.com/
- Tavily: https://tavily.com/

---

## 완료 체크리스트

### 필수 단계

- [ ] 시스템 요구사항 충족 (Bash 4.0+, Node.js 18+)
- [ ] Droid CLI 설치 완료
- [ ] SuperClaude Framework 다운로드
- [ ] migrate-to-droid.sh 실행 성공
- [ ] 26개 슬래시 명령어 생성 확인
- [ ] mcp.json 파일 복사 완료
- [ ] Context7 API 키 설정 (선택)
- [ ] Tavily API 키 설정 (선택)
- [ ] Droid 재시작
- [ ] /sc-help 테스트 성공
- [ ] /sc-analyze 테스트 성공

### 선택 단계

- [ ] AGENTS.md 생성
- [ ] 모든 MCP 서버 활성화
- [ ] 커스터마이징 적용

---

## 🎉 축하합니다!

SuperClaude Framework를 Droid CLI로 성공적으로 포팅했습니다!

이제 다음 명령어들을 사용할 수 있습니다:

```
/sc-analyze     - 코드 분석
/sc-design      - 시스템 설계
/sc-implement   - 기능 구현
/sc-test        - 테스트 실행
/sc-help        - 전체 명령어 목록
... 그 외 22개 명령어
```

**다음 단계**:
1. [Droid_Quick_Start.md](./Droid_Quick_Start.md)로 빠른 참조
2. 실제 프로젝트에서 /sc- 명령어 사용해보기
3. 피드백 및 개선사항 공유

**Happy Coding with SuperClaude + Droid! 🚀**
