#paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/scripts:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

#settings
bindkey -v

# Match the cursor shape to the active vi keymap.
zle-keymap-select() {
  case $KEYMAP in
    viins|main) print -n -- $'\e[6 q' ;; # skinny bar
    vicmd)      print -n -- $'\e[2 q' ;; # block
  esac
}
zle -N zle-keymap-select

zle-line-init() {
  zle -K viins
  print -n -- $'\e[6 q'
}
zle -N zle-line-init

zle-line-finish() {
  print -n -- $'\e[2 q'
}
zle -N zle-line-finish

autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

#prompt
autoload -Uz vcs_info add-zsh-hook
setopt prompt_subst

zstyle ':vcs_info:git:*' formats ' (%b)'
zstyle ':vcs_info:git:*' actionformats ' (%b|%a)'

update_git_prompt() {
  vcs_info
}
add-zsh-hook precmd update_git_prompt

PROMPT='%n@%m %~${vcs_info_msg_0_} ❯ '

#aliases
alias n="niri-session"
