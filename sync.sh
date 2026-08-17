#!/usr/bin/env bash
# 在新 Mac 上同步本仓库的 Typora 主题与配置。
# 对应 README「迁移到新 Mac」：安装字体、备份默认配置、创建软链接。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${TYPORA_REPO:-$SCRIPT_DIR}"
TYPORA_SUPPORT="${HOME}/Library/Application Support/abnerworks.Typora"
FONT_DIR="${HOME}/Library/Fonts"
REPO_URL="https://github.com/leexeo/Typora.git"

ASSUME_YES=0
DRY_RUN=0
COMMAND=""

LXGW_FILES=(
    "LXGWWenKai-Regular.ttf"
    "LXGWWenKai-Medium.ttf"
    "LXGWWenKaiMono-Regular.ttf"
)

# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------

supports_color() {
    [[ -t 1 ]] || return 1
    [[ -z "${NO_COLOR:-}" ]] || return 1
    [[ "${TERM:-}" != "dumb" ]] || return 1
    return 0
}

init_colors() {
    if supports_color; then
        printf -v BOLD '\033[1m'
        printf -v DIM '\033[2m'
        printf -v GREEN '\033[32m'
        printf -v YELLOW '\033[33m'
        printf -v CYAN '\033[36m'
        printf -v RED '\033[31m'
        printf -v RESET '\033[0m'
    else
        BOLD="" DIM="" GREEN="" YELLOW="" CYAN="" RED="" RESET=""
    fi
}

init_colors

info()    { printf '%b•%b %s\n' "$CYAN" "$RESET" "$*"; }
ok()      { printf '%b✔%b %s\n' "$GREEN" "$RESET" "$*"; }
warn()    { printf '%b!%b %s\n' "$YELLOW" "$RESET" "$*"; }
err()     { printf '%b错误%b %s\n' "$RED" "$RESET" "$*" >&2; }
section() { printf '\n%b%s%b\n' "$BOLD" "$*" "$RESET"; }

die() {
    err "$*"
    exit 1
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

usage() {
    cat <<EOF
${BOLD}sync.sh${RESET} — 在新系统上同步 Typora 主题与配置

${BOLD}用法${RESET}
  ./sync.sh [command] [options]

${BOLD}命令${RESET}
  install    安装字体并创建软链接（默认）
  status     检查字体、软链接和主题状态
  fonts      仅安装所需字体
  link       仅创建配置目录软链接
  extra      将 extra-themes 复制到 themes/，启用可选主题
  help       显示本帮助

${BOLD}选项${RESET}
  -y, --yes       非交互，自动确认备份 / 覆盖 / 退出 Typora
  -n, --dry-run   只打印将要执行的操作
  --repo PATH     指定本仓库路径（默认：脚本所在目录）

${BOLD}示例${RESET}
  git clone ${REPO_URL} ~/Configs/Typora
  cd ~/Configs/Typora
  ./sync.sh
  ./sync.sh status
  ./sync.sh extra
EOF
}

run() {
    if (( DRY_RUN )); then
        info "[dry-run] $*"
        return 0
    fi
    "$@"
}

confirm() {
    local prompt="$1"
    if (( ASSUME_YES )); then
        return 0
    fi
    if [[ ! -t 0 ]]; then
        die "需要确认但当前非交互。请加上 --yes 后重试。"
    fi
    local ans=""
    read -r -p "${prompt} [y/N] " ans
    [[ "${ans}" == [yY] || "${ans}" == yes || "${ans}" == YES ]]
}

require_macos() {
    [[ "$(uname -s)" == "Darwin" ]] || die "本脚本仅支持 macOS（Typora 配置路径按 README 约定）。"
}

require_repo() {
    [[ -d "${REPO_DIR}/themes" ]] || die "未找到 ${REPO_DIR}/themes。请在仓库根目录运行，或用 --repo 指定。"
    [[ -f "${REPO_DIR}/README.md" ]] || warn "未找到 README.md，仍继续。"
}

has_font_file() {
    local name="$1"
    local dir
    for dir in "${FONT_DIR}" "/Library/Fonts"; do
        [[ -e "${dir}/${name}" ]] && return 0
    done
    return 1
}

has_font_glob() {
    local pattern="$1"
    local dir
    shopt -s nullglob
    for dir in "${FONT_DIR}" "/Library/Fonts"; do
        local matches=("${dir}/"${pattern})
        if (( ${#matches[@]} > 0 )); then
            shopt -u nullglob
            return 0
        fi
    done
    shopt -u nullglob
    return 1
}

lxgw_missing() {
    local f
    for f in "${LXGW_FILES[@]}"; do
        has_font_file "$f" || { printf '%s\n' "$f"; }
    done
}

has_jetbrains() {
    has_font_glob "JetBrainsMono*"
}

has_source_han() {
    has_font_glob "SourceHanSans*"
}

typora_installed() {
    [[ -d "/Applications/Typora.app" || -d "${HOME}/Applications/Typora.app" ]]
}

typora_running() {
    pgrep -qx Typora
}

wait_typora_quit() {
    local i
    for i in {1..20}; do
        typora_running || return 0
        sleep 0.25
    done
    return 1
}

quit_typora() {
    typora_running || return 0
    warn "Typora 正在运行，替换配置目录前需要先退出。"
    if ! confirm "现在退出 Typora？"; then
        die "请先手动退出 Typora 后再运行。"
    fi
    if (( DRY_RUN )); then
        info "[dry-run] quit Typora"
        return 0
    fi
    osascript -e 'tell application "Typora" to quit' >/dev/null 2>&1 || true
    if ! wait_typora_quit; then
        killall Typora >/dev/null 2>&1 || true
        wait_typora_quit || die "无法退出 Typora，请手动退出后重试。"
    fi
    ok "已退出 Typora"
}

have_brew() {
    command -v brew >/dev/null 2>&1
}

latest_github_tag() {
    local repo="$1"
    local url
    url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/${repo}/releases/latest")"
    printf '%s\n' "${url##*/}"
}

download_zip_and_copy() {
    local url="$1"
    shift
    local tmp zip_path
    tmp="$(mktemp -d "${TMPDIR:-/tmp}/typora-sync.XXXXXX")"
    zip_path="${tmp}/fonts.zip"
    info "下载 ${url}"
    if (( DRY_RUN )); then
        info "[dry-run] curl + unzip + 复制字体到 ${FONT_DIR}"
        rm -rf "${tmp}"
        return 0
    fi
    curl -fL --retry 3 --retry-delay 1 "$url" -o "${zip_path}"
    unzip -q "${zip_path}" -d "${tmp}"
    mkdir -p "${FONT_DIR}"
    local pattern dest
    for pattern in "$@"; do
        while IFS= read -r -d '' dest; do
            cp -f "${dest}" "${FONT_DIR}/"
            ok "已安装 $(basename "${dest}")"
        done < <(find "${tmp}" -type f -name "${pattern}" -print0)
    done
    rm -rf "${tmp}"
}

install_cask_or_download() {
    local cask="$1"
    shift
    if have_brew; then
        info "Homebrew 安装 ${cask}"
        if (( DRY_RUN )); then
            info "[dry-run] brew install --cask ${cask}"
            return 0
        fi
        if brew install --cask "${cask}"; then
            return 0
        fi
        warn "brew 安装 ${cask} 失败，尝试从 GitHub 下载"
    else
        warn "未检测到 Homebrew，改为从 GitHub 下载字体"
    fi
    "$@"
}

install_lxgw() {
    local missing
    missing="$(lxgw_missing || true)"
    if [[ -z "${missing}" ]]; then
        ok "霞鹜文楷已安装"
        return 0
    fi
    info "缺少霞鹜文楷：$(printf '%s' "${missing}" | tr '\n' ' ')"
    install_cask_or_download font-lxgw-wenkai install_lxgw_from_github
    if [[ -n "$(lxgw_missing || true)" ]] && (( ! DRY_RUN )); then
        die "霞鹜文楷仍未安装完整。请手动把下列文件放到 ${FONT_DIR}/：${missing}"
    fi
}

install_lxgw_from_github() {
    local tag url
    tag="$(latest_github_tag "lxgw/LxgwWenKai")"
    [[ -n "${tag}" ]] || die "无法获取 lxgw/LxgwWenKai 最新版本。"
    url="https://github.com/lxgw/LxgwWenKai/releases/download/${tag}/lxgw-wenkai-${tag}.zip"
    download_zip_and_copy "$url" \
        "LXGWWenKai-Regular.ttf" \
        "LXGWWenKai-Medium.ttf" \
        "LXGWWenKaiMono-Regular.ttf"
}

install_jetbrains() {
    if has_jetbrains; then
        ok "JetBrains Mono 已安装"
        return 0
    fi
    info "缺少 JetBrains Mono（base.user.css 正文/代码字体）"
    install_cask_or_download font-jetbrains-mono install_jetbrains_from_github
    if ! has_jetbrains && (( ! DRY_RUN )); then
        die "JetBrains Mono 安装失败。可执行：brew install --cask font-jetbrains-mono"
    fi
}

install_jetbrains_from_github() {
    local tag ver url
    tag="$(latest_github_tag "JetBrains/JetBrainsMono")"
    [[ -n "${tag}" ]] || die "无法获取 JetBrains/JetBrainsMono 最新版本。"
    ver="${tag#v}"
    url="https://github.com/JetBrains/JetBrainsMono/releases/download/${tag}/JetBrainsMono-${ver}.zip"
    download_zip_and_copy "$url" "JetBrainsMono-Regular.ttf" "JetBrainsMono-Bold.ttf"
}

install_source_han() {
    if has_source_han; then
        ok "思源黑体已安装"
        return 0
    fi
    info "缺少思源黑体 Source Han Sans（base.user.css 中文字体）"
    if have_brew; then
        info "Homebrew 安装 font-source-han-sans-vf"
        run brew install --cask font-source-han-sans-vf
    else
        warn "未检测到 Homebrew，无法自动安装思源黑体。"
        warn "请安装后重试：brew install --cask font-source-han-sans-vf"
        return 0
    fi
    if ! has_source_han && (( ! DRY_RUN )); then
        warn "思源黑体仍未检测到。Typora 会回退到系统中文字体。"
    fi
}

has_pandoc() {
    command -v pandoc >/dev/null 2>&1
}

install_pandoc() {
    if has_pandoc; then
        ok "Pandoc 已安装 ($(pandoc --version | head -n 1 | awk '{print $2}'))"
        return 0
    fi
    info "未检测到 Pandoc（Word/LaTeX 导出依赖）"
    if have_brew; then
        info "Homebrew 安装 pandoc"
        run brew install pandoc
        if has_pandoc; then
            ok "Pandoc 安装成功"
        fi
    else
        warn "未检测到 Homebrew，跳过 Pandoc 自动安装。可手动安装：https://pandoc.org/installing.html"
    fi
}

canonical_path() {
    (cd "$1" && pwd -P)
}

same_path() {
    local a b
    a="$(canonical_path "$1")"
    b="$(canonical_path "$2")"
    [[ -n "$a" && -n "$b" && "$a" == "$b" ]]
}

link_config() {
    mkdir -p "$(dirname "${TYPORA_SUPPORT}")"

    if [[ -L "${TYPORA_SUPPORT}" ]]; then
        local current
        current="$(readlink "${TYPORA_SUPPORT}")"
        if same_path "${TYPORA_SUPPORT}" "${REPO_DIR}"; then
            ok "软链接已就位：${TYPORA_SUPPORT} → ${REPO_DIR}"
            return 0
        fi
        warn "现有软链接指向 ${current}"
        confirm "改为指向本仓库？" || die "已取消。"
        quit_typora
        run rm "${TYPORA_SUPPORT}"
    elif [[ -e "${TYPORA_SUPPORT}" ]]; then
        local backup
        backup="${TYPORA_SUPPORT}.bak.$(date +%Y%m%d-%H%M%S)"
        warn "发现已有 Typora 配置目录，将备份后替换为软链接。"
        info "备份目标：${backup}"
        confirm "备份并替换为指向本仓库的软链接？" || die "已取消。"
        quit_typora
        run mv "${TYPORA_SUPPORT}" "${backup}"
        ok "已备份到 ${backup}"
    fi

    run ln -s "${REPO_DIR}" "${TYPORA_SUPPORT}"
    ok "已创建软链接：${TYPORA_SUPPORT} → ${REPO_DIR}"
}

cmd_fonts() {
    section "安装字体"
    mkdir -p "${FONT_DIR}"
    install_lxgw
    install_jetbrains
    install_source_han
}

cmd_link() {
    section "创建配置软链接"
    link_config
}

cmd_extra() {
    section "启用可选主题"
    local src dest name count=0
    src="${REPO_DIR}/themes/extra-themes"
    [[ -d "${src}" ]] || die "未找到 ${src}"
    shopt -s nullglob
    local files=("${src}"/*.css)
    shopt -u nullglob
    (( ${#files[@]} > 0 )) || die "extra-themes 中没有 .css 文件。"
    for src in "${files[@]}"; do
        name="$(basename "${src}")"
        dest="${REPO_DIR}/themes/${name}"
        if [[ -e "${dest}" ]]; then
            info "已存在，跳过 ${name}"
            continue
        fi
        run cp "${src}" "${dest}"
        if (( DRY_RUN )); then
            info "将启用 ${name%.css}"
        else
            ok "已启用 ${name%.css}"
        fi
        count=$((count + 1))
    done
    if (( count == 0 )); then
        ok "可选主题均已启用"
    elif (( DRY_RUN )); then
        info "将新启用 ${count} 个主题（dry-run，未写入）"
    else
        ok "新启用 ${count} 个主题，重启 Typora 后出现在主题菜单"
    fi
}

list_enabled_themes() {
    local f
    shopt -s nullglob
    for f in "${REPO_DIR}/themes"/*.css; do
        [[ "$(basename "$f")" == "base.user.css" ]] && continue
        printf '%s\n' "$(basename "${f%.css}")"
    done | sort
    shopt -u nullglob
}

list_extra_themes() {
    local f
    shopt -s nullglob
    for f in "${REPO_DIR}/themes/extra-themes"/*.css; do
        printf '%s\n' "$(basename "${f%.css}")"
    done | sort
    shopt -u nullglob
}

cmd_status() {
    local missing theme extra dest
    section "状态"

    printf '%b仓库%b    %s\n' "$BOLD" "$RESET" "${REPO_DIR}"
    printf '%b配置目录%b %s\n' "$BOLD" "$RESET" "${TYPORA_SUPPORT}"

    echo
    if typora_installed; then
        ok "已安装 Typora.app"
    else
        warn "未找到 Typora.app，请先安装并至少启动一次"
    fi
    if typora_running; then
        info "Typora 正在运行"
    fi

    echo
    if [[ -L "${TYPORA_SUPPORT}" ]]; then
        if same_path "${TYPORA_SUPPORT}" "${REPO_DIR}"; then
            ok "软链接正确 → $(readlink "${TYPORA_SUPPORT}")"
        else
            warn "软链接指向其他位置：$(readlink "${TYPORA_SUPPORT}")"
        fi
    elif [[ -d "${TYPORA_SUPPORT}" ]]; then
        warn "配置目录是普通文件夹，尚未软链接到本仓库"
    elif [[ -e "${TYPORA_SUPPORT}" ]]; then
        warn "配置路径存在，但不是目录：${TYPORA_SUPPORT}"
    else
        warn "配置目录不存在（尚未创建软链接）"
    fi

    echo
    missing="$(lxgw_missing || true)"
    if [[ -z "${missing}" ]]; then
        ok "霞鹜文楷（README 依赖）"
    else
        warn "缺少霞鹜文楷：$(printf '%s' "${missing}" | tr '\n' ' ')"
    fi
    if has_jetbrains; then
        ok "JetBrains Mono（base.user.css）"
    else
        warn "缺少 JetBrains Mono"
    fi
    if has_source_han; then
        ok "思源黑体 Source Han Sans（base.user.css）"
    else
        warn "缺少思源黑体"
    fi
    if has_pandoc; then
        ok "Pandoc（高级导出引擎：$(pandoc --version | head -n 1 | awk '{print $2}')）"
    else
        warn "未安装 Pandoc（Word/LaTeX 导出依赖，可执行：brew install pandoc）"
    fi

    echo
    printf '%b当前启用的主题%b（themes/*.css，会出现在 Typora 主题菜单）\n' "$BOLD" "$RESET"
    while IFS= read -r theme; do
        [[ -n "${theme}" ]] && printf '  %s\n' "${theme}"
    done < <(list_enabled_themes)

    echo
    printf '%b可选主题%b（themes/extra-themes，需 ./sync.sh extra）\n' "$BOLD" "$RESET"
    while IFS= read -r extra; do
        [[ -z "${extra}" ]] && continue
        dest="${REPO_DIR}/themes/${extra}.css"
        if [[ -e "${dest}" ]]; then
            printf '  %s （已启用）\n' "${extra}"
        else
            printf '  %s （未启用）\n' "${extra}"
        fi
    done < <(list_extra_themes)
}

cmd_install() {
    if ! typora_installed; then
        warn "未检测到 Typora.app。建议先安装并启动一次，再运行本脚本。"
        if [[ -t 0 ]] && ! (( ASSUME_YES )); then
            confirm "仍继续安装字体并创建软链接？" || die "已取消。"
        fi
    fi
    cmd_fonts
    install_pandoc
    cmd_link
    section "完成"
    ok "主题与配置已同步。"
    info "请重启 Typora，然后在「主题」菜单中选择。"
    info "可选主题：./sync.sh extra"
    info "查看状态：./sync.sh status"
}

# ---------------------------------------------------------------------------
# Args
# ---------------------------------------------------------------------------

parse_args() {
    local arg
    while [[ $# -gt 0 ]]; do
        arg="$1"
        case "$arg" in
            -y|--yes)
                ASSUME_YES=1
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=1
                shift
                ;;
            --repo)
                [[ $# -ge 2 ]] || die "--repo 需要路径参数"
                REPO_DIR="$2"
                shift 2
                ;;
            --repo=*)
                REPO_DIR="${arg#--repo=}"
                shift
                ;;
            -h|--help)
                COMMAND="help"
                shift
                ;;
            install|status|fonts|link|extra|help)
                if [[ -n "${COMMAND}" ]]; then
                    die "只能指定一个命令（已有 ${COMMAND}，又收到 ${arg}）"
                fi
                COMMAND="$arg"
                shift
                ;;
            -*)
                die "未知选项：${arg}（./sync.sh help）"
                ;;
            *)
                die "未知命令：${arg}（./sync.sh help）"
                ;;
        esac
    done
    COMMAND="${COMMAND:-install}"
}

main() {
    parse_args "$@"
    case "${COMMAND}" in
        help)
            usage
            return 0
            ;;
    esac
    require_macos
    REPO_DIR="$(cd "${REPO_DIR}" && pwd)"
    require_repo
    case "${COMMAND}" in
        install) cmd_install ;;
        status)  cmd_status ;;
        fonts)   cmd_fonts ;;
        link)    cmd_link ;;
        extra)   cmd_extra ;;
        *)       die "未知命令：${COMMAND}" ;;
    esac
}

main "$@"
