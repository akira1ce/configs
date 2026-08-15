# [oh-my-zsh]

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"

# zsh-theme
ZSH_THEME="robbyrussell"

# zsh-plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting z extract)

source $ZSH/oh-my-zsh.sh

# [fnm]
eval "$(fnm env --use-on-cd --shell zsh)"
