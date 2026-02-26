# [oh-my-zsh]

export ZSH="$HOME/.oh-my-zsh"

# zsh-theme
ZSH_THEME="robbyrussell"

# zsh-plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting z extract)

source $ZSH/oh-my-zsh.sh

# [fnm]

eval "$(fnm env --use-on-cd --shell zsh)"

# [any-router]

export ANTHROPIC_AUTH_TOKEN=sk-i9F4jeCsRlLiH69N3oOgjSPVotEUhZ6CmDqhp3VUf4Amvp8K
export ANTHROPIC_BASE_URL=https://anyrouter.top
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
