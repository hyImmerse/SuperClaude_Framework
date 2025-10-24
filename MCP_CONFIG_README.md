# Droid CLI MCP 서버 설정 가이드

## 📁 파일 위치

이 설정 파일은 다음 위치에 복사해야 합니다:
```
~/.factory/mcp.json
```

## 📋 설정된 MCP 서버 (8개)

### 1. Sequential Thinking
**패키지**: `@modelcontextprotocol/server-sequential-thinking`
**용도**: 복잡한 다단계 추론 및 구조적 사고
**환경 변수**: 불필요

### 2. Context7
**패키지**: `@upstash/context7-mcp`
**용도**: 공식 라이브러리 문서 검색
**환경 변수**: ⚠️ **필수 설정 필요**
- `UPSTASH_REDIS_REST_URL`: Upstash Redis URL
- `UPSTASH_REDIS_REST_TOKEN`: Upstash Redis 토큰

**설정 방법**:
1. [Upstash](https://upstash.com/) 가입 및 Redis 데이터베이스 생성
2. REST API URL과 토큰 복사
3. `~/.factory/mcp.json`에서 빈 문자열을 실제 값으로 교체

### 3. Magic
**패키지**: `@21st-dev/magic`
**용도**: UI 컴포넌트 생성 (21st.dev)
**환경 변수**: 불필요

### 4. Playwright
**패키지**: `@executeautomation/playwright-mcp-server`
**용도**: 브라우저 자동화 및 E2E 테스트
**환경 변수**: 불필요

### 5. Serena
**패키지**: `@serenaai/mcp-server`
**용도**: 코드베이스 의미 이해 및 세션 저장
**환경 변수**: 불필요

### 6. Tavily
**패키지**: `@tavily/mcp-server`
**용도**: 웹 검색 및 실시간 정보
**환경 변수**: ⚠️ **필수 설정 필요**
- `TAVILY_API_KEY`: Tavily API 키

**설정 방법**:
1. [Tavily](https://app.tavily.com/) 가입
2. API 키 생성
3. `~/.factory/mcp.json`에서 빈 문자열을 API 키로 교체

### 7. Chrome DevTools
**패키지**: `@modelcontextprotocol/server-chrome-devtools`
**용도**: 브라우저 성능 분석 및 디버깅
**환경 변수**: 불필요

### 8. Morphllm
**패키지**: `@morphllm/mcp-server`
**용도**: 패턴 기반 코드 편집
**환경 변수**: 불필요

## 🔧 설정 방법

### 1. 파일 복사
```bash
cp factory-mcp.json ~/.factory/mcp.json
```

### 2. 환경 변수 설정

파일을 편집기로 엽니다:
```bash
vim ~/.factory/mcp.json
# 또는
nano ~/.factory/mcp.json
```

**Context7 설정 예시**:
```json
"context7": {
  "command": "npx",
  "args": ["-y", "@upstash/context7-mcp"],
  "env": {
    "UPSTASH_REDIS_REST_URL": "https://your-redis-url.upstash.io",
    "UPSTASH_REDIS_REST_TOKEN": "AYakAAIjcDExxx..."
  },
  "disabled": false
}
```

**Tavily 설정 예시**:
```json
"tavily": {
  "command": "npx",
  "args": ["-y", "@tavily/mcp-server"],
  "env": {
    "TAVILY_API_KEY": "tvly-xxxxxxxxxx"
  },
  "disabled": false
}
```

### 3. JSON 유효성 검증

설정 파일이 올바른지 확인:
```bash
# jq가 설치되어 있는 경우
jq empty ~/.factory/mcp.json && echo "✅ JSON 유효" || echo "❌ JSON 오류"

# Python이 설치되어 있는 경우
python3 -m json.tool ~/.factory/mcp.json > /dev/null && echo "✅ JSON 유효" || echo "❌ JSON 오류"
```

### 4. Droid 재시작

설정을 적용하려면 Droid를 재시작합니다:
```bash
# Droid 프로세스 종료
pkill droid

# Droid 재실행
droid
```

## 🎛️ MCP 서버 관리

### Droid CLI 내에서 관리

```bash
# MCP 서버 목록 확인
/mcp list

# 특정 서버 활성화
/mcp enable sequential-thinking

# 특정 서버 비활성화
/mcp disable sequential-thinking

# 서버 제거
/mcp remove sequential-thinking
```

### 파일에서 직접 비활성화

`mcp.json` 파일에서 `disabled` 필드를 `true`로 설정:
```json
"sequential-thinking": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
  "disabled": true  // 비활성화
}
```

## 🔍 트러블슈팅

### 문제 1: MCP 서버 연결 실패

**증상**: MCP 도구를 사용할 수 없다는 오류

**해결**:
```bash
# Droid 내에서
/mcp list

# 서버가 disabled 상태인지 확인
# disabled: true이면 활성화
/mcp enable [서버이름]
```

### 문제 2: 환경 변수 인증 오류

**증상**: Context7, Tavily 사용 시 인증 실패

**해결**:
1. `~/.factory/mcp.json` 파일 확인
2. 환경 변수가 빈 문자열(`""`)인지 확인
3. 실제 API 키로 교체
4. Droid 재시작

### 문제 3: JSON 파싱 오류

**증상**: Droid 시작 시 mcp.json 파싱 실패

**해결**:
```bash
# JSON 문법 검증
jq empty ~/.factory/mcp.json

# 오류가 있으면 수정
# 주의: 쉼표, 따옴표, 중괄호 확인
```

### 문제 4: npx 명령어 오류 (Windows)

**증상**: Windows에서 npx 실행 실패

**해결**:
```json
// Windows용 설정
"sequential-thinking": {
  "command": "cmd",
  "args": ["/c", "npx", "-y", "@modelcontextprotocol/server-sequential-thinking"],
  "disabled": false
}
```

## 📊 서버 선택 가이드

| 작업 유형 | 추천 MCP 서버 |
|---------|-------------|
| 복잡한 분석 | Sequential Thinking |
| 라이브러리 문서 | Context7 |
| UI 컴포넌트 생성 | Magic |
| 브라우저 테스트 | Playwright |
| 웹 검색 | Tavily |
| 성능 분석 | Chrome DevTools |
| 대량 코드 편집 | Morphllm |
| 프로젝트 메모리 | Serena |

## 🔐 보안 주의사항

1. **API 키 노출 방지**
   - `mcp.json` 파일을 Git에 커밋하지 마세요
   - `.gitignore`에 추가 권장: `~/.factory/mcp.json`

2. **파일 권한 설정**
   ```bash
   chmod 600 ~/.factory/mcp.json
   ```

3. **백업**
   ```bash
   cp ~/.factory/mcp.json ~/.factory/mcp.json.backup
   ```

## 📚 추가 리소스

- **Context7 문서**: https://github.com/upstash/context7-mcp
- **Tavily 문서**: https://tavily.com/docs
- **Droid CLI 문서**: https://docs.factory.ai/cli/
- **MCP 프로토콜**: https://modelcontextprotocol.io/

## ✅ 검증 체크리스트

설정 완료 후 확인:

- [ ] `~/.factory/mcp.json` 파일 존재
- [ ] JSON 문법 유효 (`jq empty ~/.factory/mcp.json`)
- [ ] Context7 환경 변수 설정 (사용하는 경우)
- [ ] Tavily API 키 설정 (사용하는 경우)
- [ ] Droid 재시작 완료
- [ ] `/mcp list`에서 8개 서버 확인
- [ ] 테스트 명령어 실행 성공

## 🎯 다음 단계

1. ✅ MCP 설정 완료
2. ⏭️ AGENTS.md 생성
3. ⏭️ SuperClaude 명령어 테스트
4. ⏭️ 프로젝트 초기화 및 사용 시작

---

**작성일**: 2025-10-25
**버전**: 1.0
**관련 파일**: factory-mcp.json
