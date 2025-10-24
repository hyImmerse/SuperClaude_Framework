#!/usr/bin/env bash

################################################################################
# SuperClaude → Droid CLI 자동 포팅 스크립트
#
# 목적: SuperClaude_Framework를 Droid CLI로 안전하게 포팅
# 버전: 1.0
# 작성일: 2025-10-25
################################################################################

set -e  # 에러 발생 시 즉시 종료
set -u  # 미정의 변수 사용 시 에러
set -o pipefail  # 파이프라인 에러 감지

################################################################################
# 전역 변수
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/.factory-backup-$TIMESTAMP"
LOG_FILE="$SCRIPT_DIR/migration-$TIMESTAMP.log"

# 소스 디렉토리
SOURCE_BASE="$HOME/.claude"
SOURCE_COMMANDS="$SOURCE_BASE/commands/sc"

# 타겟 디렉토리
TARGET_BASE="$HOME/.factory"
TARGET_COMMANDS="$TARGET_BASE/commands/sc"
TARGET_SUPERCLAUDE="$TARGET_BASE/superclaude"

# 파일 개수
EXPECTED_COMMANDS=26
EXPECTED_MODES=7
EXPECTED_FRAMEWORK=6
EXPECTED_MCP=7

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 드라이런 모드
DRY_RUN=false

################################################################################
# 유틸리티 함수
################################################################################

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}ℹ${NC} $*"
    log "INFO" "$*"
}

success() {
    echo -e "${GREEN}✅${NC} $*"
    log "SUCCESS" "$*"
}

warning() {
    echo -e "${YELLOW}⚠️${NC} $*"
    log "WARNING" "$*"
}

error() {
    echo -e "${RED}❌${NC} $*" >&2
    log "ERROR" "$*"
}

fatal() {
    error "$*"
    error "포팅 실패. 롤백을 시작합니다..."
    rollback
    exit 1
}

progress() {
    local current=$1
    local total=$2
    local message=$3
    local percent=$((current * 100 / total))
    echo -ne "\r${BLUE}⏳${NC} 진행: [$current/$total] $percent% - $message"
    if [ "$current" -eq "$total" ]; then
        echo ""  # 줄바꿈
    fi
}

################################################################################
# 검증 함수
################################################################################

check_prerequisites() {
    info "사전 조건 확인 중..."

    # Bash 버전 확인 (4.0 이상)
    if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
        fatal "Bash 4.0 이상이 필요합니다. 현재 버전: ${BASH_VERSION}"
    fi

    # 필수 명령어 확인
    local required_commands=("sed" "cp" "mkdir" "ls" "wc" "grep")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            fatal "필수 명령어 '$cmd'를 찾을 수 없습니다."
        fi
    done

    # SuperClaude 설치 확인
    if [ ! -d "$SOURCE_BASE" ]; then
        fatal "SuperClaude가 설치되지 않았습니다: $SOURCE_BASE"
    fi

    if [ ! -d "$SOURCE_COMMANDS" ]; then
        fatal "SuperClaude 명령어 디렉토리를 찾을 수 없습니다: $SOURCE_COMMANDS"
    fi

    # 슬래시 명령어 개수 확인
    local cmd_count=$(find "$SOURCE_COMMANDS" -name "*.md" -type f | wc -l)
    if [ "$cmd_count" -ne "$EXPECTED_COMMANDS" ]; then
        warning "예상 명령어 개수($EXPECTED_COMMANDS)와 다릅니다: $cmd_count개 발견"
    fi

    # Droid CLI 설치 확인
    if ! command -v droid &> /dev/null; then
        warning "Droid CLI가 설치되지 않았습니다. 계속하시겠습니까?"
        if [ "$DRY_RUN" = false ]; then
            read -p "계속하려면 'yes'를 입력하세요: " confirm
            if [ "$confirm" != "yes" ]; then
                fatal "사용자가 취소했습니다."
            fi
        fi
    fi

    # 디스크 공간 확인 (최소 10MB)
    local available=$(df -k "$HOME" | awk 'NR==2 {print $4}')
    if [ "$available" -lt 10240 ]; then
        fatal "디스크 공간이 부족합니다. 최소 10MB 필요"
    fi

    success "사전 조건 확인 완료"
}

check_source_files() {
    info "소스 파일 존재 여부 확인 중..."

    local missing_files=0

    # 명령어 파일 확인
    if [ ! -d "$SOURCE_COMMANDS" ]; then
        error "명령어 디렉토리 없음: $SOURCE_COMMANDS"
        ((missing_files++))
    fi

    # MODE 파일 확인
    local mode_count=$(find "$SOURCE_BASE" -maxdepth 1 -name "MODE_*.md" -type f | wc -l)
    if [ "$mode_count" -ne "$EXPECTED_MODES" ]; then
        warning "MODE 파일 개수 불일치: $mode_count/$EXPECTED_MODES"
    fi

    # 프레임워크 파일 확인
    local framework_files=("PRINCIPLES.md" "RULES.md" "FLAGS.md" "RESEARCH_CONFIG.md" "BUSINESS_SYMBOLS.md" "BUSINESS_PANEL_EXAMPLES.md")
    for file in "${framework_files[@]}"; do
        if [ ! -f "$SOURCE_BASE/$file" ]; then
            warning "프레임워크 파일 없음: $file"
            ((missing_files++))
        fi
    done

    # MCP 문서 확인
    local mcp_count=$(find "$SOURCE_BASE" -maxdepth 1 -name "MCP_*.md" -type f | wc -l)
    if [ "$mcp_count" -ne "$EXPECTED_MCP" ]; then
        warning "MCP 문서 개수 불일치: $mcp_count/$EXPECTED_MCP"
    fi

    if [ "$missing_files" -gt 0 ]; then
        warning "$missing_files 개의 파일이 누락되었습니다. 계속하시겠습니까?"
        if [ "$DRY_RUN" = false ]; then
            read -p "계속하려면 'yes'를 입력하세요: " confirm
            if [ "$confirm" != "yes" ]; then
                fatal "사용자가 취소했습니다."
            fi
        fi
    fi

    success "소스 파일 확인 완료"
}

################################################################################
# 백업 및 롤백 함수
################################################################################

create_backup() {
    info "기존 설정 백업 중..."

    if [ ! -d "$TARGET_BASE" ]; then
        info "기존 Droid 설정 없음. 백업 건너뛰기."
        return 0
    fi

    if [ "$DRY_RUN" = true ]; then
        info "[DRY RUN] 백업 디렉토리 생성: $BACKUP_DIR"
        return 0
    fi

    mkdir -p "$BACKUP_DIR"

    # ~/.factory/ 전체 백업
    if cp -r "$TARGET_BASE"/* "$BACKUP_DIR/" 2>/dev/null; then
        success "백업 완료: $BACKUP_DIR"
        log "INFO" "백업 크기: $(du -sh "$BACKUP_DIR" | cut -f1)"
    else
        warning "백업할 파일이 없거나 백업 실패"
    fi
}

rollback() {
    if [ ! -d "$BACKUP_DIR" ]; then
        error "백업 디렉토리를 찾을 수 없습니다: $BACKUP_DIR"
        return 1
    fi

    warning "롤백 진행 중..."

    # 생성된 디렉토리 삭제
    rm -rf "$TARGET_COMMANDS" "$TARGET_SUPERCLAUDE" 2>/dev/null || true

    # 백업 복원
    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR")" ]; then
        cp -r "$BACKUP_DIR"/* "$TARGET_BASE/" 2>/dev/null || true
        success "백업에서 복원 완료"
    fi
}

################################################################################
# 디렉토리 생성 함수
################################################################################

create_directories() {
    info "디렉토리 구조 생성 중..."

    local directories=(
        "$TARGET_COMMANDS"
        "$TARGET_SUPERCLAUDE/modes"
        "$TARGET_SUPERCLAUDE/framework"
        "$TARGET_SUPERCLAUDE/mcp"
    )

    if [ "$DRY_RUN" = true ]; then
        for dir in "${directories[@]}"; do
            info "[DRY RUN] 디렉토리 생성: $dir"
        done
        return 0
    fi

    local count=0
    local total=${#directories[@]}

    for dir in "${directories[@]}"; do
        ((count++))
        progress $count $total "$(basename "$dir") 생성 중..."

        if mkdir -p "$dir"; then
            log "INFO" "디렉토리 생성: $dir"
        else
            fatal "디렉토리 생성 실패: $dir"
        fi
    done

    success "디렉토리 구조 생성 완료"
}

################################################################################
# 파일 복사 및 변환 함수
################################################################################

convert_command_files() {
    info "슬래시 명령어 파일 변환 중..."

    if [ ! -d "$SOURCE_COMMANDS" ]; then
        fatal "소스 명령어 디렉토리 없음: $SOURCE_COMMANDS"
    fi

    local files=("$SOURCE_COMMANDS"/*.md)
    local total=${#files[@]}
    local count=0
    local converted=0
    local failed=0

    for source_file in "${files[@]}"; do
        ((count++))
        local filename=$(basename "$source_file")
        local target_file="$TARGET_COMMANDS/$filename"

        if [ "$DRY_RUN" = false ]; then
            progress $count $total "$filename"
        fi

        if [ "$DRY_RUN" = true ]; then
            info "[DRY RUN] 변환: $filename"
            ((converted++))
            continue
        fi

        # 텍스트 치환: Claude Code → Droid CLI, ~/.claude/ → ~/.factory/
        if sed 's/Claude Code/Droid CLI/g; s|~/.claude/|~/.factory/|g' \
            "$source_file" > "$target_file"; then
            ((converted++))
            log "INFO" "변환 완료: $filename"
        else
            error "변환 실패: $filename"
            ((failed++))
        fi
    done

    echo ""  # 진행 바 줄바꿈

    if [ $failed -gt 0 ]; then
        fatal "$failed 개 파일 변환 실패"
    fi

    success "명령어 파일 변환 완료: $converted/$total"
}

copy_mode_files() {
    info "모드 파일 복사 중..."

    local files=("$SOURCE_BASE"/MODE_*.md)
    local total=${#files[@]}
    local count=0
    local copied=0

    for source_file in "${files[@]}"; do
        ((count++))
        local filename=$(basename "$source_file")

        if [ "$DRY_RUN" = false ]; then
            progress $count $total "$filename"
        fi

        if [ "$DRY_RUN" = true ]; then
            info "[DRY RUN] 복사: $filename"
            ((copied++))
            continue
        fi

        if cp "$source_file" "$TARGET_SUPERCLAUDE/modes/"; then
            ((copied++))
            log "INFO" "복사 완료: $filename"
        else
            error "복사 실패: $filename"
        fi
    done

    echo ""

    success "모드 파일 복사 완료: $copied/$EXPECTED_MODES"
}

copy_framework_files() {
    info "프레임워크 문서 복사 중..."

    local framework_files=(
        "PRINCIPLES.md"
        "RULES.md"
        "FLAGS.md"
        "RESEARCH_CONFIG.md"
        "BUSINESS_SYMBOLS.md"
        "BUSINESS_PANEL_EXAMPLES.md"
    )

    local total=${#framework_files[@]}
    local count=0
    local copied=0

    for file in "${framework_files[@]}"; do
        ((count++))

        if [ "$DRY_RUN" = false ]; then
            progress $count $total "$file"
        fi

        if [ "$DRY_RUN" = true ]; then
            info "[DRY RUN] 복사: $file"
            ((copied++))
            continue
        fi

        local source_file="$SOURCE_BASE/$file"

        if [ -f "$source_file" ]; then
            if cp "$source_file" "$TARGET_SUPERCLAUDE/framework/"; then
                ((copied++))
                log "INFO" "복사 완료: $file"
            else
                error "복사 실패: $file"
            fi
        else
            warning "파일 없음: $file"
        fi
    done

    echo ""

    success "프레임워크 문서 복사 완료: $copied/$EXPECTED_FRAMEWORK"
}

copy_mcp_files() {
    info "MCP 문서 복사 중..."

    local files=("$SOURCE_BASE"/MCP_*.md)
    local total=${#files[@]}
    local count=0
    local copied=0

    for source_file in "${files[@]}"; do
        ((count++))
        local filename=$(basename "$source_file")

        if [ "$DRY_RUN" = false ]; then
            progress $count $total "$filename"
        fi

        if [ "$DRY_RUN" = true ]; then
            info "[DRY RUN] 복사: $filename"
            ((copied++))
            continue
        fi

        if cp "$source_file" "$TARGET_SUPERCLAUDE/mcp/"; then
            ((copied++))
            log "INFO" "복사 완료: $filename"
        else
            error "복사 실패: $filename"
        fi
    done

    echo ""

    success "MCP 문서 복사 완료: $copied/$EXPECTED_MCP"
}

################################################################################
# 권한 설정 함수
################################################################################

set_permissions() {
    info "파일 권한 설정 중..."

    if [ "$DRY_RUN" = true ]; then
        info "[DRY RUN] 권한 설정 건너뛰기"
        return 0
    fi

    # .md 파일: 644 (rw-r--r--)
    find "$TARGET_COMMANDS" "$TARGET_SUPERCLAUDE" -type f -name "*.md" -exec chmod 644 {} \; 2>/dev/null || true

    # mcp.json이 있다면: 600 (rw-------)
    if [ -f "$TARGET_BASE/mcp.json" ]; then
        chmod 600 "$TARGET_BASE/mcp.json"
    fi

    success "권한 설정 완료"
}

################################################################################
# 검증 함수
################################################################################

verify_migration() {
    info "포팅 결과 검증 중..."

    local errors=0

    # 1. 디렉토리 존재 확인
    local required_dirs=(
        "$TARGET_COMMANDS"
        "$TARGET_SUPERCLAUDE/modes"
        "$TARGET_SUPERCLAUDE/framework"
        "$TARGET_SUPERCLAUDE/mcp"
    )

    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            error "디렉토리 없음: $dir"
            ((errors++))
        fi
    done

    # 2. 파일 개수 확인
    local cmd_count=$(find "$TARGET_COMMANDS" -name "*.md" -type f 2>/dev/null | wc -l)
    local mode_count=$(find "$TARGET_SUPERCLAUDE/modes" -name "*.md" -type f 2>/dev/null | wc -l)
    local framework_count=$(find "$TARGET_SUPERCLAUDE/framework" -name "*.md" -type f 2>/dev/null | wc -l)
    local mcp_count=$(find "$TARGET_SUPERCLAUDE/mcp" -name "*.md" -type f 2>/dev/null | wc -l)

    info "파일 개수:"
    echo "  명령어: $cmd_count / $EXPECTED_COMMANDS"
    echo "  모드: $mode_count / $EXPECTED_MODES"
    echo "  프레임워크: $framework_count / $EXPECTED_FRAMEWORK"
    echo "  MCP: $mcp_count / $EXPECTED_MCP"

    if [ "$cmd_count" -ne "$EXPECTED_COMMANDS" ]; then
        warning "명령어 파일 개수 불일치"
    fi

    # 3. 텍스트 치환 확인
    if [ "$DRY_RUN" = false ]; then
        local claude_count=$(grep -r "Claude Code" "$TARGET_COMMANDS" 2>/dev/null | wc -l)
        local droid_count=$(grep -r "Droid CLI" "$TARGET_COMMANDS" 2>/dev/null | wc -l)

        if [ "$claude_count" -gt 0 ]; then
            error "텍스트 치환 미완료: 'Claude Code' $claude_count개 발견"
            ((errors++))
        else
            success "텍스트 치환 완료: 'Claude Code' 미존재"
        fi

        if [ "$droid_count" -eq 0 ]; then
            error "'Droid CLI' 문자열이 발견되지 않음"
            ((errors++))
        fi
    fi

    if [ $errors -gt 0 ]; then
        error "검증 실패: $errors 개 오류"
        return 1
    fi

    success "검증 완료: 모든 검사 통과"
    return 0
}

################################################################################
# 요약 출력 함수
################################################################################

print_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}✅ SuperClaude → Droid 포팅 완료${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📁 생성된 디렉토리:"
    echo "  • ~/.factory/commands/sc/"
    echo "  • ~/.factory/superclaude/modes/"
    echo "  • ~/.factory/superclaude/framework/"
    echo "  • ~/.factory/superclaude/mcp/"
    echo ""
    echo "📝 복사된 파일:"
    echo "  • 슬래시 명령어: $(find "$TARGET_COMMANDS" -name "*.md" 2>/dev/null | wc -l)개"
    echo "  • 모드 파일: $(find "$TARGET_SUPERCLAUDE/modes" -name "*.md" 2>/dev/null | wc -l)개"
    echo "  • 프레임워크: $(find "$TARGET_SUPERCLAUDE/framework" -name "*.md" 2>/dev/null | wc -l)개"
    echo "  • MCP 문서: $(find "$TARGET_SUPERCLAUDE/mcp" -name "*.md" 2>/dev/null | wc -l)개"
    echo ""

    if [ -d "$BACKUP_DIR" ]; then
        echo "💾 백업 위치: $BACKUP_DIR"
        echo ""
    fi

    echo "📋 다음 단계:"
    echo "  1. MCP 서버 설정: ~/.factory/mcp.json 생성"
    echo "  2. AGENTS.md 생성: ~/.factory/AGENTS.md"
    echo "  3. API 키 설정: context7, tavily 환경 변수"
    echo "  4. Droid 재시작: pkill droid && droid"
    echo "  5. 명령어 테스트: /sc:help"
    echo ""
    echo "📄 로그 파일: $LOG_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

################################################################################
# 도움말 함수
################################################################################

print_help() {
    cat << EOF
사용법: $0 [옵션]

SuperClaude_Framework를 Droid CLI로 자동 포팅하는 스크립트

옵션:
  -h, --help          이 도움말 표시
  -d, --dry-run       실제 작업 없이 시뮬레이션만 실행
  -v, --verbose       상세 로그 출력
  -y, --yes           모든 확인 프롬프트에 자동으로 'yes' 응답

예시:
  $0                  일반 실행
  $0 --dry-run        드라이런 모드 (시뮬레이션)
  $0 --yes            자동 실행 (프롬프트 없음)

생성되는 구조:
  ~/.factory/
  ├── commands/sc/              (26개 명령어)
  ├── superclaude/
  │   ├── modes/                (7개 모드)
  │   ├── framework/            (6개 프레임워크)
  │   └── mcp/                  (7개 MCP 문서)
  └── [mcp.json, AGENTS.md는 별도 생성 필요]

백업:
  기존 ~/.factory/ 내용은 ~/.factory-backup-YYYYMMDD-HHMMSS/에 백업됩니다.

로그:
  실행 로그는 migration-YYYYMMDD-HHMMSS.log에 저장됩니다.

EOF
}

################################################################################
# 메인 함수
################################################################################

main() {
    # 인자 파싱
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                print_help
                exit 0
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            -y|--yes)
                # 자동 yes 모드 (향후 구현)
                shift
                ;;
            *)
                error "알 수 없는 옵션: $1"
                print_help
                exit 1
                ;;
        esac
    done

    # 헤더 출력
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  SuperClaude → Droid CLI 자동 포팅 스크립트"
    echo "  버전: 1.0"
    echo "  날짜: $(date '+%Y-%m-%d %H:%M:%S')"
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}모드: DRY RUN (시뮬레이션)${NC}"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # 로그 파일 초기화
    echo "=== SuperClaude → Droid 포팅 로그 ===" > "$LOG_FILE"
    log "INFO" "스크립트 시작"

    # 실행 단계
    check_prerequisites
    check_source_files
    create_backup
    create_directories
    convert_command_files
    copy_mode_files
    copy_framework_files
    copy_mcp_files
    set_permissions

    # 검증
    if verify_migration; then
        print_summary
        log "INFO" "포팅 성공"
        exit 0
    else
        fatal "검증 실패"
    fi
}

################################################################################
# 스크립트 실행
################################################################################

# SIGINT (Ctrl+C) 핸들러
trap 'error "사용자가 중단했습니다."; rollback; exit 130' INT

# 에러 핸들러
trap 'error "스크립트 실행 중 오류 발생 (라인 $LINENO)"; rollback; exit 1' ERR

# 메인 함수 실행
main "$@"
