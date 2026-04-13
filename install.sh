#!/usr/bin/env bash
# Install this tmux config: symlinks tmux.conf → ~/.tmux.conf and
# cheatsheet.txt → ~/.config/tmux/cheatsheet.txt, backing up anything
# that's already there.
#
# Usage:
#   ./install.sh              # install (symlink)
#   ./install.sh --uninstall  # remove symlinks, restore most recent backups
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
MODE="install"

for arg in "$@"; do
    case "$arg" in
        --uninstall) MODE="uninstall" ;;
        -h|--help)
            sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) echo "unknown arg: $arg" >&2; exit 2 ;;
    esac
done

c_g="\033[32m"; c_y="\033[33m"; c_r="\033[31m"; c_d="\033[2m"; c_x="\033[0m"
log()  { printf "${c_g}✓${c_x} %s\n" "$*"; }
warn() { printf "${c_y}!${c_x} %s\n" "$*"; }
err()  { printf "${c_r}✗${c_x} %s\n" "$*" >&2; }

backup() {
    local target="$1"
    if [[ -e "$target" || -L "$target" ]]; then
        local bk="${target}.bak.${TS}"
        mv "$target" "$bk"
        warn "backed up existing $target → $bk"
    fi
}

install_one() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    backup "$dst"
    ln -s "$src" "$dst"
    log "linked $dst → $src"
}

uninstall_one() {
    local dst="$1"
    if [[ -L "$dst" ]]; then
        rm "$dst"
        log "removed symlink $dst"
    elif [[ -e "$dst" ]]; then
        warn "$dst is not a symlink; leaving it alone"
    fi
    local newest
    newest="$(ls -1t "${dst}".bak.* 2>/dev/null | head -n1 || true)"
    if [[ -n "$newest" ]]; then
        mv "$newest" "$dst"
        log "restored $dst from $newest"
    fi
}

CONF_DST="$HOME/.tmux.conf"
CHEAT_DST="$HOME/.config/tmux/cheatsheet.txt"

if [[ "$MODE" == "uninstall" ]]; then
    uninstall_one "$CONF_DST"
    uninstall_one "$CHEAT_DST"
else
    install_one "$REPO_DIR/tmux.conf"      "$CONF_DST"
    install_one "$REPO_DIR/cheatsheet.txt" "$CHEAT_DST"
fi

# Reload running tmux servers, if any
if command -v tmux >/dev/null && tmux info >/dev/null 2>&1; then
    tmux source-file "$CONF_DST" && log "reloaded running tmux"
else
    printf "${c_d}(no running tmux to reload)${c_x}\n"
fi

echo
log "done. press  prefix ?  inside tmux for the cheatsheet."
echo "    prefix = Ctrl+Space  (or Ctrl+b as fallback)"
