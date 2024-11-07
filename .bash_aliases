alias ls='ls --color=auto'
alias rm="rm -iv"
alias cp="cp -iv"
alias mv="mv -iv"
alias rmdir="rmdir -v"

alias watch-0='watch -n 0 '
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
alias k-get-nodes='kubectl get nodes -o wide'
alias k-watch-nodes='watch -n 1 kubectl get nodes -o wide'
alias k-get-pods='kubectl get pods -o wide'
alias k-watch-pods='watch -n 1 kubectl get pods -o wide'
alias k-top-pods='watch -n 1 kubectl top pods'
alias k-get-svc='kubectl get svc -o wide'
alias k-watch-svc='watch -n 1 kubectl get svc -o wide'
alias k-get-pvc='kubectl get pvc -o wide'
alias k-watch-pvc='watch -n 1 kubectl get pvc -o wide'

alias terragrunt="terragrunt --terragrunt-source-update"
alias tf-pike="pike"
alias tf-scan="terrascan"

alias gittag='git tag'
alias gittagpush='git push origin tag'
alias gittagfresh="git fetch -fup origin \"+refs/tags/*:refs/tags/*\" -vvv"

alias gcloud-project-list="gcloud projects list"
alias gcloud-project-set="gcloud config set project"
alias gcloud-auth-login="gcloud auth login"
alias gcloud-auth-login-app-default="gcloud auth application-default login"
alias gcloud-container-clusters-list="gcloud container clusters list"
alias gcloud-container-clusters-creds="gcloud container clusters get-credentials"

alias git-commit='git add . && git commit -am "fix: init" && git push'
alias git-pull='git pull'
alias git-graph="git log --graph --no-abbrev-commit --decorate=full --pretty=oneline --color=always --log-size --date=iso  --raw --stat --all"
alias git-fresh="git pull ; git fetch --all ; git fetch --prune ; git fetch -fup origin \"+refs/*:refs/*\" -vvv"
alias git-empty-commit-push="git commit --allow-empty -m \"Empty Commit\" ; git push"
alias git-ref="git show-ref --tags --heads"
alias git-status="git status -vvv --long"
alias git-show="git show --no-abbrev-commit --decorate=full --pretty=oneline --color=always --log-size"
alias git-log='sc_helper_git_log_n_commits'
alias git-reset-soft='git reset --soft HEAD^'
alias git-reset-hard='git reset --hard'

alias export-tofu='export TERRAGRUNT_TFPATH=tofu'
alias export-terraform='export TERRAGRUNT_TFPATH=terraform'

alias base64enc='python3 -c "import sys, base64 ; print(base64.b64encode(sys.argv[1].rstrip().encode() if len(sys.argv) > 1 else sys.stdin.read().rstrip().encode()).decode())"'
alias base64dec='python3 -c "import sys, base64 ; print(base64.b64decode(sys.argv[1].rstrip().encode() if len(sys.argv) > 1 else sys.stdin.read().rstrip().encode()).decode())"'

alias urlenc='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1].rstrip()) if len(sys.argv) > 1 else ul.quote_plus(sys.stdin.read().rstrip()))"'
alias urldec='python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1].rstrip()) if len(sys.argv) > 1 else ul.unquote_plus(sys.stdin.read().rstrip()))"'

alias x509dec='sc_helper_x509_decode'
alias x509ca='sc_helper_x509_ca_make'
alias x509leaf='sc_helper_x509_ca_make_leaf'

alias curlperf='sc_helper_curl_format_file && curl -w "@.curl-timing-format.txt" -o /dev/null -s -L'
alias tcpcheck='sc_helper_tcp_linux_check'
