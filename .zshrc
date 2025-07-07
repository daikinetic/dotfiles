
burl() { curl -s "$@" | jq . | bat --language=json; }
set -o ignoreeof

#alias
source ~/.zsh/alias.zsh

#script
source ~/.zsh/script.zsh
