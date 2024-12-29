# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
#source /home/bogdan/zsh-autocomplete/zsh-autocomplete.plugin.zsh
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/bogdan/.zshrc'

autoload -Uz compinit
compinit
eval "$(starship init zsh)"
#source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# End of lines added by compinstall
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

alias eza='eza --git'
alias ls='eza --git --icons --color=always'
alias ll='eza -l --git --icons --color=always'
alias la='eza -la --git --icons --color=always'

eval "$(zoxide init zsh)"
alias cd="z"

export EDITOR=nvim
export VISUAL=nvim

export PATH="$HOME/.local/bin:$PATH"