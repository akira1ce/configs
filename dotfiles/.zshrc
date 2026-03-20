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
export ANTHROPIC_AUTH_TOKEN=sk-xxx
export ANTHROPIC_BASE_URL=https://a-ocnfniawgw.cn-shanghai.fcapp.run
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
export ENABLE_TOOL_SEARCH=false
export NODE_TLS_REJECT_UNAUTHORIZED=0

# [agent-router]

# export ANTHROPIC_AUTH_TOKEN=sk-xxx
# export ANTHROPIC_BASE_URL=https://agentrouter.org
# export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1