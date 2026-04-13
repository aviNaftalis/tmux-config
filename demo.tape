# Generates demo.gif. Install vhs (https://github.com/charmbracelet/vhs)
# then run:   vhs demo.tape
# (vhs bundles ttyd + ffmpeg, so no other deps needed.)

Output demo.gif

Set Shell        "bash"
Set FontSize     16
Set Width        1100
Set Height       680
Set Theme        "TokyoNight"
Set Padding      20
Set TypingSpeed  50ms
Set PlaybackSpeed 1.0

# === Setup (hidden) ==========================================================
# Write a fake-prompt rcfile + a tiny tmux overlay that sources the real
# config and overrides PS1/hostname so the GIF doesn't leak machine info.
# Use an isolated socket (-L vhsdemo) so this is safe to re-record from
# inside an existing tmux session.
Hide
Type "cat > /tmp/vhsdemo-rc <<'EOF'" Enter
Type "PS1='\[\033[1;36m\]❯\[\033[0m\] '" Enter
Type "unset PROMPT_COMMAND" Enter
Type "EOF" Enter
Type "cat > /tmp/vhsdemo-tmux.conf <<'EOF'" Enter
Type "source-file ./tmux.conf" Enter
Type "set -g default-command 'bash --rcfile /tmp/vhsdemo-rc -i'" Enter
Type "set -g status-right '#[fg=#565f89] %H:%M '" Enter
Type "EOF" Enter
Type "tmux -L vhsdemo kill-server 2>/dev/null; clear" Enter
Sleep 300ms
Type "tmux -L vhsdemo -f /tmp/vhsdemo-tmux.conf new-session -s demo" Enter
Sleep 1500ms
Show

# === Open multiple panes ====================================================
Sleep 700ms
Type "ls" Enter
Sleep 700ms

# Vertical split (prefix |)
Ctrl+Space
Type "|"
Sleep 400ms
Type "echo 'pane 2 — prefix |'" Enter
Sleep 600ms

# Horizontal split in current pane (prefix -)
Ctrl+Space
Type "-"
Sleep 400ms
Type "echo 'pane 3 — prefix -'" Enter
Sleep 600ms

# === Navigate panes (Alt+hjkl, no prefix) ===================================
Alt+h
Sleep 350ms
Alt+l
Sleep 350ms
Alt+k
Sleep 350ms
Alt+j
Sleep 500ms

# === Resize panes (prefix H/J/K/L, repeatable) ==============================
Ctrl+Space
Type "HHHH"
Sleep 500ms
Ctrl+Space
Type "JJJ"
Sleep 500ms
Ctrl+Space
Type "LL"
Sleep 500ms

# === Close panes (prefix x — no confirm) ====================================
Ctrl+Space
Type "x"
Sleep 500ms
Ctrl+Space
Type "x"
Sleep 700ms

# === Copy + paste (vim keys in copy-mode) ===================================
Type "echo 'select-and-yank with vim keys'" Enter
Sleep 700ms
# Enter copy-mode (prefix [)
Ctrl+Space
Type "["
Sleep 400ms
Type "k"        # up one line, onto the echo output
Sleep 200ms
Type "0"        # start of line
Sleep 200ms
Type "v"        # begin selection
Sleep 200ms
Type "$"        # extend to end of line
Sleep 400ms
Type "y"        # yank → system clipboard, exit copy-mode
Sleep 600ms
# Paste it back inside an echo
Type "echo 'pasted: "
Ctrl+Space
Type "p"        # prefix p → paste-buffer
Type "'"
Enter
Sleep 800ms

# === New window + switch (prefix c, then Alt+1/2) ===========================
Ctrl+Space
Type "c"
Sleep 500ms
Type "echo 'window 2 — switch with Alt+1/2'" Enter
Sleep 700ms
Escape
Type "1"
Sleep 600ms
Escape
Type "2"
Sleep 700ms

# === Rename window (prefix , — prefilled, clear with Ctrl+u) ================
Ctrl+Space
Type ","
Sleep 400ms
Ctrl+u
Type "scratch"
Enter
Sleep 800ms

# === Show cheatsheet (prefix ?) =============================================
Ctrl+Space
Type "?"
Sleep 2500ms
Type "q"
Sleep 600ms

# === Detach =================================================================
Ctrl+Space
Type "d"
Sleep 600ms

# === Cleanup (hidden) =======================================================
Hide
Type "tmux -L vhsdemo kill-server 2>/dev/null; rm -f /tmp/vhsdemo-rc /tmp/vhsdemo-tmux.conf; clear" Enter
