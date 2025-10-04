echo "Loading file: $(basename \"${BASH_SOURCE[0]}\")"

# Generic
alias ls='ls --color=auto'
alias rm="rm -iv"
alias cp="cp -iv"
alias mv="mv -iv"
alias rmdir="rmdir -v"




# Watches
alias watch-0='watch -n 0 '
alias watch-1='watch -n 1 '
alias watch-2='watch -n 2 '
alias watch-3='watch -n 3 '
alias watch-5='watch -n 5 '
alias watch-10='watch -n 10 '
alias watch-15='watch -n 15 '
alias watch-30='watch -n 30 '




# Kubernetes Defaults
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

alias ksecret='sc_helper_kube_secret'

# Kubernetes Watches
alias kget-nodes='kubectl get nodes -o wide'
alias kwatch-nodes='watch -n 1 kubectl get nodes -o wide'
alias kget-pods='kubectl get pods -o wide'
alias kwatch-pods='watch -n 1 kubectl get pods -o wide'
alias ktop-pods='watch -n 1 kubectl top pods'
alias kget-svc='kubectl get svc -o wide'
alias kwatch-svc='watch -n 1 kubectl get svc -o wide'
alias kget-pvc='kubectl get pvc -o wide'
alias kwatch-pvc='watch -n 1 kubectl get pvc -o wide'




alias helm-unittest=untt




# Docker
alias docker-compose-up-clean="docker-compose up --force-recreate --remove-orphans --build"
alias docker-stop="docker ps -aq | xargs -r docker stop -t 0"
alias docker-rm-containers="docker ps -aq | xargs -r docker rm -f"
alias docker-rm-images="docker images -q | xargs -r docker rmi -f"
alias docker-rm-networks="docker network ls -q | xargs -r docker network rm"
alias docker-rm-volumes="docker volume ls -q | xargs -r docker volume rm"
alias docker-system-prune="docker system prune -f"






# Terraform
alias terragrunt="terragrunt"
alias terralint="tflint"
alias terrasec="tfsec"
alias terrapike="pike"


alias export-tofu='export TG_TF_PATH=tofu'
alias export-terraform='export TG_TF_PATH=terraform'









# gcloud
alias gcloud-projects="gcloud projects list"
alias gcloud-set-project="gcloud config set project"
alias gcloud-auth="gcloud auth login --no-launch-browser"
alias gcloud-auth-app="gcloud auth application-default login --no-launch-browser"
alias gcloud-kube="gcloud container clusters list"
alias gcloud-kube-creds="gcloud container clusters get-credentials"

# Azure
alias az-subs="az account subscription list --query '[].{Name:name,Id:id,State:state,IsDefault:isDefault}' -o table"





# Git Commit
alias git-commitpush-feat='git add . && git commit -am "feat: new features implemented" && git push'
alias git-commitpush-fix='git add . && git commit -am "fix: general fixes" && git push'
alias git-commitpush-chore='git add . && git commit -am "chore: cleanups and maintenance" && git push'
alias git-commitpush-docs='git add . && git commit -am "chore: update and improve existing docs" && git push'
alias git-commitpush-empty="git commit --allow-empty -m \"Empty Commit\" ; git push"

# Git 
alias git-graph='git log --graph --no-abbrev-commit --decorate=full \
  --pretty=format:"%C(yellow)%h%Creset %Cgreen%ad%Creset %C(auto)%d %s" \
  --date=iso --color=always --log-size --raw --stat --all'

# Git - Log
alias git-log='bash -c '"'"'
  N=${1:-5}
  for h in $(git --no-pager log --reverse -n "$N" --format=%H); do
    printf "\033[35m"; printf "%.0s-" {1..80}; printf "\033[0m\n"
    git --no-pager show -s --date=iso --decorate=full \
      --pretty="%C(yellow)%h %Cgreen%ad %C(auto)%d %Cblue[%an]%Creset%n%C(red bold)%s%Creset%n%b" "$h"
    printf "\033[35m"; printf "%.0s-" {1..80}; printf "\033[0m\n"
    git --no-pager show --format= "$h"
  done
'"'"' bash'

# Git - Status
alias git-status="git status -vvv --long"

# Git - Ref
alias git-ref='git show-ref --tags --heads \
  | sed -E "s#refs/heads/#branch #; s#refs/tags/#tag    #;" \
  | awk "{h=substr(\$1,1,10); t=\$2; n=\$3; c=(t==\"branch\"?\"\033[32m\":\"\033[34m\"); printf \"\033[33m%-10s\033[0m %-7s %s%s\033[0m\n\", h, t, c, n}"'

# Git - Show
alias git-show='git show --no-abbrev-commit --decorate=full \
  --pretty=format:"%C(yellow)commit %H%Creset%n%Cgreen%ad%Creset %C(auto)%d%Creset%n\
%CblueAuthor:%Creset %an%n%C(cyan)Message:%Creset%n  %C(red bold)%s%Creset%n%n%b%n\
%C(magenta)--------------------------------------------------%Creset" \
  --date=iso --color=always'

# Git - Remote Show
alias git-remote='git remote show origin | sed \
  -e "s/^\\* remote/Remote:/" \
  -e "s/^  Fetch URL:/\x1b[32mFetch URL:\x1b[0m/" \
  -e "s/^  Push  URL:/\x1b[36mPush  URL:\x1b[0m/" \
  -e "s/^  HEAD branch:/\x1b[35mHEAD branch:\x1b[0m/" \
  -e "s/^  Local branch configured for '\''git pull'\'':/\x1b[34mPull config:\x1b[0m/" \
  -e "s/^  Local ref configured for '\''git push'\'':/\x1b[34mPush config:\x1b[0m/"'







# Git Sync
alias git-sync-tag="git fetch -fup origin \"+refs/tags/*:refs/tags/*\" -vvv"
alias git-sync-branch='git fetch -fup origin "+refs/heads/*:refs/heads/*" -vvv'







# Git Tags
alias git-tag='git tag'
alias git-tag-push='git push origin tag'
alias git-tag-by-date='sc_helper_git_tag_push'








# Git Code Follow
alias git-reset-soft='git reset --soft HEAD^'
alias git-reset-hard='git reset --hard'
alias git-reset-hard-commited="git reset --hard @{u}"

alias git-pull='git pull -vvv'
alias git-pull-main='git pull origin main -vvv'
alias git-pull-master='git pull origin master -vvv'
alias git-pull-home='git -C "${HOME}" pull origin main -vvv'







# Data Processing
alias base64enc='python3 -c "import sys, base64 ; print(base64.b64encode(sys.argv[1].rstrip().encode() if len(sys.argv) > 1 else sys.stdin.read().rstrip().encode()).decode())"'
alias base64dec='python3 -c "import sys, base64 ; print(base64.b64decode(sys.argv[1].rstrip().encode() if len(sys.argv) > 1 else sys.stdin.read().rstrip().encode()).decode())"'

alias urlenc='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1].rstrip()) if len(sys.argv) > 1 else ul.quote_plus(sys.stdin.read().rstrip()))"'
alias urldec='python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1].rstrip()) if len(sys.argv) > 1 else ul.unquote_plus(sys.stdin.read().rstrip()))"'

alias x509dec='sc_helper_x509_decode'
alias x509ca='sc_helper_x509_ca_make'
alias x509leaf='sc_helper_x509_ca_make_leaf'

alias rg='rg --no-filename --no-line-number --no-ignore'






# Tests
alias curlperf='sc_helper_curl_format_file && curl -w "@.curl-timing-format.txt" -o /dev/null -s -L'
alias tcpcheck='sc_helper_tcp_linux_check'






# function required (alias too limited for this)
reload() {
  source "${HOME}/.bash_profile"
  echo "Reloaded ${HOME}/.bash_profile"
}

