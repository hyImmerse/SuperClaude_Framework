# Droid CLI 명령어 파일 변환 템플릿

**작성일**: 2025-10-25
**목적**: Claude Code CLI 형식 → Droid CLI 형식 변환 가이드

---

## 🎯 변환 템플릿

### YAML Frontmatter 변환

**Before** (Claude Code 형식):
```yaml
---
name: commandname
description: "Description text"
category: workflow
complexity: standard
mcp-servers: []
personas: [architect, frontend]
---
```

**After** (Droid CLI 형식):
```yaml
---
description: "Clear, action-oriented description"
argument-hint: <target> [--flag1] [--flag2]
mcp-servers: [required-server-1, required-server-2]
---
```

**변환 규칙**:
1. `name` 제거 (파일명이 명령어 이름)
2. `category`, `complexity`, `personas` 제거
3. `argument-hint` 추가 (명령어 사용법)
4. `mcp-servers` 실제 필요 서버로 채우기

---

### 본문 변환 템플릿

#### 기본 구조

```markdown
**COMMAND: [Action Verb] [Object/Target]**

[What to analyze/implement/execute]: `$ARGUMENTS`

**CRITICAL INSTRUCTIONS**:
1. [Primary action on $ARGUMENTS]
2. IDE Context Control: [Instruction about ignoring/using IDE context]
3. Flag Parsing: [How to parse and use flags from $ARGUMENTS]
4. Framework Rules: Follow PRINCIPLES.md and RULES.md from AGENTS.md
5. Execution: [Final execution instruction]

**Execution Steps**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

Execute [action] now.
```

#### 명령어 타입별 템플릿

##### 분석 명령어 (analyze, troubleshoot)

```markdown
**COMMAND: Analyze [Domain] with SuperClaude Framework**

Analyze target: `$ARGUMENTS`

**CRITICAL INSTRUCTIONS**:
1. Analyze `$ARGUMENTS`, NOT the currently open file in IDE
2. Parse flags: --focus [domain], --depth [level], --seq, --think-hard
3. If --seq or --think-hard: Activate Sequential MCP for structured analysis
4. Follow PRINCIPLES.md (Evidence > assumptions) and RULES.md (TodoWrite for >3 steps)
5. Generate comprehensive analysis report with actionable recommendations

**Execution Steps**:
1. Parse target and flags from `$ARGUMENTS`
2. Apply TodoWrite for multi-step analysis (per RULES.md)
3. Perform domain-specific analysis based on --focus flag
4. Generate findings with severity ratings
5. Provide actionable recommendations

Execute analysis now.
```

##### 구현 명령어 (implement, build, design)

```markdown
**COMMAND: Implement [Feature Type] with SuperClaude Framework**

Implement feature: `$ARGUMENTS`

**CRITICAL INSTRUCTIONS**:
1. Implement feature specified in `$ARGUMENTS`, NOT the currently open file
2. Parse flags: --type [component|api|service], --framework [name], --test-driven
3. Activate appropriate MCP servers based on task:
   - Context7: For framework-specific patterns
   - Magic: For UI components
   - Sequential: For complex multi-step implementation
4. Follow PRINCIPLES.md (SOLID, DRY, KISS) and RULES.md (Complete implementations, no TODOs)
5. Generate complete, production-ready code

**Execution Steps**:
1. Analyze requirements from `$ARGUMENTS`
2. Plan implementation approach with TodoWrite
3. Generate code with framework best practices
4. Include tests if --test-driven flag present
5. Update documentation

Execute implementation now.
```

##### 테스트 명령어 (test)

```markdown
**COMMAND: Execute Tests with SuperClaude Framework**

Test target: `$ARGUMENTS`

**CRITICAL INSTRUCTIONS**:
1. Test target specified in `$ARGUMENTS`, NOT just the open file
2. Parse flags: --type [unit|integration|e2e], --coverage, --watch
3. If --type e2e: Activate Playwright MCP for browser testing
4. Follow RULES.md (Run tests, don't skip validation)
5. Generate comprehensive test report

**Execution Steps**:
1. Discover tests in target from `$ARGUMENTS`
2. Configure test environment
3. Execute tests with appropriate runner
4. Generate coverage report
5. Provide failure analysis if needed

Execute tests now.
```

##### 문서화 명령어 (document, explain, index)

```markdown
**COMMAND: Generate Documentation with SuperClaude Framework**

Document target: `$ARGUMENTS`

**CRITICAL INSTRUCTIONS**:
1. Document target specified in `$ARGUMENTS`
2. Parse flags: --focus [api|user-guide|architecture], --format [markdown|html]
3. Follow PRINCIPLES.md (Clear communication) and RULES.md (Complete documentation)
4. Generate comprehensive, maintainable documentation
5. Save to appropriate location (docs/ directory)

**Execution Steps**:
1. Analyze target from `$ARGUMENTS`
2. Extract key information and structure
3. Generate documentation with examples
4. Format according to --format flag
5. Save to docs directory

Execute documentation generation now.
```

##### 헬프/리스트 명령어 (help, index)

```markdown
**COMMAND: Display [Information Type]**

**IMPORTANT**: Display the information below, NOT analysis of any open files.

[Information content - tables, lists, etc.]

**DO NOT** analyze the currently open file. Simply display this information.
```

---

## 🔧 MCP 서버 매핑 테이블

| 명령어 | 필요 MCP 서버 | 사용 목적 |
|--------|--------------|----------|
| **sc-analyze** | `[sequential-thinking]` | 구조화된 분석, 복잡한 코드 평가 |
| **sc-implement** | `[context7, sequential-thinking, magic]` | 프레임워크 패턴, 구현 계획, UI 생성 |
| **sc-build** | `[]` | 빌드는 기본 도구로 가능 |
| **sc-brainstorm** | `[sequential-thinking]` | 아이디어 생성, 구조화된 사고 |
| **sc-business-panel** | `[sequential-thinking, tavily]` | 비즈니스 분석, 시장 조사 |
| **sc-cleanup** | `[]` | 파일 정리는 기본 도구로 가능 |
| **sc-design** | `[sequential-thinking, context7]` | 시스템 설계, 아키텍처 패턴 |
| **sc-document** | `[context7]` | 문서 패턴, 베스트 프랙티스 |
| **sc-estimate** | `[sequential-thinking]` | 복잡도 계산, 추정 모델 |
| **sc-explain** | `[context7]` | 기술 문서, 개념 설명 |
| **sc-git** | `[]` | Git 명령은 기본 도구로 가능 |
| **sc-help** | `[]` | 정보 표시만 |
| **sc-improve** | `[sequential-thinking]` | 개선 전략 수립, 체계적 리팩토링 |
| **sc-index** | `[]` | 문서 생성은 기본 도구로 가능 |
| **sc-load** | `[]` | 컨텍스트 로딩은 기본 도구로 가능 |
| **sc-pm** | `[]` | 프로젝트 관리는 기본 도구로 가능 |
| **sc-reflect** | `[sequential-thinking]` | 회고, 학습 패턴 분석 |
| **sc-research** | `[tavily, sequential-thinking]` | 웹 검색, 복잡한 리서치 |
| **sc-save** | `[]` | 세션 저장은 기본 도구로 가능 |
| **sc-select-tool** | `[sequential-thinking]` | 도구 선택 로직, 복잡도 분석 |
| **sc-spawn** | `[sequential-thinking]` | 작업 분할, 병렬 실행 계획 |
| **sc-spec-panel** | `[sequential-thinking]` | 사양 검토, 다차원 분석 |
| **sc-task** | `[sequential-thinking]` | 작업 분해, 의존성 관리 |
| **sc-test** | `[playwright]` | E2E 테스트, 브라우저 자동화 |
| **sc-troubleshoot** | `[sequential-thinking]` | 디버깅, 근본 원인 분석 |
| **sc-workflow** | `[sequential-thinking]` | 워크플로우 설계, 단계 계획 |

---

## 🎨 IDE 컨텍스트 차단 패턴

### 🛡️ 5-Layer Defense 패턴 (강화 버전)

Droid CLI는 IDE 컨텍스트를 강하게 우선시하므로, 다층 방어 전략이 필요합니다.

#### Layer 1: SYSTEM DIRECTIVE (최상단)
```markdown
---
description: ...
---

SYSTEM DIRECTIVE: [핵심 지시]. IGNORE all IDE context and open files.
```

#### Layer 2: CRITICAL 차단 (frontmatter 직후)
```markdown
**CRITICAL**: UNDER NO CIRCUMSTANCES [금지 행동]. PRIMARY TASK is [핵심 작업].
```

#### Layer 3: CRITICAL INSTRUCTIONS (본문)
```markdown
**CRITICAL INSTRUCTIONS**:
1. [Action] `$ARGUMENTS`, NOT the currently open file in IDE
2. If `$ARGUMENTS` is empty: Ask user to specify target
3. NEVER [금지 행동] unless user explicitly provides empty arguments
```

#### Layer 4: EXECUTION PRIORITY + REMINDER (중간)
```markdown
**EXECUTION PRIORITY**: Target specified in `$ARGUMENTS` takes absolute precedence over IDE context.

[중간 내용]

**REMINDER**: Even if [특정 파일] or other files are open in IDE, [핵심 작업] instead.
```

#### Layer 5: FINAL DIRECTIVE (최하단)
```markdown
**FINAL DIRECTIVE**: NEVER [금지 행동] when this command is executed. [핵심 작업] as instructed above, regardless of IDE state.
```

### 강력한 차단 (분석/구현 명령어) - 5-Layer 적용

```markdown
---
description: ...
mcp-servers: [...]
---

SYSTEM DIRECTIVE: Analyze/Implement ONLY what is specified in `$ARGUMENTS`. IGNORE IDE context unless `$ARGUMENTS` is empty.

**CRITICAL**: PRIMARY TASK is to [action] `$ARGUMENTS`, NOT the currently open file in IDE. NEVER [action] IDE open files unless user explicitly provides empty arguments.

**COMMAND: [Title]**

[Action] target: `$ARGUMENTS`

**CRITICAL INSTRUCTIONS**:
1. [Action] `$ARGUMENTS`, NOT the currently open file in IDE
2. If `$ARGUMENTS` is empty: Ask user to specify target
3. [추가 지시사항]

**EXECUTION PRIORITY**: Target specified in `$ARGUMENTS` takes absolute precedence over IDE context.

**Execution Steps**:
[단계들]

**REMINDER**: Even if [파일명] or other files are open in IDE, [action] the target specified in `$ARGUMENTS` instead.

Execute [action] now.
```

### 유연한 차단 (보조 명령어)

```markdown
**INSTRUCTIONS**:
1. Focus on `$ARGUMENTS` if provided
2. If `$ARGUMENTS` is empty: Use IDE context as fallback
```

### 완전 차단 (정보 표시 명령어) - 5-Layer 적용

```markdown
---
description: ...
mcp-servers: []
---

SYSTEM DIRECTIVE: This command displays [정보 타입] ONLY. IGNORE all IDE context and open files.

**CRITICAL**: UNDER NO CIRCUMSTANCES analyze any files. This is a [목적] command that shows [내용].

**COMMAND: Display [Title]**

**IMPORTANT**: Display the [정보 타입] below, NOT analysis of any open files.

## [정보 제목]

[정보 내용]

**REMINDER**: Even if files are open in IDE, display this [정보 타입] instead of analyzing files.

[나머지 정보]

**FINAL DIRECTIVE**: NEVER analyze open files when this command is executed. Display [정보 타입] as instructed above, regardless of IDE state.
```

---

## 🏗️ $ARGUMENTS 사용 패턴

### 기본 패턴

```markdown
[Action] target: `$ARGUMENTS`
```

### 조건부 패턴

```markdown
**If `$ARGUMENTS` is provided**: [Action on $ARGUMENTS]
**If `$ARGUMENTS` is empty**: [Fallback action or ask user]
```

### 플래그 파싱 패턴

```markdown
Parse flags from `$ARGUMENTS`:
- `--flag1 [value]`: [Description]
- `--flag2`: [Description]
- `--flag3 [option1|option2]`: [Description]
```

---

## 📋 프레임워크 규칙 참조 패턴

### 표준 참조

```markdown
Follow PRINCIPLES.md and RULES.md from AGENTS.md
```

### 구체적 참조

```markdown
Follow SuperClaude Framework rules:
- PRINCIPLES.md: Evidence > assumptions, SOLID, DRY
- RULES.md: TodoWrite for >3 steps, Complete implementations
- FLAGS.md: --seq activates Sequential MCP, --think-hard for deep analysis
```

### 선택적 참조

```markdown
Apply relevant rules from AGENTS.md:
- Quality: PRINCIPLES.md guidelines
- Process: RULES.md workflow rules
- Tools: FLAGS.md MCP activation
```

---

## ✅ 변환 체크리스트

### YAML Frontmatter
- [ ] `description` 명확하고 실행 중심
- [ ] `argument-hint` 사용법 명시
- [ ] `mcp-servers` 실제 필요 서버만 포함

### 본문 구조
- [ ] **COMMAND:** 명령형 제목
- [ ] `$ARGUMENTS` 명시적 사용
- [ ] **CRITICAL INSTRUCTIONS** 섹션 있음
- [ ] IDE 컨텍스트 차단 지시
- [ ] 플래그 파싱 로직 명시
- [ ] 프레임워크 규칙 참조
- [ ] "Execute [action] now" 마무리

### 실행 지시
- [ ] 명령형 동사 사용 (Analyze, Implement, Execute)
- [ ] 구체적 실행 단계 제시
- [ ] 조건부 로직 명확
- [ ] 에러 처리 안내

---

## 🔄 변환 프로세스

### 단계 1: YAML Frontmatter
1. description 추출 및 개선
2. argument-hint 작성
3. mcp-servers 매핑 테이블 참조하여 설정

### 단계 2: 명령형 제목
1. 명령어 동작 파악
2. "COMMAND: [Verb] [Object]" 형식 작성

### 단계 3: $ARGUMENTS 통합
1. 타겟 지정: `$ARGUMENTS`
2. 조건부 로직 추가
3. 플래그 파싱 명시

### 단계 4: CRITICAL INSTRUCTIONS
1. $ARGUMENTS 우선 처리
2. IDE 컨텍스트 차단
3. 플래그 파싱
4. 프레임워크 규칙
5. 실행 지시

### 단계 5: 실행 단계
1. Behavioral Flow에서 핵심 단계 추출
2. 명령형 문장으로 변환
3. 순서대로 나열

### 단계 6: 마무리
1. "Execute [action] now." 추가
2. 전체 검토
3. 테스트

---

## 📝 예시: sc-analyze.md 변환

### Before (Claude Code 형식)

```markdown
---
name: analyze
description: "Comprehensive code analysis"
category: utility
complexity: basic
mcp-servers: []
personas: []
---

# /sc:analyze - Code Analysis

## Triggers
- Code quality assessment requests
...

## Behavioral Flow
1. **Discover**: Categorize source files
2. **Scan**: Apply analysis techniques
...
```

### After (Droid CLI 형식)

```markdown
---
description: Comprehensive code analysis across quality, security, performance, architecture
argument-hint: <target> [--focus domain] [--depth level]
mcp-servers: [sequential-thinking]
---

**COMMAND: Analyze Code with SuperClaude Framework**

Analyze target: `$ARGUMENTS`

**CRITICAL INSTRUCTIONS**:
1. Analyze `$ARGUMENTS`, NOT the currently open file in IDE
2. Parse flags: --focus [quality|security|performance|architecture], --depth [quick|deep], --seq, --think-hard
3. If --seq or --think-hard: Activate Sequential MCP for structured analysis
4. Follow PRINCIPLES.md (Evidence > assumptions) and RULES.md (TodoWrite for >3 steps)
5. Generate comprehensive analysis report with actionable recommendations

**Execution Steps**:
1. Parse target and flags from `$ARGUMENTS`
2. Apply TodoWrite for multi-step analysis (per RULES.md)
3. Perform domain-specific analysis based on --focus flag
4. Generate findings with severity ratings
5. Provide actionable recommendations

Execute analysis now.
```

---

**작성자**: Claude (Sonnet 4.5)
**버전**: 1.0
**다음 업데이트**: 핵심 5개 파일 변환 완료 후
