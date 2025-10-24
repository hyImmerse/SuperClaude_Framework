# Droid CLI 분석 보고서

## 개요

Droid CLI는 Factory.ai가 개발한 독립 실행형 CLI 기반 AI 코딩 에이전트입니다. Claude Code와 유사한 기능을 제공하면서도 독자적인 아키텍처와 설정 시스템을 갖추고 있습니다. 본 문서는 Droid CLI의 전체 구조를 분석하고, SuperClaude_Framework를 Droid로 포팅하기 위한 상세한 가이드를 제공합니다.

## 설치 프로세스 상세 분석

### 1단계: 설치 스크립트 다운로드 및 실행

```bash
# macOS/Linux
curl -fsSL https://app.factory.ai/cli | sh

# Windows
irm https://app.factory.ai/cli/windows | iex
```

### 설치 스크립트 동작 원리

설치 스크립트(`https://app.factory.ai/cli`)는 Shell 인스톨러로서 다음 작업을 수행합니다:

#### 1.1 환경 검증 및 준비
- **curl 설치 확인**: 다운로드 도구 존재 여부 검증
- **임시 디렉토리 생성**: 다운로드용 임시 공간 확보
- **컬러 출력 함수 설정**: info, warn, error 메시지 시각화

#### 1.2 플랫폼 및 아키텍처 감지
- **운영체제 식별**:
  * Darwin (macOS)
  * Linux
  * Windows (별도 스크립트)
- **CPU 아키텍처 감지**:
  * x64 (Intel/AMD)
  * arm64 (Apple Silicon, ARM)
- **지원하지 않는 시스템**: 자동 종료 및 오류 메시지 출력

#### 1.3 바이너리 다운로드
- **Droid CLI**: v0.22.2 버전
  * 다운로드 URL: `https://downloads.factory.ai/droid-{os}-{arch}-v0.22.2`
  * 플랫폼별 바이너리 자동 선택
- **Ripgrep**: 코드 검색 도구
  * Droid의 핵심 의존성
  * 플랫폼별 최적화된 버전 다운로드

#### 1.4 보안 검증
- **SHA256 체크섬 검증**:
  * 다운로드된 바이너리의 무결성 확인
  * 변조 방지 보안 메커니즘
  * 체크섬 도구 부재 시 경고만 출력 (설치 계속)

#### 1.5 설치 디렉토리 생성

스크립트는 다음 디렉토리를 생성합니다:

```bash
$HOME/.local/bin/          # Droid 실행 파일
$HOME/.factory/bin/        # Ripgrep 바이너리
```

#### 1.6 바이너리 설치
- **Droid 설치**: `~/.local/bin/droid`로 복사
- **Ripgrep 설치**: `~/.factory/bin/rg`로 복사
- **실행 권한 부여**: `chmod +x` 적용
- **기존 프로세스 종료**: `pkill droid`로 실행 중인 Droid 종료

#### 1.7 PATH 환경변수 설정

스크립트는 `~/.local/bin`이 PATH에 포함되었는지 확인하고, 없으면 다음 지침을 제공합니다:

```bash
# zsh 사용자
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# bash 사용자
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# sh 사용자
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
```

### Linux 특수 요구사항

Linux 사용자는 추가로 `xdg-utils` 패키지가 필요합니다:

```bash
# Ubuntu/Debian
sudo apt install xdg-utils

# Fedora/RHEL
sudo dnf install xdg-utils

# Arch Linux
sudo pacman -S xdg-utils
```

### 설치 후 초기 실행

설치 완료 후 프로젝트 디렉토리로 이동하여 Droid를 시작합니다:

```bash
cd your-project
droid
```

첫 실행 시 Droid는 자동으로 설정 파일을 생성하고 초기화를 수행합니다.

## Droid 디렉토리 구조 전체 매핑

### 전역 설정 디렉토리 (~/.factory/)

```
~/.factory/
├── settings.json          # CLI 전역 설정 파일
├── mcp.json              # MCP 서버 설정 파일 ⭐
├── bin/                  # 의존성 바이너리 디렉토리
│   └── rg               # Ripgrep 실행 파일
├── commands/             # 개인 슬래시 명령어 디렉토리
│   ├── example.md       # Markdown 명령어 예시
│   └── script.sh        # 실행 파일 명령어 예시
├── docs/                # Spec 모드 출력 디렉토리
│   └── specifications/  # 자동 생성된 스펙 문서
└── AGENTS.md           # 전역 프로젝트 설정 (선택적)
```

### Droid 실행 파일 위치

```
~/.local/bin/
└── droid                # 메인 CLI 실행 파일
```

### 프로젝트별 설정 디렉토리 (<project>/.factory/)

```
<project-root>/
└── .factory/
    ├── commands/         # 프로젝트별 슬래시 명령어
    │   ├── build.md     # 빌드 명령어
    │   └── deploy.md    # 배포 명령어
    ├── docs/            # 프로젝트 문서
    │   └── specs/       # 스펙 문서
    └── AGENTS.md        # 프로젝트별 AI 설정 및 규칙
```

### 설정 파일 우선순위

1. **프로젝트 설정**: `<project>/.factory/` (최우선)
2. **전역 설정**: `~/.factory/` (기본값)
3. **명령어 오버라이드**: 프로젝트 명령어가 전역 명령어보다 우선

## 슬래시 명령어 시스템 상세 분석

### 명령어 발견 메커니즘

Droid는 다음 위치에서 슬래시 명령어를 자동으로 검색합니다:

1. **개인 명령어**: `~/.factory/commands/`
2. **프로젝트 명령어**: `<repo>/.factory/commands/`
3. **우선순위**: 프로젝트 명령어가 동일한 이름의 개인 명령어를 오버라이드

### 지원 파일 형식

#### 1. Markdown 명령어 (.md, .mdx)

**기본 구조:**

```markdown
---
description: 명령어에 대한 간단한 설명
argument-hint: <사용법 힌트>
allowed-tools: [향후 사용 예정]
---

명령어를 실행할 때 AI에게 전달될 프롬프트 내용입니다.

$ARGUMENTS 변수를 사용하면 사용자가 입력한 인자를 받을 수 있습니다.
```

**YAML Frontmatter 필드:**

| 필드 | 필수 여부 | 설명 | 예시 |
|------|-----------|------|------|
| `description` | 선택 | 명령어 설명 오버라이드 | `"코드 품질 분석 수행"` |
| `argument-hint` | 선택 | 사용법 힌트 | `<file-path>` 또는 `[options]` |
| `allowed-tools` | 선택 | 향후 사용 예정 | `["read", "write"]` |

**예시:**

```markdown
---
description: 프로젝트 전체 코드 분석
argument-hint: [target-directory]
---

다음 작업을 수행하세요:
1. $ARGUMENTS 디렉토리의 코드 품질 분석
2. 보안 취약점 스캔
3. 성능 최적화 기회 식별
4. 종합 보고서 생성

분석 후 개선 사항을 우선순위별로 정리해주세요.
```

#### 2. 실행 파일 명령어 (Shebang)

**요구사항:**
- 파일 첫 줄에 shebang (`#!`) 필수
- 실행 권한 필요: `chmod +x command-name`

**예시:**

```bash
#!/usr/bin/env bash
# Git 상태 확인 및 보고

echo "=== Git Status Report ==="
git status
echo ""
echo "=== Recent Commits ==="
git log --oneline -5
echo ""
echo "=== Branch Information ==="
git branch -v
```

**Python 스크립트 예시:**

```python
#!/usr/bin/env python3
# 프로젝트 의존성 분석

import json
import sys

def analyze_dependencies():
    with open('package.json', 'r') as f:
        data = json.load(f)

    deps = data.get('dependencies', {})
    print(f"총 의존성: {len(deps)}개")

    for name, version in deps.items():
        print(f"  - {name}: {version}")

if __name__ == "__main__":
    analyze_dependencies()
```

### 명령어 호출 방법

```bash
# Droid CLI 내에서
/command-name [인자1] [인자2] ...

# 예시
/analyze src/
/build production
/deploy --staging
```

### 명령어 실행 흐름

1. **사용자 입력**: `/command-name args`
2. **파일 검색**: `.factory/commands/` 디렉토리에서 매칭
3. **타입 감지**: Markdown vs 실행 파일
4. **변수 치환**: `$ARGUMENTS` 변수를 실제 인자로 치환
5. **실행**:
   - Markdown: 프롬프트를 AI에게 전달
   - 실행 파일: 스크립트 실행 → stdout/stderr 캡처 (최대 64KB)
6. **결과 반환**: 채팅에 출력 표시

### 명령어 관리

```bash
# Droid CLI 내에서
/commands              # 명령어 관리자 열기
```

**명령어 관리자 기능:**
- 사용 가능한 모든 명령어 목록 표시
- 명령어 새로고침 (파일 변경 후)
- 기존 명령어 예시 가져오기

### 파일 이름 슬러그 규칙

파일 이름은 다음 규칙으로 슬러그화됩니다:

- **소문자 변환**: `MyCommand.md` → `mycommand`
- **공백 → 하이픈**: `my command.md` → `my-command`
- **URL 안전 문자만**: 특수문자 제거
- **예시**:
  * `Build Project.md` → `build-project`
  * `deploy_to_prod.sh` → `deploy_to_prod`
  * `Test & Deploy.md` → `test-deploy`

## MCP 통합 방식 상세 분석

### MCP 설정 파일: ~/.factory/mcp.json

**중요 발견**: Droid의 MCP 설정은 `~/.factory/mcp.json` 파일에 저장됩니다. 이는 문서에 명시되지 않았지만 실제 구현에서 사용되는 파일입니다.

### mcp.json 구조

```json
{
  "mcpServers": {
    "서버이름": {
      "command": "실행 명령어",
      "args": ["인자1", "인자2", "..."],
      "env": {
        "환경변수명": "값"
      },
      "disabled": false
    }
  }
}
```

### 필드 설명

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `command` | string | ✅ | MCP 서버 실행 명령어 (예: `npx`, `node`, `python`) |
| `args` | array | ✅ | 명령어 인자 배열 |
| `env` | object | ❌ | 환경 변수 (API 키 등) |
| `disabled` | boolean | ❌ | 서버 비활성화 플래그 (기본값: `false`) |

### MCP 서버 타입

#### 1. Stdio 서버 (로컬 프로세스)

표준 입출력을 통해 통신하는 로컬 프로세스입니다.

**예시:**

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "disabled": false
    }
  }
}
```

#### 2. HTTP 서버 (원격 엔드포인트)

HTTP/HTTPS URL을 통해 통신하는 원격 서버입니다.

**예시 (문서 기반, 실제 형식은 확인 필요):**

```json
{
  "mcpServers": {
    "remote-api": {
      "type": "http",
      "url": "https://api.example.com/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_TOKEN"
      },
      "disabled": false
    }
  }
}
```

### MCP 관리 CLI 명령어

Droid는 mcp.json을 직접 편집하는 것 외에도 CLI 명령어를 제공합니다:

```bash
# Droid CLI 내에서
/mcp add <server-name>      # 새 MCP 서버 추가
/mcp remove <server-name>   # MCP 서버 제거
/mcp enable <server-name>   # MCP 서버 활성화
/mcp disable <server-name>  # MCP 서버 비활성화
/mcp list                   # 설치된 MCP 서버 목록 표시
```

### MCP 서버 설정 예시 모음

#### Sequential Thinking

```json
{
  "sequential-thinking": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
  }
}
```

#### Context7 (문서 검색)

```json
{
  "context7": {
    "command": "npx",
    "args": ["-y", "@upstash/context7-mcp"],
    "env": {
      "UPSTASH_REDIS_REST_URL": "https://your-redis-url.upstash.io",
      "UPSTASH_REDIS_REST_TOKEN": "your-redis-token"
    }
  }
}
```

#### Magic (UI 컴포넌트 생성)

```json
{
  "magic": {
    "command": "npx",
    "args": ["-y", "@21st-dev/magic"]
  }
}
```

#### Playwright (브라우저 자동화)

```json
{
  "playwright": {
    "command": "npx",
    "args": ["-y", "@executeautomation/playwright-mcp-server"]
  }
}
```

#### Tavily (웹 검색)

```json
{
  "tavily": {
    "command": "npx",
    "args": ["-y", "@tavily/mcp-server"],
    "env": {
      "TAVILY_API_KEY": "your-tavily-api-key"
    }
  }
}
```

### Windows 특별 고려사항

Windows에서 npx 실행 시 문제가 발생할 수 있습니다. 이 경우 다음과 같이 수정:

```json
{
  "sequential-thinking": {
    "command": "cmd",
    "args": ["/c", "npx", "-y", "@modelcontextprotocol/server-sequential-thinking"]
  }
}
```

## AGENTS.md 시스템 상세 분석

### AGENTS.md란?

AGENTS.md는 Droid가 프로젝트별 규칙, 명령어, 패턴을 학습하기 위한 Markdown 기반 설정 파일입니다. AI 에이전트에게 프로젝트의 컨텍스트를 제공하여 더 정확하고 관련성 높은 지원을 받을 수 있습니다.

### 파일 발견 우선순위

Droid는 다음 순서로 AGENTS.md 파일을 검색합니다:

1. **현재 작업 디렉토리**: `./AGENTS.md`
2. **상위 디렉토리**: 리포지토리 루트까지 재귀적으로 검색
3. **서브폴더**: 에이전트가 작업 중인 하위 디렉토리
4. **개인 오버라이드**: `~/.factory/AGENTS.md`

**우선순위 원칙**: 가장 가까운 AGENTS.md가 우선 적용됩니다.

**여러 파일 병합**: 각 레벨의 AGENTS.md가 모두 컨텍스트에 로드되어 계층적으로 적용됩니다.

### 파일 형식 및 구조

AGENTS.md는 표준 Markdown 문법을 사용하며, 의미론적 힌트를 통해 구조화됩니다:

#### 권장 섹션 구조

```markdown
# 프로젝트 이름

간단한 프로젝트 설명

## Build & Test
정확한 빌드 및 테스트 명령어

## Architecture Overview
모듈 설명 및 데이터 흐름

## Security
API 키, 인증 흐름, 민감 데이터 처리

## Git Workflows
브랜치 전략, 커밋 컨벤션

## Conventions & Patterns
폴더 레이아웃, 네이밍, 코드 스타일
```

#### 마크다운 요소별 의미

| 요소 | 의미 | 예시 |
|------|------|------|
| `#` 제목 | 섹션 구분 | `# Build & Test` |
| 글머리 기호 | 명령어/규칙 리스트 | `- npm run build` |
| 인라인 코드 | 정확한 명령어/파일명 | `` `package.json` `` |
| 코드 블록 | 실행 가능한 명령어 | ` ```bash npm test ``` ` |
| 링크 | 외부 문서 참조 | `[문서](https://...)` |

### AGENTS.md 예시

#### 간단한 예시

```markdown
# MyProject

React + TypeScript 프로젝트

## Build & Test

빌드:
```bash
pnpm install
pnpm build
```

테스트:
```bash
pnpm test
pnpm lint
```

## Architecture

- `/src/components` - React 컴포넌트
- `/src/services` - API 호출 로직
- `/src/utils` - 유틸리티 함수

## Conventions

- 파일명: PascalCase for components, camelCase for utilities
- 스타일: Tailwind CSS 사용
- 상태관리: Zustand
```

#### 상세한 예시

```markdown
# E-Commerce Platform

Next.js 14 기반 전자상거래 플랫폼

## Build & Test

### 개발 환경 실행
```bash
pnpm install
pnpm dev
```

### 프로덕션 빌드
```bash
pnpm build
pnpm start
```

### 테스트 실행
```bash
# 단위 테스트
pnpm test

# E2E 테스트
pnpm test:e2e

# 타입 체크
pnpm typecheck

# 린트
pnpm lint
```

## Architecture Overview

### 디렉토리 구조
- `/app` - Next.js App Router 페이지
- `/components` - 재사용 가능한 React 컴포넌트
  - `/ui` - shadcn/ui 기반 UI 컴포넌트
  - `/features` - 기능별 컴포넌트
- `/lib` - 유틸리티 및 헬퍼 함수
- `/server` - Server Actions
- `/hooks` - Custom React Hooks

### 데이터 흐름
1. 클라이언트 컴포넌트 → Server Action 호출
2. Server Action → Database 쿼리 (Prisma)
3. 결과 → 클라이언트로 반환
4. 클라이언트 → UI 업데이트

## Security

### API 키 관리
- 모든 API 키는 `.env.local`에 저장
- `.env.example`에 필요한 키 목록 문서화
- 절대 코드에 하드코딩하지 않음

### 인증 흐로
- NextAuth.js 사용
- JWT 토큰 기반 세션 관리
- OAuth (Google, GitHub) 지원

## Git Workflows

### 브랜치 전략
- `main` - 프로덕션 코드
- `develop` - 개발 브랜치
- `feature/*` - 새 기능
- `fix/*` - 버그 수정

### 커밋 컨벤션
```
type(scope): subject

feat(auth): Google OAuth 로그인 추가
fix(cart): 결제 금액 계산 오류 수정
docs(readme): 설치 가이드 업데이트
```

### PR 프로세스
1. `develop`에서 feature 브랜치 생성
2. 작업 완료 후 PR 생성
3. 코드 리뷰 후 머지
4. 브랜치 삭제

## Conventions & Patterns

### 파일 네이밍
- 컴포넌트: PascalCase (`UserProfile.tsx`)
- 유틸리티: camelCase (`formatDate.ts`)
- 훅: camelCase with 'use' prefix (`useAuth.ts`)
- 서버 액션: camelCase (`createOrder.ts`)

### 코드 스타일
- ESLint + Prettier 사용
- Tailwind CSS for styling
- TypeScript strict mode 활성화
- 최대 줄 길이: 100자

### 컴포넌트 패턴
```typescript
// 좋은 예시
export function UserProfile({ userId }: { userId: string }) {
  const user = useUser(userId)

  if (!user) return <Skeleton />

  return (
    <div className="flex flex-col gap-4">
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  )
}
```

## Dependencies

### 주요 의존성
- Next.js 14 (App Router)
- React 18
- TypeScript 5
- Tailwind CSS 3
- Prisma (ORM)
- NextAuth.js (인증)
- Zustand (상태관리)

### 새 의존성 추가 시
1. 필요성 검토
2. 번들 사이즈 확인
3. 보안 취약점 검사
4. 팀 승인 후 추가

## External Documentation

- [Next.js 문서](https://nextjs.org/docs)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [Prisma 가이드](https://www.prisma.io/docs)
```

### AI 에이전트의 AGENTS.md 활용 방식

1. **작업 시작 시**: 가장 가까운 AGENTS.md를 컨텍스트 윈도우에 로드
2. **명령어 선택**: Build & Test 섹션에서 정확한 명령어 참조
3. **코드 생성**: Conventions & Patterns에 따라 코드 스타일 적용
4. **아키텍처 이해**: Architecture Overview로 프로젝트 구조 파악
5. **검증**: 생성한 코드가 프로젝트 규칙을 준수하는지 확인

### 베스트 프랙티스

#### ✅ 권장사항

1. **간결성**: 150줄 이하로 유지 (토큰 효율성)
2. **구체성**: 복사-붙여넣기 가능한 명령어 제공
3. **최신성**: 코드 변경 시 함께 업데이트
4. **참조**: 중복 방지를 위해 외부 문서 링크 활용
5. **실용성**: 실제로 사용하는 명령어와 패턴만 기록

#### ❌ 피해야 할 사항

1. **장황함**: 수백 줄의 세부 사항 나열
2. **중복**: 이미 문서화된 내용 반복
3. **추상성**: "좋은 코드를 작성하세요" 같은 모호한 지침
4. **오래된 정보**: 실제 프로젝트와 다른 정보
5. **비밀 정보**: API 키나 비밀번호 포함

## SuperClaude vs Droid 비교 분석

### 아키텍처 비교

| 측면 | SuperClaude (Claude Code 기반) | Droid CLI |
|------|-------------------------------|-----------|
| **기반 시스템** | Claude Code 확장 프레임워크 | 독립 실행형 CLI 애플리케이션 |
| **설치 방법** | Python 패키지 + pip install | Shell 스크립트 → 바이너리 설치 |
| **설정 디렉토리** | `~/.claude/` | `~/.factory/` |
| **실행 파일 위치** | Claude Code 내장 | `~/.local/bin/droid` |
| **프로젝트 설정** | `.claude/` 디렉토리 | `.factory/AGENTS.md` |

### 명령어 시스템 비교

| 항목 | SuperClaude | Droid |
|------|-------------|-------|
| **명령어 위치** | `~/.claude/commands/sc/` | `~/.factory/commands/` |
| **명령어 접두사** | `/sc:` (26개 명령어) | `/` (사용자 정의) |
| **명령어 형식** | Markdown (YAML frontmatter) | Markdown + 실행 파일 |
| **프로젝트 오버라이드** | 지원하지 않음 | `<project>/.factory/commands/` |
| **동적 명령어** | 정적 Markdown만 | Markdown + Shell/Python 스크립트 |

**SuperClaude 명령어 예시:**
- `/sc:analyze` - 코드 분석
- `/sc:implement` - 기능 구현
- `/sc:brainstorm` - 요구사항 탐색
- `/sc:research` - 웹 검색 연구
- `/sc:task` - 작업 관리

### MCP 서버 통합 비교

| 항목 | SuperClaude | Droid |
|------|-------------|-------|
| **설정 파일** | `claude_desktop_config.json` | **`~/.factory/mcp.json`** |
| **통합 방식** | airis-mcp-gateway (통합 게이트웨이) | 개별 서버 직접 연결 |
| **관리 방법** | 파일 직접 편집 | CLI 명령어 + 파일 편집 |
| **서버 타입** | stdio, SSE | stdio, HTTP |
| **환경 변수** | JSON 내 env 객체 | JSON 내 env 객체 (동일) |

**SuperClaude MCP 서버 (8개):**
1. airis-mcp-gateway (통합 게이트웨이)
2. sequential-thinking (구조적 사고)
3. context7 (문서 검색)
4. magic (UI 컴포넌트 생성)
5. playwright (브라우저 자동화)
6. serena (코드베이스 이해)
7. tavily (웹 검색)
8. chrome-devtools (성능 분석)

### 프로젝트 설정 시스템 비교

| 항목 | SuperClaude | Droid |
|------|-------------|-------|
| **전역 설정** | `CLAUDE.md` (import 시스템) | `AGENTS.md` (옵션) |
| **설정 형식** | Markdown with @imports | Markdown with semantic hints |
| **모드 시스템** | 7개 MODE 파일 (별도) | AGENTS.md에 통합 가능 |
| **프레임워크 문서** | 다수 별도 파일 | 단일 또는 최소 파일 |
| **발견 메커니즘** | @import 지시어 | 파일 시스템 검색 |

**SuperClaude 모드 파일 (7개):**
1. MODE_Brainstorming.md
2. MODE_DeepResearch.md
3. MODE_Introspection.md
4. MODE_Orchestration.md
5. MODE_Task_Management.md
6. MODE_Token_Efficiency.md
7. MODE_Business_Panel.md

**SuperClaude 프레임워크 문서:**
- PRINCIPLES.md (소프트웨어 엔지니어링 원칙)
- RULES.md (행동 규칙)
- FLAGS.md (실행 플래그)
- RESEARCH_CONFIG.md (리서치 설정)
- BUSINESS_SYMBOLS.md (비즈니스 심볼)
- BUSINESS_PANEL_EXAMPLES.md (비즈니스 패널 예시)

### 기능 비교 매트릭스

| 기능 | SuperClaude | Droid | 호환성 |
|------|-------------|-------|--------|
| 슬래시 명령어 | ✅ 26개 (고정) | ✅ 무제한 (사용자 정의) | 🟢 포팅 가능 |
| MCP 서버 통합 | ✅ 8개 서버 | ✅ 무제한 서버 | 🟢 완전 호환 |
| 프로젝트 설정 | ✅ CLAUDE.md | ✅ AGENTS.md | 🟡 구조 변환 필요 |
| 모드 시스템 | ✅ 7개 MODE | ❌ 없음 | 🟡 명령어/AGENTS.md로 변환 |
| 실행 스크립트 | ❌ 없음 | ✅ Shebang 지원 | 🔴 Droid 전용 |
| 전역 프레임워크 | ✅ 체계적 구조 | 🟡 단순 구조 | 🟡 디렉토리 추가 필요 |
| IDE 통합 | ✅ Claude Code | ✅ VSCode, JetBrains | 🟢 양쪽 지원 |

## SuperClaude → Droid 포팅 전략

### 목표

SuperClaude_Framework의 모든 기능을 Droid CLI에서도 사용 가능하도록 포팅하여, **Claude Code와 Droid 양쪽에서 동일한 강력한 개발 환경을 구축**합니다.

### 디렉토리 구조 설계

```
~/.factory/
├── settings.json                    # Droid 기본 설정
├── mcp.json                         # ⭐ MCP 서버 설정 (업데이트)
├── bin/
│   └── rg                          # Ripgrep
├── commands/
│   └── sc/                         # ⭐ SuperClaude 슬래시 명령어 (26개)
│       ├── analyze.md
│       ├── implement.md
│       ├── brainstorm.md
│       ├── research.md
│       ├── task.md
│       ├── design.md
│       ├── document.md
│       ├── explain.md
│       ├── build.md
│       ├── test.md
│       ├── troubleshoot.md
│       ├── cleanup.md
│       ├── improve.md
│       ├── workflow.md
│       ├── git.md
│       ├── save.md
│       ├── load.md
│       ├── reflect.md
│       ├── estimate.md
│       ├── spec-panel.md
│       ├── business-panel.md
│       ├── help.md
│       ├── index.md
│       ├── select-tool.md
│       ├── spawn.md
│       └── pm.md
├── superclaude/                    # ⭐ SuperClaude 프레임워크
│   ├── modes/                      # 7개 행동 모드
│   │   ├── MODE_Brainstorming.md
│   │   ├── MODE_DeepResearch.md
│   │   ├── MODE_Introspection.md
│   │   ├── MODE_Orchestration.md
│   │   ├── MODE_Task_Management.md
│   │   ├── MODE_Token_Efficiency.md
│   │   └── MODE_Business_Panel.md
│   ├── framework/                  # 핵심 프레임워크 문서
│   │   ├── PRINCIPLES.md
│   │   ├── RULES.md
│   │   ├── FLAGS.md
│   │   ├── RESEARCH_CONFIG.md
│   │   ├── BUSINESS_SYMBOLS.md
│   │   └── BUSINESS_PANEL_EXAMPLES.md
│   └── mcp/                        # MCP 서버 문서
│       ├── MCP_Sequential.md
│       ├── MCP_Context7.md
│       ├── MCP_Magic.md
│       ├── MCP_Playwright.md
│       ├── MCP_Serena.md
│       ├── MCP_Tavily.md
│       └── MCP_Morphllm.md
├── docs/                           # Spec 출력
└── AGENTS.md                       # ⭐ SuperClaude 프레임워크 통합 참조
```

### 포팅 작업 단계

#### Phase 1: MCP 서버 설정 (mcp.json)

**파일**: `~/.factory/mcp.json`

**내용:**

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

**참고**: 환경 변수가 필요한 서버 (context7, tavily 등)는 사용자가 직접 API 키를 설정해야 합니다.

#### Phase 2: 슬래시 명령어 포팅

**작업 내용:**

1. **디렉토리 생성**:
   ```bash
   mkdir -p ~/.factory/commands/sc
   ```

2. **명령어 파일 복사**:
   SuperClaude의 26개 명령어 파일을 `~/.factory/commands/sc/`로 복사

3. **명령어 파일 수정**:
   각 명령어 파일에서 다음 변경 수행:

   **변경 전:**
   ```markdown
   ---
   description: Comprehensive code analysis
   ---

   You are Claude Code with the SuperClaude_Framework.

   Access framework docs at ~/.claude/superclaude/framework/
   ```

   **변경 후:**
   ```markdown
   ---
   description: Comprehensive code analysis
   ---

   You are Droid CLI with the SuperClaude_Framework.

   Access framework docs at ~/.factory/superclaude/framework/
   ```

4. **주요 수정 사항**:
   - "Claude Code" → "Droid CLI"
   - "~/.claude/" → "~/.factory/"
   - MCP 서버 참조 유지 (Droid도 동일한 MCP 사용)

#### Phase 3: 프레임워크 문서 복사

**작업 내용:**

```bash
# 디렉토리 생성
mkdir -p ~/.factory/superclaude/{modes,framework,mcp}

# 모드 파일 복사
cp MODE_*.md ~/.factory/superclaude/modes/

# 프레임워크 문서 복사
cp PRINCIPLES.md RULES.md FLAGS.md RESEARCH_CONFIG.md \
   BUSINESS_SYMBOLS.md BUSINESS_PANEL_EXAMPLES.md \
   ~/.factory/superclaude/framework/

# MCP 문서 복사
cp MCP_*.md ~/.factory/superclaude/mcp/
```

#### Phase 4: 전역 AGENTS.md 생성

**파일**: `~/.factory/AGENTS.md`

**내용**:

```markdown
# SuperClaude Framework for Droid CLI

Droid CLI에서 SuperClaude_Framework를 활성화합니다.

## 프레임워크 컴포넌트

모든 SuperClaude 프레임워크 문서는 `~/.factory/superclaude/`에 있습니다:

- **Modes**: `~/.factory/superclaude/modes/` - 7개 행동 모드
- **Framework**: `~/.factory/superclaude/framework/` - 핵심 원칙 및 규칙
- **MCP**: `~/.factory/superclaude/mcp/` - MCP 서버 사용 가이드

## 핵심 원칙 (PRINCIPLES.md 요약)

**Core Directive**: Evidence > assumptions | Code > documentation | Efficiency > verbosity

**Philosophy**:
- Task-First Approach: Understand → Plan → Execute → Validate
- Evidence-Based Reasoning: All claims verifiable through testing
- Parallel Thinking: Maximize efficiency through intelligent batching
- Context Awareness: Maintain project understanding across sessions

**SOLID Principles**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion

**Core Patterns**: DRY, KISS, YAGNI

## 주요 행동 규칙 (RULES.md 요약)

### 워크플로우
- **Pattern**: Understand → Plan → TodoWrite(3+ tasks) → Execute → Validate
- **Batch Operations**: 항상 병렬 도구 호출 우선
- **Context Retention**: 90% 이상 이해도 유지

### 구현 완전성
- 부분 구현 금지, TODO 주석 금지
- 시작한 기능은 완전히 구현
- 실제 코드만 작성 (Mock 금지)

### 스코프 규율
- 요청된 것만 구현
- MVP 우선
- YAGNI 강제

### Git 워크플로우
- 항상 `git status`로 시작
- Feature 브랜치만 사용
- Main/Master 직접 작업 금지

### 도구 최적화
- 최적 도구 선택 (MCP > Native > Basic)
- 모든 독립 작업 병렬 실행
- Agent 위임 적극 활용

## MCP 서버 통합

### 사용 가능한 MCP 서버

1. **sequential-thinking**: 복잡한 분석 및 다단계 추론
2. **context7**: 공식 라이브러리 문서 검색
3. **magic**: UI 컴포넌트 생성 (21st.dev)
4. **playwright**: 브라우저 자동화 및 E2E 테스트
5. **serena**: 코드베이스 의미 이해 및 세션 저장
6. **tavily**: 웹 검색 및 실시간 정보
7. **chrome-devtools**: 성능 분석 및 디버깅
8. **morphllm**: 패턴 기반 코드 편집

### MCP 서버 선택 가이드

- **복잡한 분석**: sequential-thinking
- **라이브러리 문서**: context7
- **UI 작업**: magic
- **브라우저 테스트**: playwright
- **웹 검색**: tavily
- **대량 편집**: morphllm

## 슬래시 명령어

SuperClaude의 26개 강력한 명령어를 사용할 수 있습니다:

### 주요 명령어

- `/sc:analyze` - 코드 품질, 보안, 성능, 아키텍처 분석
- `/sc:implement` - 기능 구현 (MCP 통합)
- `/sc:brainstorm` - 요구사항 탐색 및 발견
- `/sc:research` - 웹 검색 기반 심층 연구
- `/sc:task` - 복잡한 작업 관리 및 위임
- `/sc:design` - 시스템 아키텍처 설계
- `/sc:document` - 문서 생성
- `/sc:test` - 테스트 실행 및 커버리지 분석
- `/sc:troubleshoot` - 문제 진단 및 해결
- `/sc:git` - Git 작업 (커밋, PR 생성)
- `/sc:save` / `/sc:load` - 세션 저장 및 로드

### 전체 명령어 목록

`/sc:help` 명령어로 모든 명령어 확인 가능

## 행동 모드

### 자동 활성화 트리거

1. **Brainstorming Mode**: 모호한 요청, "not sure", "thinking about"
2. **DeepResearch Mode**: 웹 검색 요청, 최신 정보 필요
3. **Introspection Mode**: 에러 복구, 메타 인지 필요
4. **Orchestration Mode**: 다중 도구, 병렬 실행 기회
5. **Task_Management Mode**: 3단계 이상 작업, 복잡한 스코프
6. **Token_Efficiency Mode**: 컨텍스트 사용률 75% 이상
7. **Business_Panel Mode**: 비즈니스 전략 분석 요청

## 플래그 시스템

### 분석 깊이
- `--think`: 표준 분석 (~4K 토큰)
- `--think-hard`: 심층 분석 (~10K 토큰)
- `--ultrathink`: 최대 깊이 (~32K 토큰)

### MCP 서버
- `--seq`: Sequential Thinking 활성화
- `--c7`: Context7 활성화
- `--magic`: Magic 활성화
- `--play`: Playwright 활성화
- `--tavily`: Tavily 활성화

### 실행 제어
- `--delegate`: 서브 에이전트 병렬 처리
- `--loop`: 반복 개선 사이클
- `--validate`: 실행 전 리스크 평가

## 사용 예시

```bash
# 복잡한 코드 분석
/sc:analyze src/ --think-hard --seq

# UI 기능 구현
/sc:implement --magic "user dashboard"

# 웹 검색 연구
/sc:research "latest React 19 features" --tavily

# Git 커밋 및 PR
/sc:git commit
/sc:git pr

# 작업 관리
/sc:task "implement authentication" --delegate
```

## 추가 리소스

자세한 내용은 `~/.factory/superclaude/` 디렉토리의 문서를 참조하세요.
```

### 포팅 스크립트 (선택적)

자동 포팅을 위한 Shell 스크립트:

```bash
#!/usr/bin/env bash
# superclaude-to-droid.sh
# SuperClaude_Framework를 Droid CLI로 포팅하는 스크립트

set -e

echo "🤖 SuperClaude → Droid 포팅 시작"

# 디렉토리 생성
echo "📁 디렉토리 구조 생성 중..."
mkdir -p ~/.factory/commands/sc
mkdir -p ~/.factory/superclaude/{modes,framework,mcp}

# 슬래시 명령어 복사 및 수정
echo "📝 슬래시 명령어 포팅 중..."
SUPERCLAUDE_DIR="$HOME/.claude/commands/sc"
DROID_CMD_DIR="$HOME/.factory/commands/sc"

if [ -d "$SUPERCLAUDE_DIR" ]; then
    for file in "$SUPERCLAUDE_DIR"/*.md; do
        filename=$(basename "$file")
        echo "  - $filename"

        # 복사 및 텍스트 치환
        sed 's/Claude Code/Droid CLI/g; s|~/.claude/|~/.factory/|g' \
            "$file" > "$DROID_CMD_DIR/$filename"
    done
else
    echo "⚠️  SuperClaude 명령어 디렉토리를 찾을 수 없습니다: $SUPERCLAUDE_DIR"
fi

# 프레임워크 문서 복사
echo "📚 프레임워크 문서 복사 중..."
FRAMEWORK_FILES=(
    "PRINCIPLES.md"
    "RULES.md"
    "FLAGS.md"
    "RESEARCH_CONFIG.md"
    "BUSINESS_SYMBOLS.md"
    "BUSINESS_PANEL_EXAMPLES.md"
)

for file in "${FRAMEWORK_FILES[@]}"; do
    if [ -f "$HOME/.claude/$file" ]; then
        echo "  - $file"
        cp "$HOME/.claude/$file" ~/.factory/superclaude/framework/
    fi
done

# 모드 파일 복사
echo "🎭 모드 파일 복사 중..."
for file in "$HOME/.claude"/MODE_*.md; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "  - $filename"
        cp "$file" ~/.factory/superclaude/modes/
    fi
done

# MCP 문서 복사
echo "🔌 MCP 문서 복사 중..."
for file in "$HOME/.claude"/MCP_*.md; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "  - $filename"
        cp "$file" ~/.factory/superclaude/mcp/
    fi
done

# AGENTS.md 생성
echo "⚙️  AGENTS.md 생성 중..."
cat > ~/.factory/AGENTS.md << 'EOF'
# SuperClaude Framework for Droid CLI

[위의 AGENTS.md 내용]
EOF

echo "✅ 포팅 완료!"
echo ""
echo "다음 단계:"
echo "1. ~/.factory/mcp.json 확인 및 API 키 설정"
echo "2. Droid 실행: droid"
echo "3. 명령어 테스트: /sc:help"
```

## 검증 및 테스트 계획

### Phase 1: 기본 검증

```bash
# Droid 실행
droid

# 명령어 목록 확인
/commands

# SuperClaude 명령어 확인
# sc/ 디렉토리의 26개 명령어가 모두 표시되어야 함
```

### Phase 2: 명령어 테스트

```bash
# 도움말 명령어
/sc:help

# 간단한 분석 명령어
/sc:analyze README.md

# MCP 서버 활용 명령어
/sc:research "Droid CLI features"
```

### Phase 3: MCP 서버 연결 확인

```bash
# MCP 서버 목록
/mcp list

# 개별 서버 테스트
# Sequential Thinking
/sc:analyze --seq src/

# Tavily 웹 검색
/sc:research --tavily "latest AI tools"

# Magic UI 생성
/sc:implement --magic "login form"
```

### 예상 문제 및 해결

#### 문제 1: MCP 서버 연결 실패

**증상**: MCP 도구를 사용할 수 없다는 오류

**해결**:
```bash
# MCP 서버 상태 확인
/mcp list

# 서버 비활성화되어 있으면 활성화
/mcp enable sequential-thinking
/mcp enable tavily

# mcp.json 직접 확인
cat ~/.factory/mcp.json
```

#### 문제 2: API 키 미설정

**증상**: Context7, Tavily 등에서 인증 오류

**해결**:
```bash
# mcp.json 편집
vim ~/.factory/mcp.json

# 환경 변수 설정
# Context7
"env": {
  "UPSTASH_REDIS_REST_URL": "https://your-url.upstash.io",
  "UPSTASH_REDIS_REST_TOKEN": "your-token"
}

# Tavily
"env": {
  "TAVILY_API_KEY": "your-api-key"
}
```

#### 문제 3: 명령어 파일 인식 안됨

**증상**: /sc: 명령어를 입력해도 "명령어를 찾을 수 없음"

**해결**:
```bash
# 디렉토리 확인
ls -la ~/.factory/commands/sc/

# 명령어 새로고침
/commands
# → "Reload Commands" 선택

# 파일 권한 확인 (실행 파일인 경우)
chmod +x ~/.factory/commands/sc/*.sh
```

## 최종 디렉토리 구조 검증

포팅 완료 후 최종 디렉토리 구조:

```
~/.factory/
├── settings.json                    ✅
├── mcp.json                         ✅ (8개 서버 설정)
├── bin/
│   └── rg                          ✅
├── commands/
│   └── sc/                         ✅ (26개 명령어)
│       ├── analyze.md
│       ├── implement.md
│       ├── brainstorm.md
│       ├── research.md
│       ├── task.md
│       ├── design.md
│       ├── document.md
│       ├── explain.md
│       ├── build.md
│       ├── test.md
│       ├── troubleshoot.md
│       ├── cleanup.md
│       ├── improve.md
│       ├── workflow.md
│       ├── git.md
│       ├── save.md
│       ├── load.md
│       ├── reflect.md
│       ├── estimate.md
│       ├── spec-panel.md
│       ├── business-panel.md
│       ├── help.md
│       ├── index.md
│       ├── select-tool.md
│       ├── spawn.md
│       └── pm.md
├── superclaude/                    ✅
│   ├── modes/                      ✅ (7개 파일)
│   │   ├── MODE_Brainstorming.md
│   │   ├── MODE_DeepResearch.md
│   │   ├── MODE_Introspection.md
│   │   ├── MODE_Orchestration.md
│   │   ├── MODE_Task_Management.md
│   │   ├── MODE_Token_Efficiency.md
│   │   └── MODE_Business_Panel.md
│   ├── framework/                  ✅ (6개 파일)
│   │   ├── PRINCIPLES.md
│   │   ├── RULES.md
│   │   ├── FLAGS.md
│   │   ├── RESEARCH_CONFIG.md
│   │   ├── BUSINESS_SYMBOLS.md
│   │   └── BUSINESS_PANEL_EXAMPLES.md
│   └── mcp/                        ✅ (7개 파일)
│       ├── MCP_Sequential.md
│       ├── MCP_Context7.md
│       ├── MCP_Magic.md
│       ├── MCP_Playwright.md
│       ├── MCP_Serena.md
│       ├── MCP_Tavily.md
│       └── MCP_Morphllm.md
├── docs/                           ✅
└── AGENTS.md                       ✅ (SuperClaude 통합)
```

## 호환성 유지 전략

### Claude Code 설정 유지

SuperClaude_Framework를 Droid로 포팅해도 **Claude Code의 기존 설정은 그대로 유지**됩니다:

```
~/.claude/                          # Claude Code (변경 없음)
├── settings.json
├── commands/sc/
├── MODE_*.md
├── PRINCIPLES.md
└── ...

~/.factory/                         # Droid CLI (새로 추가)
├── settings.json
├── mcp.json
├── commands/sc/
├── superclaude/
└── AGENTS.md
```

### 동기화 전략 (선택적)

두 시스템을 동기화하려면:

**Option 1: Symlink 사용**
```bash
# 위험: 설정 파일 형식이 다를 수 있음
ln -s ~/.claude/commands/sc ~/.factory/commands/sc
```

**Option 2: 수동 동기화**
```bash
# SuperClaude 업데이트 시 Droid도 업데이트
rsync -av ~/.claude/commands/sc/ ~/.factory/commands/sc/
sed -i 's/Claude Code/Droid CLI/g' ~/.factory/commands/sc/*.md
```

**Option 3: 독립 운영 (권장)**
- 각 시스템을 독립적으로 운영
- 필요한 기능만 선택적으로 복사
- 시스템별 최적화 가능

## 결론

### 포팅 성공 시 기대 효과

1. **명령어 통일성**: Claude Code와 Droid에서 동일한 `/sc:` 명령어 사용
2. **MCP 서버 공유**: 양쪽 시스템에서 동일한 MCP 서버 활용
3. **일관된 워크플로우**: SuperClaude의 강력한 프레임워크를 Droid에서도 활용
4. **선택의 자유**: 상황에 맞는 도구 선택 가능

### 주요 이점

| 측면 | 이점 |
|------|------|
| **생산성** | 강력한 /sc: 명령어로 반복 작업 자동화 |
| **품질** | 프레임워크 규칙으로 일관된 코드 품질 |
| **효율성** | MCP 서버 통합으로 2-3배 빠른 실행 |
| **유연성** | Claude Code와 Droid 간 자유로운 전환 |
| **확장성** | 새 명령어와 MCP 서버 쉽게 추가 가능 |

### 다음 단계

1. **즉시 실행**: 포팅 스크립트 실행 또는 수동 복사
2. **설정 확인**: mcp.json의 API 키 설정
3. **테스트**: 주요 명령어 동작 확인
4. **최적화**: Droid 특성에 맞게 명령어 조정
5. **문서화**: 팀원과 공유할 사용 가이드 작성

### 유지보수 계획

- **정기 업데이트**: SuperClaude_Framework 업데이트 시 Droid 동기화
- **피드백 수집**: Droid 사용 경험 기록 및 개선
- **커뮤니티 기여**: Droid용 SuperClaude 포팅 가이드 공유

---

**작성일**: 2025-10-24
**작성자**: Claude (Sonnet 4.5)
**목적**: SuperClaude_Framework를 Droid CLI로 포팅하기 위한 포괄적 분석 및 가이드
