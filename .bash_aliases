alias ls='ls --color=auto'
alias rm="rm -iv"
alias cp="cp -iv"
alias mv="mv -iv"
alias rmdir="rmdir -v"

alias watch-1='watch -n 1 '
alias watch-2='watch -n 2 '
alias watch-3='watch -n 3 '
alias watch-5='watch -n 5 '
alias watch-10='watch -n 10 '
alias watch-15='watch -n 15 '
alias watch-30='watch -n 30 '

alias k="kubectl"
alias kctx="kubectx"
alias kns="kubens"
alias kc="kube-capacity"
alias kt="kubetail"
alias kl="kube-linter"
alias kp="popeye"
alias knt="kubent"
alias ks="kubespy"
alias kv='kubectl get events --sort-by=".metadata.creationTimestamp"'
alias kva='kubectl get events --sort-by=".metadata.creationTimestamp" -A'

alias tf="terraform"
alias tfgrunt="terragrunt"
alias tfpike="pike"
alias tfscan="terrascan"

alias gitgraph="git log --graph --no-abbrev-commit --decorate=full --pretty=oneline --color=always --log-size --date=iso  --raw --stat --all"
alias gitfresh="git pull ; git fetch --all ; git fetch --prune ; git fetch -fup origin \"+refs/*:refs/*\""
alias gitfreshtags="git fetch --prune origin \"+refs/tags/*:refs/tags/*\""
alias gitref="git show-ref --tags --heads"
alias gitstatus="git status -vvv --long"
alias gitshow="git show --no-abbrev-commit --decorate=full --pretty=oneline --color=always --log-size"
alias gitlog='sc_helper_git_log_n_commits'
alias gitsoft='git reset --soft HEAD^'
alias gitsoftrev='git reset --soft HEAD@{1}'

alias base64enc='python3 -c "import sys, base64 ; print(base64.b64encode(sys.argv[1].rstrip().encode() if len(sys.argv) > 1 else sys.stdin.read().rstrip().encode()).decode())"'
alias base64dec='python3 -c "import sys, base64 ; print(base64.b64decode(sys.argv[1].rstrip().encode() if len(sys.argv) > 1 else sys.stdin.read().rstrip().encode()).decode())"'

alias urlenc='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1].rstrip()) if len(sys.argv) > 1 else ul.quote_plus(sys.stdin.read().rstrip()))"'
alias urldec='python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1].rstrip()) if len(sys.argv) > 1 else ul.unquote_plus(sys.stdin.read().rstrip()))"'

alias x509dec='sc_helper_x509_decode'
alias x509ca='sc_helper_x509_ca_make'
alias x509leaf='sc_helper_x509_ca_make_leaf'

alias curlperf='sc_helper_curl_format_file && curl -w "@.curl-timing-format.txt" -o /dev/null -s -L'
alias tcpcheck='sc_helper_tcp_linux_check'
