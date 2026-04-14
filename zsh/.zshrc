# ══════════════════════════════════════════════════════════════════════════════
# ~/.zshrc — bogdan @ vreau.io
# managed via: ~/.dotfiles/zsh/.zshrc → stow zsh
# ══════════════════════════════════════════════════════════════════════════════

# ── History ────────────────────────────────────────────────────────────────
HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS       # nu salva duplicate consecutive
setopt HIST_IGNORE_ALL_DUPS   # sterge duplicatele mai vechi din history
setopt HIST_FIND_NO_DUPS      # nu afisa duplicate la cautare
setopt HIST_IGNORE_SPACE      # comenzile prefixate cu spatiu nu se salveaza
setopt SHARE_HISTORY          # sincronizeaza history intre sesiuni tmux/tab-uri

# ── Completion ─────────────────────────────────────────────────────────────
zstyle :compinstall filename '/home/bogdan/.zshrc'
autoload -Uz compinit

# Regenereaza cache-ul compinit doar o data pe zi — mult mai rapid
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# fzf-tab (trebuie sourcat dupa compinit, inainte de alte plugins)
source ~/.zsh/fzf-tab/fzf-tab.plugin.zsh

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case-insensitive
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border

# ── Keybindings ────────────────────────────────────────────────────────────
# bindkey -e  # dezactivat — zsh-vi-mode gestioneaza modul

# ── Environment ────────────────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim
export TERM=xterm-256color
export PATH="$HOME/.local/bin:$PATH"

# Afiseaza durata comenzilor care dureaza mai mult de 5 secunde
REPORTTIME=5

# pnpm
export PNPM_HOME="/home/bogdan/.local/share/pnpm"
[[ ":$PATH:" != *":$PNPM_HOME:"* ]] && export PATH="$PNPM_HOME:$PATH"

# fnm (Node version manager — inlocuieste nvm, instant la startup)
# instalare: curl -fsSL https://fnm.vercel.app/install | bash
if command -v fnm &>/dev/null; then
  eval "$(fnm env --use-on-cd)"
fi

# ── IBus (doar pentru sesiuni grafice) ─────────────────────────────────────
if [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]; then
  export GTK_IM_MODULE=ibus
  export QT_IM_MODULE=ibus
  export XMODIFIERS=@im=ibus
fi

# ── fzf config ─────────────────────────────────────────────────────────────
# necesita: sudo dnf install fd-find bat
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 40% --layout=reverse --border
  --preview "bat --color=always --line-range :50 {}"
  --bind ctrl-u:preview-up,ctrl-d:preview-down
'

# Ctrl+F — file picker cu fzf (insereaza path-ul in linie)
fzf-file-widget() {
  local file
  file=$(fd --type f --hidden --exclude .git | fzf --preview 'bat --color=always --line-range :50 {}')
  [[ -n "$file" ]] && LBUFFER+="$file"
  zle reset-prompt
}
zle -N fzf-file-widget
bindkey '^F' fzf-file-widget

# ── Plugins (managed via stow + git submodules) ──────────────────────────
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-autopair/autopair.zsh

# zsh-vi-mode — vim motions pe command line (Esc = Normal mode)
ZVM_INIT_MODE=sourcing          # compatibilitate cu alte plugins
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk # jk ca alternativa la Esc
KEYTIMEOUT=1                    # fara delay la Esc
source ~/.zsh/zsh-vi-mode/zsh-vi-mode.plugin.zsh

source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  # trebuie ultimul

# ── Aliases — navigare ─────────────────────────────────────────────────────
alias cd='z'

# ── Aliases — listing (eza) ────────────────────────────────────────────────
alias ls='eza --git --icons --color=always'
alias ll='eza -l --git --icons --color=always'
alias la='eza -la --git --icons --color=always'
alias lt='eza --tree -L 3 --git --icons --color=always'
alias ltd='eza --tree -L 3 -D --git --icons --color=always'

# ── Aliases — better defaults ──────────────────────────────────────────────
alias cat='bat --paging=never'
alias catp='bat'

# ── Aliases — clipboard (Wayland) ──────────────────────────────────────────
# necesita: sudo dnf install wl-clipboard
alias copy='wl-copy'
alias paste='wl-paste'

# ── Aliases — git ──────────────────────────────────────────────────────────
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gp='git push'
alias gpf='git push --force-with-lease'

# ── Functions ──────────────────────────────────────────────────────────────
# Yazi cu cd la exit
function y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# tmux session switcher (git-aware, cu fzf + zoxide)
new_tmux() {
  if ! command -v zoxide >/dev/null 2>&1; then
    echo "zoxide not installed"; return 1
  fi

  local session_dir
  if command -v fzf >/dev/null 2>&1; then
    session_dir=$(zoxide query --list | fzf --preview 'ls -la {} | head -50')
  else
    session_dir=$(zoxide query)
  fi
  [[ -z "$session_dir" ]] && return

  local matches
  matches=$(tmux list-sessions -F '#{session_name} #{session_path}' 2>/dev/null \
    | awk -v dir="$session_dir" '$2 == dir {print $1}')

  if [[ -n "$matches" ]]; then
    local existing
    if [[ $(echo "$matches" | wc -l) -gt 1 ]]; then
      existing=$(echo "$matches" | fzf --prompt="sesiune: ")
    else
      existing="$matches"
    fi
    [[ -z "$existing" ]] && return
    [[ -n "$TMUX" ]] \
      && tmux switch-client -t "$existing" \
      || tmux attach -t "$existing"
    return
  fi

  local session_name
  if git -C "$session_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local repo_root repo_name branch
    repo_root=$(git -C "$session_dir" rev-parse --show-toplevel)
    repo_name=$(basename "$repo_root")
    branch=$(git -C "$session_dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
    branch=${branch//[\/.]/__}
    session_name="${repo_name}:${branch}"
  else
    session_name=$(basename "$session_dir")
  fi

  if [[ -n "$TMUX" ]]; then
    tmux new-session -d -c "$session_dir" -s "$session_name"
    tmux switch-client -t "$session_name"
  else
    tmux new-session -c "$session_dir" -s "$session_name"
  fi
}
alias tm=new_tmux

# thefuck lazy-load — evita ~200ms la startup
function fuck() {
  unfunction fuck
  eval "$(thefuck --alias)"
  fuck "$@"
}

# ── Tool init ──────────────────────────────────────────────────────────────
eval "$(fzf --zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"     # zoxide ultimul — ca sa nu-i rescrie hook-ul chpwd

# ── Keybindings finale (dupa toate tool init-urile) ───────────────────────
# zvm_after_lazy_keybindings se apeleaza dupa ce zsh-vi-mode face lazy init
function zvm_after_lazy_keybindings() {
  bindkey -M viins '\t' autosuggest-accept     # Tab accepta autosuggestion in insert mode
  bindkey -M viins '^ ' fzf-tab-complete       # Ctrl+Space deschide fzf completion
  bindkey -M viins '^R' fzf-history-widget     # Ctrl+R cauta in history cu fzf
  bindkey -M vicmd '^R' fzf-history-widget     # Ctrl+R si in normal mode
}
# fallback — aplica si direct acum
bindkey '\t' autosuggest-accept
bindkey '^ ' fzf-tab-complete
bindkey '^R' fzf-history-widget