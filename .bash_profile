source ~/.bashrc

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"


[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/dwanderson/sigopt/google-cloud-sdk/path.bash.inc' ]; then . '/Users/dwanderson/sigopt/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/dwanderson/sigopt/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/dwanderson/sigopt/google-cloud-sdk/completion.bash.inc'; fi
