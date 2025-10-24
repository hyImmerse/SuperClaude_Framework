# SuperClaude 커맨드 사용 가이드
**버전 4.0.9** | 업데이트: 2025-09-08 | ⭐ 15.1k GitHub Stars

SuperClaude는 Claude Code의 확장된 명령어 시스템으로, AI 기반 개발의 전체 라이프사이클을 혁신적으로 지원하는 차세대 프레임워크입니다.

## 🚀 버전 4.0.9 주요 변경사항
- **AI 기반 명령어 확장**: 브레인스토밍, 비즈니스 분석, 자기 성찰 등 신규 명령어
- **글로벌 베스트 프랙티스 통합**: 전 세계 개발자들의 검증된 워크플로우
- **MCP 서버 생태계 강화**: GitHub, Playwright, Context7 등 핵심 서버 통합
- **병렬 처리 최적화**: /sc:spawn을 통한 대규모 작업 자동화
- **엔터프라이즈 기능**: 팀 협업, 보안, 성능 모니터링 강화
- **AI 체이닝**: 여러 AI 모델 연계 활용 지원

## 📋 목차
- [프로젝트 개발 단계별 워크플로우](#프로젝트-개발-단계별-워크플로우)
- [SuperClaude 커맨드 분류](#superclaude-커맨드-분류)
- [페르소나 시스템](#페르소나-시스템)
- [상세 커맨드 가이드](#상세-커맨드-가이드)
- [글로벌 베스트 프랙티스](#글로벌-베스트-프랙티스)
- [실전 예시](#실전-예시)
- [고급 기능](#고급-기능)

## 🌟 글로벌 베스트 프랙티스

### CLAUDE.md 파일 활용법
프로젝트 루트에 `CLAUDE.md` 파일을 생성하여 Claude가 프로젝트 컨텍스트를 자동으로 이해하도록 설정합니다.

#### 효과적인 CLAUDE.md 구조
```markdown
# Project: [프로젝트명]

## 🏗️ 아키텍처 개요
- 프레임워크: Next.js 15 + React 19
- 데이터베이스: Supabase PostgreSQL
- 인증: Clerk
- 스타일링: Tailwind CSS + Shadcn/ui

## 📁 디렉터리 구조
- `/src/app`: Next.js App Router 페이지
- `/src/components`: 재사용 가능한 UI 컴포넌트
- `/src/lib`: 유틸리티 함수 및 설정
- `/src/hooks`: 커스텀 React 훅

## 🛠️ 주요 명령어
- `pnpm dev`: 개발 서버 실행
- `pnpm build`: 프로덕션 빌드
- `pnpm test`: 테스트 실행
- `pnpm lint`: 코드 품질 검사

## 📝 코드 스타일 가이드라인
- TypeScript strict 모드 사용
- 훅을 사용한 함수형 컴포넌트 선호
- Airbnb ESLint 규칙 준수
- Prettier를 사용한 코드 포매팅

## ⚠️ 중요 참고사항
- 새 컴포넌트 생성 전 기존 컴포넌트 확인 필수
- 기본적으로 서버 컴포넌트 사용, 필요시에만 클라이언트 컴포넌트 사용
- 더 나은 에러 처리를 위한 에러 바운더리 구현
- API 라우트에서 최소 권한 원칙 준수
```

### MCP 서버 통합 전략

#### 핵심 MCP 서버 매트릭스
| MCP 서버 | 용도 | 최적 사용 시나리오 |
|---------|------|-------------------|
| **GitHub** | 버전 관리, PR 리뷰 | 코드 리뷰, 이슈 관리, CI/CD 트리거 |
| **Playwright** | 브라우저 자동화 | E2E 테스트, UI 검증, 스크린샷 |
| **Context7** | 문서 검색 | 라이브러리 문서, API 레퍼런스 |
| **Sequential** | 복잡한 분석 | 디버깅, 아키텍처 설계 |
| **Magic** | UI 컴포넌트 | React/Vue 컴포넌트 생성 |
| **Morphllm** | 대량 편집 | 코드 리팩토링, 스타일 적용 |
| **Serena** | 프로젝트 메모리 | 세션 지속성, 컨텍스트 관리 |

### 워크플로우 자동화 패턴

#### CI/CD 파이프라인 통합
```bash
# GitHub Actions와 연계
/sc:implement "CI/CD 파이프라인" --persona-devops --github-mcp

# 자동화된 테스트 실행
/sc:test --type all --coverage --ci-mode

# 배포 자동화
/sc:deploy --environment production --validate --rollback-enabled
```

## 🚀 프로젝트 개발 단계별 워크플로우

### 0단계: 프로젝트 초기 설정 (SuperClaude 3.0 신기능)

> **💡 필수 도구**: [개발 설정 도구](https://github.com/SuperClaude-Org/setup-tools) 설치 필요

**즉시 시작 가능한 프로젝트 설정**:

#### **모든 OS 공통:**
```bash
# 기존 프로젝트 SuperClaude 활성화
cd /path/to/your/project
setup-sctemplate  # 또는 sst (단축키)

# 새 프로젝트 생성 및 설정
mkdir my-new-project && cd my-new-project
setup-sctemplate --type [web|flutter|saas|enterprise]
```

#### **프로젝트 타입별 템플릿:**
- **web**: Next.js 15 + React 19 + Vercel + Drizzle + Neon + tRPC
- **flutter**: Flutter 3.24+ + Supabase + Riverpod + Clean Architecture + Go Router 4.0
- **saas**: 서버리스 아키텍처 + AI 통합 + 엣지 컴퓨팅 + 관찰가능성
- **enterprise**: Service Mesh + Observability Platform + Cloud-Native + Zero Trust

### 1단계: 프로젝트 컨텍스트 로딩 및 TODO 생성

```bash
# 프로젝트 컨텍스트 로드 (MCP 서버 자동 활성화)
/sc:load @specs/customer_req.md @tech-stack-guide.md @scUsage.md --seq --c7 --persona-architect

# AI 기반 TODO 생성 (프로젝트 타입별 최적화)
/sc:analyze @specs/customer_req.md @tech-stack-guide.md --comprehensive --seq --c7

# 브레인스토밍 세션 (신규 기능)
/sc:brainstorm "프로젝트 아키텍처 설계" --persona-architect --visual --mindmap
```

### 2단계: 핵심 기능 구현

```bash
# 서버리스 백엔드 구현
/sc:implement "사용자 인증 시스템" --persona-backend --c7 --test-driven

# 프론트엔드 컴포넌트 구현
/sc:implement "대시보드 UI" --persona-frontend --magic --c7 --responsive

# 데이터베이스 설계
/sc:implement "데이터 모델링" --persona-backend --seq --migration-ready

# 비즈니스 로직 분석 (신규 기능)
/sc:business-panel "수익 모델 분석" --market-analysis --roi-calculation
```

### 3단계: 품질 보증

```bash
# 코드 품질 분석
/sc:analyze --focus quality --persona-refactorer --sonarqube

# 보안 분석
/sc:analyze --focus security --persona-security --penetration-test

# 성능 최적화
/sc:improve --focus performance --persona-performance --lighthouse

# 자기 성찰 및 개선 (신규 기능)
/sc:reflect "개발 프로세스" --lessons-learned --improvement-points
```

### 4단계: 테스트 및 검증

```bash
# 테스트 구현 및 실행
/sc:test --type unit --persona-qa --coverage-threshold 80

# E2E 테스트
/sc:test --type e2e --play --record-video

# 부하 테스트
/sc:test --type load --users 1000 --duration 10m

# 작업 추정 (신규 기능)
/sc:estimate "남은 작업" --breakdown --confidence-level
```

### 5단계: 문서화

```bash
# API 문서 생성
/sc:document --focus api --persona-scribe=ko --openapi

# 사용자 가이드 작성
/sc:document --focus user-guide --persona-mentor --interactive

# 프로젝트 전체 문서화
/sc:index --comprehensive --searchable
```

### 6단계: 배포 준비

```bash
# 빌드 및 패키징
/sc:build --production --validate --tree-shaking

# 배포 파이프라인
/sc:implement "CI/CD 파이프라인" --persona-devops --github-actions

# 프로덕션 체크리스트
/sc:analyze --focus production-ready --checklist
```

### 7단계: 프로덕션 모니터링 (신규)

```bash
# 모니터링 설정
/sc:implement "모니터링 대시보드" --persona-devops --grafana --prometheus

# 알림 설정
/sc:implement "알림 시스템" --pagerduty --slack

# 성능 추적
/sc:monitor --realtime --metrics --alerts
```

## 🎯 SuperClaude 커맨드 분류

### 개발 & 구현
- **`/sc:implement`**: 기능 구현 및 코드 작성
- **`/sc:build`**: 빌드, 컴파일, 패키징
- **`/sc:design`**: 시스템 아키텍처 및 API 설계
- **`/sc:workflow`**: 구조화된 구현 워크플로우 생성
- **`/sc:spawn`**: 병렬 작업 실행 및 위임 (확장)

### 분석 & 품질
- **`/sc:analyze`**: 코드 품질, 보안, 성능 분석
- **`/sc:improve`**: 체계적인 품질 개선
- **`/sc:cleanup`**: 코드 정리 및 최적화
- **`/sc:troubleshoot`**: 문제 진단 및 해결
- **`/sc:reflect`**: 자기 성찰 및 프로세스 개선 (신규)

### 협업 & 계획
- **`/sc:brainstorm`**: AI 기반 브레인스토밍 (신규)
- **`/sc:business-panel`**: 비즈니스 분석 패널 (신규)
- **`/sc:task`**: 고급 작업 관리 (신규)
- **`/sc:estimate`**: 시간 및 복잡도 추정 (신규)

### 테스트 & 검증
- **`/sc:test`**: 테스트 실행 및 커버리지 관리
- **`/sc:validate`**: 검증 및 품질 게이트

### 문서화 & 지식관리
- **`/sc:document`**: 특정 컴포넌트 문서화
- **`/sc:index`**: 종합적인 프로젝트 문서 생성
- **`/sc:explain`**: 코드 및 개념 설명

### 프로젝트 관리
- **`/sc:load`**: 프로젝트 컨텍스트 분석
- **`/sc:git`**: Git 워크플로우 관리
- **`/sc:monitor`**: 실시간 모니터링 (신규)

## 👥 페르소나 시스템 (확장: 15개)

### 기술 전문가
- **`--persona-architect`**: 시스템 아키텍처 전문가
- **`--persona-frontend`**: UI/UX 전문가
- **`--persona-backend`**: 서버 및 인프라 전문가
- **`--persona-security`**: 보안 전문가
- **`--persona-performance`**: 성능 최적화 전문가
- **`--persona-ai-trainer`**: AI 모델 학습 전문가 (신규)
- **`--persona-data-scientist`**: 데이터 분석 전문가 (신규)

### 프로세스 & 품질 전문가
- **`--persona-analyzer`**: 근본 원인 분석 전문가
- **`--persona-qa`**: 품질 보증 전문가
- **`--persona-refactorer`**: 코드 품질 전문가
- **`--persona-devops`**: 인프라 및 배포 전문가
- **`--persona-cloud-architect`**: 클라우드 아키텍처 전문가 (신규)

### 지식 & 커뮤니케이션
- **`--persona-mentor`**: 교육 및 지식 전달 전문가
- **`--persona-scribe=lang`**: 전문 문서 작성자
- **`--persona-blockchain`**: 블록체인 전문가 (신규)

## 📖 상세 커맨드 가이드

### /sc:cleanup (개선)
**목적**: 프로젝트 코드 정리, 구조 최적화, 불필요한 파일 제거
**특징**: 안전한 정리, 구조 재조직, 데드 코드 제거, 폴더 최적화

```bash
# 기본 코드 정리
/sc:cleanup

# 불필요한 파일 분석 및 제거
/sc:cleanup --analyze-unused --safe --backup

# 프로젝트 구조 재조직화
/sc:cleanup --restructure --persona-architect --validate

# 데드 코드 제거
/sc:cleanup --dead-code --test-coverage

# 의존성 정리
/sc:cleanup --dependencies --update-imports

# 전체 프로젝트 최적화
/sc:cleanup --comprehensive --optimize-structure --documentation
```

#### 활용 예시
```bash
# 레거시 프로젝트 정리
/sc:cleanup --legacy --safe-mode --incremental

# 테스트 파일 정리
/sc:cleanup --test-files --organize

# 빌드 아티팩트 제거
/sc:cleanup --build-artifacts --cache-clear

# 폴더 구조 표준화
/sc:cleanup --standardize --best-practices --rename-files
```

#### 프로젝트 구조 최적화 워크플로우
```bash
# 1단계: 현재 구조 분석
/sc:analyze --focus architecture --comprehensive

# 2단계: 불필요한 파일 식별
/sc:cleanup --analyze-unused --report-only

# 3단계: 안전하게 정리 (백업 포함)
/sc:cleanup --safe --backup --log-changes

# 4단계: 구조 재조직화
/sc:cleanup --restructure --validate

# 5단계: 문서 업데이트
/sc:document --structure-changes --readme-update
```

### /sc:brainstorm (신규)
**목적**: AI 기반 창의적 아이디어 생성 및 문제 해결
**특징**: 마인드맵 생성, 다각도 분석, 아이디어 평가

```bash
# 기본 브레인스토밍
/sc:brainstorm "새로운 기능 아이디어"

# 시각화 포함
/sc:brainstorm "시스템 아키텍처" --visual --mindmap

# 팀 브레인스토밍
/sc:brainstorm "프로젝트 이름" --collaborative --voting

# SWOT 분석
/sc:brainstorm "사업 계획" --swot-analysis --market-research
```

#### 활용 예시
```bash
# 스타트업 아이디어 생성
/sc:brainstorm "AI 기반 헬스케어 스타트업" --market-size --competitor-analysis

# 기술 스택 선택
/sc:brainstorm "모바일 앱 기술 스택" --pros-cons --comparison-matrix

# 문제 해결 접근법
/sc:brainstorm "성능 병목 현상 해결" --root-cause --solutions-ranking
```

### /sc:business-panel (신규)
**목적**: 비즈니스 관점의 종합적 분석 및 전략 수립
**특징**: ROI 계산, 시장 분석, 경쟁사 분석, 비즈니스 모델 검증

```bash
# 시장 분석
/sc:business-panel "타겟 시장 분석" --market-size --growth-rate

# ROI 계산
/sc:business-panel "프로젝트 ROI" --investment-analysis --payback-period

# 경쟁사 분석
/sc:business-panel "경쟁 환경" --competitor-matrix --swot

# 비즈니스 모델 검증
/sc:business-panel "SaaS 수익 모델" --unit-economics --ltv-cac
```

#### 활용 예시
```bash
# 신규 서비스 출시 전략
/sc:business-panel "B2B SaaS 출시 전략" --go-to-market --pricing-strategy

# 투자 유치 준비
/sc:business-panel "시리즈 A 준비" --pitch-deck --financial-projection

# 파트너십 분석
/sc:business-panel "전략적 파트너십" --synergy-analysis --risk-assessment
```

### /sc:reflect (신규)
**목적**: 개발 프로세스 자기 성찰 및 지속적 개선
**특징**: 레트로스펙티브, 교훈 도출, 개선점 식별

```bash
# 프로젝트 회고
/sc:reflect "스프린트 1 회고" --what-went-well --what-to-improve

# 코드 리뷰 성찰
/sc:reflect "코드 품질" --patterns-identified --anti-patterns

# 팀 프로세스 개선
/sc:reflect "팀 협업" --communication --workflow-optimization

# 기술 부채 분석
/sc:reflect "기술 부채" --debt-inventory --payoff-strategy
```

#### 활용 예시
```bash
# 인시던트 사후 분석
/sc:reflect "프로덕션 장애" --root-cause --prevention-measures

# 개인 성장 계획
/sc:reflect "개발자 성장" --skill-gaps --learning-path

# 프로젝트 교훈
/sc:reflect "프로젝트 완료" --lessons-learned --best-practices
```

### /sc:task (신규)
**목적**: 복잡한 작업의 지능적 관리 및 자동화
**특징**: 의존성 관리, 우선순위 설정, 자동 할당

```bash
# 작업 분해
/sc:task "대규모 리팩토링" --breakdown --dependencies

# 우선순위 설정
/sc:task "백로그 정리" --prioritize --effort-impact

# 팀 작업 할당
/sc:task "스프린트 계획" --auto-assign --load-balancing

# 진행 상황 추적
/sc:task "프로젝트 현황" --dashboard --bottlenecks
```

#### 활용 예시
```bash
# 마이크로서비스 분해
/sc:task "모놀리스 → 마이크로서비스" --migration-plan --phases

# 기술 부채 해결
/sc:task "기술 부채 감소" --quick-wins --long-term

# 릴리스 계획
/sc:task "v2.0 릴리스" --release-train --risk-mitigation
```

### /sc:estimate (신규)
**목적**: 정확한 시간 및 리소스 추정
**특징**: 3점 추정, 몬테카를로 시뮬레이션, 신뢰 구간

```bash
# 시간 추정
/sc:estimate "기능 개발" --three-point --confidence-interval

# 리소스 추정
/sc:estimate "팀 리소스" --capacity-planning --burndown

# 비용 추정
/sc:estimate "프로젝트 비용" --cost-breakdown --contingency

# 위험 조정 추정
/sc:estimate "출시 일정" --risk-adjusted --buffer-calculation
```

#### 활용 예시
```bash
# 스프린트 계획
/sc:estimate "스프린트 23" --velocity-based --team-capacity

# 프로젝트 제안서
/sc:estimate "신규 프로젝트" --fixed-price --scope-buffer

# 기술 부채 영향
/sc:estimate "리팩토링 영향" --productivity-impact --roi
```

### /sc:spawn (통합 및 확장)
**목적**: 대규모 병렬 작업 실행 및 워크플로우 자동화
**특징**: 작업 분할, 병렬 실행, 결과 통합, 에러 핸들링

```bash
# 기본 사용법
/sc:spawn [작업타입] "작업명" [옵션]
```

#### 대량 문서 생성 & 검토 파이프라인
```bash
# 1) 초안 생성
/sc:spawn draft "서비스 기획 매뉴얼" --persona-writer --seq

# 2) 기술 검토
/sc:spawn review "매뉴얼 기술 검토" --persona-engineer --validate

# 3) 스타일 가이드 적용
/sc:spawn refine "매뉴얼 개선" --persona-editor --c7

# 4) 최종 검수
/sc:spawn finalize "매뉴얼 완성" --persona-qa --comprehensive
```

#### 코드 리뷰 & 리팩토링 프로세스
```bash
# 1) 코드 분석
/sc:spawn analyze "src/" --persona-analyzer --deep-scan

# 2) 보안 점검
/sc:spawn audit "src/" --persona-security --vulnerability-scan

# 3) 성능 최적화
/sc:spawn optimize "src/" --persona-performance --benchmark

# 4) 리팩토링 적용
/sc:spawn refactor "src/" --persona-architect --apply-changes
```

#### API 설계 & 문서화 워크플로우
```bash
# 1) 스펙 초안 작성
/sc:spawn spec "User API 설계" --persona-architect --openapi

# 2) 예제 코드 생성
/sc:spawn generate "API 예제" --persona-developer --multi-language

# 3) 문서 포맷팅
/sc:spawn format "API 문서" --persona-scribe=ko --markdown

# 4) 배포 스크립트 생성
/sc:spawn script "deploy_api.sh" --persona-devops --ci-ready
```

#### 병렬 처리 고급 기능
```bash
# 다중 파일 동시 처리
/sc:spawn parallel "리팩토링" --files "src/**/*.ts" --workers 4

# 의존성 기반 실행
/sc:spawn chain "빌드 체인" --dependency-graph --fail-fast

# 조건부 실행
/sc:spawn conditional "테스트" --if-changed "src/" --since "main"

# 결과 집계
/sc:spawn aggregate "분석 결과" --merge-reports --summary
```

### /sc:implement (개선)
**목적**: 기능 및 코드 구현
**특징**: 지능적 페르소나 활성화, MCP 통합, TDD 지원

```bash
# 기본 사용법
/sc:implement "로그인 기능"

# TDD 방식 구현
/sc:implement "결제 시스템" --test-first --coverage 90

# 페르소나 지정
/sc:implement "REST API" --persona-backend --swagger

# MCP 서버 활용
/sc:implement "React 컴포넌트" --magic --c7 --storybook

# Wave 모드 (대규모 구현)
/sc:implement "전체 인증 시스템" --wave-mode progressive --validate
```

### /sc:analyze (개선)
**목적**: 종합적인 코드 및 시스템 분석
**특징**: 다차원 분석, Wave 지원, AI 인사이트

```bash
# 전체 시스템 분석
/sc:analyze --comprehensive --persona-architect --report

# 보안 중심 분석
/sc:analyze --focus security --persona-security --cve-check

# 성능 분석
/sc:analyze --focus performance --lighthouse --bundle-analysis

# 대규모 코드베이스 분석
/sc:analyze @monorepo/ --delegate --parallel-dirs --summary
```

### /sc:test (개선)
**목적**: 테스트 실행 및 관리
**특징**: 다양한 테스트 타입, 시각적 테스트, CI 통합

```bash
# 전체 테스트
/sc:test --all --parallel --fail-fast

# 단위 테스트
/sc:test --type unit --watch --coverage

# E2E 테스트
/sc:test --type e2e --play --video --screenshots

# 성능 테스트
/sc:test --type performance --lighthouse --metrics

# 시각적 회귀 테스트
/sc:test --type visual --percy --diff-threshold 0.1
```

## 💡 실전 예시

### 1. 새 프로젝트 시작하기 (SuperClaude 3.0 워크플로우)
```bash
# 1. 프로젝트 초기 설정
mkdir oneline-saas && cd oneline-saas
setup-sctemplate --type saas

# 2. CLAUDE.md 파일 생성
echo "# OneLine SaaS Platform
## Tech Stack
- Next.js 15 + Supabase
- AI: Claude, Perplexity, SkyWork
## Key Features
- Marketing Automation
- AI Content Generation" > CLAUDE.md

# 3. 요구사항 분석 및 TODO 생성
/sc:brainstorm "마케팅 자동화 플랫폼" --market-analysis --competitor
/sc:business-panel "SaaS 수익 모델" --pricing-tiers --unit-economics
/sc:analyze @specs/customer_req.md --comprehensive --seq --c7

# 4. 개발 시작
/sc:spawn @TODO.md --wave-mode progressive --parallel
```

### 2. 프로젝트 구조 정리 및 최적화 (신규)
```bash
# 1. 현재 프로젝트 상태 분석
/sc:analyze --focus architecture --comprehensive --report

# 2. 불필요한 파일 식별
/sc:cleanup --analyze-unused --report-only --categorize

# 3. 안전하게 정리 (백업 자동 생성)
/sc:cleanup --safe --backup --log-changes

# 4. 폴더 구조 재조직화
/sc:cleanup --restructure --best-practices --validate

# 5. 문서 업데이트
/sc:document --structure-changes --migration-guide

# 6. 검증 및 테스트
/sc:test --integration --verify-imports --path-validation
```

### 3. 엔터프라이즈 마이크로서비스 구현
```bash
# 1. 아키텍처 설계
/sc:design "마이크로서비스 아키텍처" --persona-cloud-architect --kubernetes

# 2. 서비스 구현
/sc:implement "사용자 서비스" --persona-backend --grpc --test-driven
/sc:implement "결제 서비스" --persona-backend --saga-pattern
/sc:implement "알림 서비스" --persona-backend --event-driven

# 3. API 게이트웨이
/sc:implement "API 게이트웨이" --kong --rate-limiting --auth

# 4. 모니터링 설정
/sc:implement "관찰성 스택" --prometheus --grafana --jaeger
```

### 4. AI 기반 기능 개발
```bash
# 1. AI 모델 통합
/sc:implement "AI 파이프라인" --persona-ai-trainer --langchain

# 2. 프롬프트 엔지니어링
/sc:brainstorm "효과적인 프롬프트" --prompt-templates --testing

# 3. 모델 평가
/sc:analyze "AI 모델 성능" --metrics --confusion-matrix

# 4. 프로덕션 배포
/sc:implement "AI 서빙 인프라" --vllm --load-balancing
```

### 5. 레거시 시스템 현대화
```bash
# 1. 현재 상태 분석
/sc:analyze @legacy/ --technical-debt --migration-risks
/sc:estimate "현대화 프로젝트" --phases --resources

# 2. 단계별 마이그레이션
/sc:task "마이그레이션 계획" --strangler-pattern --rollback-plan

# 3. 점진적 개선
/sc:improve --wave-mode progressive --test-coverage
/sc:spawn refactor "legacy/" --parallel --safe-mode

# 4. 검증 및 전환
/sc:test --regression --smoke-test --canary
```

### 6. 팀 협업 워크플로우
```bash
# 1. 코드 리뷰 자동화
/sc:spawn review "feature/새기능" --checklist --auto-approve

# 2. 페어 프로그래밍 시뮬레이션
/sc:implement "복잡한 알고리즘" --pair-mode --explain-steps

# 3. 지식 공유
/sc:document "아키텍처 결정" --adr --decision-record
/sc:explain "핵심 비즈니스 로직" --diagram --examples

# 4. 온보딩 자동화
/sc:implement "개발 환경 설정" --setup-script --prerequisites
```

## ⚡ 고급 기능

### Wave 모드 2.0 (개선)
- **자동 활성화**: 복잡도 ≥0.7, 파일 수 >20, 작업 유형 >2
- **지능적 분할**: AI 기반 작업 분할 및 의존성 분석
- **적응형 실행**: 실시간 리소스 모니터링 및 조정

```bash
# Progressive Wave (점진적)
/sc:implement "대규모 기능" --wave-mode progressive --checkpoint

# Systematic Wave (체계적)
/sc:analyze "전체 시스템" --wave-mode systematic --metrics

# Adaptive Wave (적응형)
/sc:improve "성능 최적화" --wave-mode adaptive --auto-tune

# Enterprise Wave (엔터프라이즈)
/sc:spawn "조직 전체 분석" --wave-mode enterprise --multi-tenant
```

### AI 체이닝 (신규)
여러 AI 모델을 연계하여 복잡한 작업 수행

```bash
# 분석 → 생성 → 검증 체인
/sc:chain analyze "요구사항" | generate "코드" | validate "테스트"

# 다중 모델 앙상블
/sc:ensemble "콘텐츠 생성" --models "claude,gpt4,gemini" --voting

# 특화 모델 라우팅
/sc:route "작업" --classifier "작업유형" --specialized-models
```

### 컨텍스트 매니저 (신규)
프로젝트별 컨텍스트 자동 전환 및 관리

```bash
# 컨텍스트 저장
/sc:context save "프로젝트A" --include-all

# 컨텍스트 전환
/sc:context switch "프로젝트B"

# 컨텍스트 병합
/sc:context merge "프로젝트A" "프로젝트B" --resolve-conflicts

# 컨텍스트 공유
/sc:context share "팀_컨텍스트" --team "개발팀"
```

### 성능 모니터링 (신규)
실시간 성능 추적 및 최적화

```bash
# 실시간 모니터링
/sc:monitor --realtime --dashboard

# 성능 프로파일링
/sc:profile "느린 API" --flame-graph --bottlenecks

# 자동 최적화
/sc:optimize --auto-tune --performance-budget

# 알림 설정
/sc:alert --threshold "response_time > 200ms" --notify slack
```

### MCP 서버 오케스트레이션
```bash
# 다중 MCP 서버 연계
/sc:orchestrate --github --playwright --context7

# 서버별 작업 라우팅
/sc:route "UI 테스트" --mcp playwright
/sc:route "문서 검색" --mcp context7
/sc:route "PR 리뷰" --mcp github

# MCP 서버 상태 확인
/sc:mcp status --health-check --latency
```

## 🔒 보안 베스트 프랙티스 (신규)

### 보안 개발 생명주기 (SDLC)
```bash
# 위협 모델링
/sc:analyze --threat-modeling --stride

# 보안 코드 리뷰
/sc:review --security-focus --owasp-top10

# 의존성 스캔
/sc:scan --dependencies --cve-check

# 침투 테스트
/sc:test --penetration --ethical-hacking
```

### 시크릿 관리
```bash
# 시크릿 스캔
/sc:scan --secrets --pre-commit

# 암호화 구현
/sc:implement "암호화 레이어" --aes256 --key-rotation

# 접근 제어
/sc:implement "RBAC" --least-privilege --audit-log
```

## 🚀 성능 최적화 가이드 (신규)

### 프론트엔드 최적화
```bash
# 번들 분석
/sc:analyze --bundle-size --tree-shaking

# 이미지 최적화
/sc:optimize "이미지" --webp --lazy-loading

# 코드 스플리팅
/sc:implement "동적 임포트" --code-splitting --prefetch
```

### 백엔드 최적화
```bash
# 데이터베이스 최적화
/sc:optimize "쿼리" --explain-plan --indexing

# 캐싱 전략
/sc:implement "캐싱" --redis --cache-invalidation

# 비동기 처리
/sc:implement "큐 시스템" --rabbitmq --worker-pool
```

## 👥 팀 협업 전략 (신규)

### 코드 리뷰 문화
```bash
# PR 템플릿 생성
/sc:implement "PR 템플릿" --checklist --guidelines

# 자동 리뷰어 할당
/sc:git "리뷰어 할당" --codeowners --round-robin

# 리뷰 메트릭
/sc:analyze "리뷰 통계" --turnaround-time --coverage
```

### 지식 공유
```bash
# 기술 문서화
/sc:document "아키텍처" --c4-model --diagrams

# 페어 프로그래밍
/sc:pair "복잡한 기능" --mob-programming --rotate

# 브라운백 세션
/sc:present "새 기술" --slides --demo
```

## 🤖 AI 윤리 가이드라인 (신규)

### 책임감 있는 AI 개발
```bash
# 편향성 검사
/sc:analyze "AI 모델" --bias-detection --fairness

# 설명 가능성
/sc:implement "XAI" --interpretability --lime-shap

# 프라이버시 보호
/sc:implement "차등 프라이버시" --differential-privacy

# 윤리 검토
/sc:review "AI 기능" --ethics-checklist --impact-assessment
```

## 📱 Flutter 특화 가이드 (개선)

### Flutter 3.5+ 최신 기능
```bash
# Material 3 디자인
/sc:implement "Material You" --dynamic-color --adaptive

# Impeller 렌더링 엔진
/sc:optimize "렌더링" --impeller --gpu-acceleration

# 웹 어셈블리 지원
/sc:build --wasm --web-optimization
```

### Riverpod 2.0 상태 관리
```bash
# Generator 사용
/sc:implement "상태 관리" --riverpod-generator --async-notifier

# 테스트 가능한 상태
/sc:test "Riverpod" --provider-container --mock

# 상태 지속성
/sc:implement "상태 저장" --hive --encrypted
```

### 최신 Flutter 패키지
```bash
# 애니메이션
/sc:implement "Rive 애니메이션" --rive --interactive

# 네비게이션
/sc:implement "Go Router" --deep-linking --guards

# 국제화
/sc:implement "다국어" --slang --type-safe
```

## 🔧 유용한 팁 (SuperClaude 3.0)

### 효율성 극대화
1. **CLAUDE.md 필수**: 모든 프로젝트에 컨텍스트 파일 생성
2. **MCP 서버 활용**: 작업별 최적 서버 선택으로 생산성 향상
3. **병렬 처리 우선**: /sc:spawn으로 대규모 작업 자동화
4. **AI 체이닝**: 복잡한 작업은 여러 AI 모델 연계
5. **Wave 모드**: 대규모 작업은 자동으로 분할 처리

### 품질 보증
6. **TDD 기본**: --test-first 플래그로 테스트 주도 개발
7. **보안 우선**: 모든 구현에 --security-check 포함
8. **성능 예산**: --performance-budget으로 성능 목표 설정
9. **문서화 동시 진행**: 구현과 동시에 문서 작성
10. **코드 리뷰 자동화**: /sc:spawn review로 일관된 품질

### 팀 협업
11. **컨텍스트 공유**: 팀원 간 프로젝트 컨텍스트 동기화
12. **페어 프로그래밍**: --pair-mode로 지식 전파
13. **자동 온보딩**: 신규 팀원용 설정 스크립트 준비
14. **메트릭 추적**: 팀 생산성 및 코드 품질 지표 모니터링
15. **레트로스펙티브**: /sc:reflect로 지속적 개선

## 🚀 빠른 시작 체크리스트

### 프로젝트 시작 전
- [ ] setup-sctemplate 도구 설치
- [ ] CLAUDE.md 파일 작성
- [ ] 기술 스택 결정
- [ ] MCP 서버 설정

### 개발 단계
- [ ] /sc:brainstorm으로 아이디어 구체화
- [ ] /sc:business-panel로 비즈니스 검증
- [ ] /sc:estimate로 일정 수립
- [ ] /sc:implement로 구현 시작
- [ ] /sc:test로 품질 검증

### 배포 준비
- [ ] /sc:analyze --production-ready
- [ ] /sc:document --comprehensive
- [ ] /sc:build --production
- [ ] /sc:monitor 설정

## 📚 참고 자료

### 공식 문서
- [SuperClaude Framework GitHub](https://github.com/SuperClaude-Org/SuperClaude_Framework)
- [Claude Code 공식 문서](https://claude.ai/code)
- [MCP 서버 디렉토리](https://github.com/anthropics/mcp-servers)

### 커뮤니티 리소스
- [SuperClaude Discord](https://discord.gg/superclaude)
- [베스트 프랙티스 포럼](https://forum.superclaude.dev)
- [유튜브 튜토리얼](https://youtube.com/@superclaude)

### 버전 히스토리
- **v3.0.0** (2025-09-08): AI 체이닝, 새로운 명령어, 글로벌 베스트 프랙티스
- **v2.0.0**: 워크플로우 자동화, 서버리스 중심, 가이드 통합
- **v1.0.0**: 기본 SuperClaude 커맨드 시스템

---

SuperClaude는 AI 기반 개발의 미래를 선도하는 혁신적인 프레임워크입니다. 
전 세계 개발자들의 검증된 워크플로우와 최신 AI 기술을 결합하여, 
개발 생산성을 극대화하고 코드 품질을 향상시킵니다.

**함께 만들어가는 SuperClaude** - [기여하기](https://github.com/SuperClaude-Org/SuperClaude_Framework/contribute)