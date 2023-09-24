umask 0022

if [ -f ${HOME}/.bash_aliases ] ; then
  . ${HOME}/.bash_aliases
fi

bashrc_branch() {
  if git branch >/dev/null 2>&1 ; then
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
  fi
}

bashrc_kube() {
  if kubectl config view --minify -o jsonpath="{}" >/dev/null 2>&1 ; then
    printf "%*s\r%s" $(( COLUMNS-1 )) "$(kubectl config view --minify -o jsonpath="{.clusters[].name}/{.contexts[].context.namespace}")"
  fi
}

bashrc_cursor(){
  [[ "${UID}" == "0" ]] && echo '#' || echo '$'
}

export PS1="\[\e[1;34m\]\$(bashrc_kube)\[\e[m\][\[\e[32m\]\u\[\e[m\]]@[\[\e[1;34m\]\h\[\e[m\]][\[\e[1;36m\]\W\[\e[m\]]\$(bashrc_cursor) \[\e[33m\]\$(bashrc_branch)\[\e[m\]"
export HISTSIZE="10000"
export HISTFILESIZE="10000"
export HISTTIMEFORMAT="%Y-%m-%d %T "
export EDITOR="vim"
