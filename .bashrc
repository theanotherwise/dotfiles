umask 0022

###################################
#
#     Branch Name is PS1
#
sc_helper_bashrc_branch() {
  if git branch >/dev/null 2>&1; then
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
  fi
}

###################################
#
#     Kube Info on Right of Console
#
sc_helper_bashrc_kube() {
  if kubectl config view --minify -o jsonpath="{}" >/dev/null 2>&1; then
    printf "%*s\r%s" $((COLUMNS - 1)) "$(kubectl config view --minify -o jsonpath="{.clusters[].name}/{.contexts[].context.namespace}")"
  fi
}

###################################
#
#     Cursor Character
#
sc_helper_bashrc_cursor() {
  [[ "${UID}" == "0" ]] && echo '#' || echo '$'
}

###################################
#
#     Others
#
sc_helper_x509_decoder (){
  if [ -z "${1}" ] ; then
    while IFS= read -r LINE; do
      lines="${lines}${LINE}\n"
    done
    echo -e "${lines}" | openssl x509 -noout -text
  else
    openssl x509 -noout -text -in "${1}"
  fi
}

sc_helper_x509_ca() {
  [ -z "${1}" ] && CA_NAME="ca" || CA_NAME="${1}"
  [ -z "${2}" ] && CN_NAME="Root CA" || CN_NAME="${2}"

  openssl req \
    -nodes -x509 -days 3650 -newkey rsa:4096 \
    -subj "/C=PL/ST=Mazovia/L=Warsaw/O=Seems Cloud/OU=Untrusted Local CA/CN=${CN_NAME}" \
    -keyout "${CA_NAME}".key.pem -out "${CA_NAME}".crt.pem
}

sc_helper_x509_leaf() {
  [ -z "${1}" ] && CA_NAME="ca" || CA_NAME="${1}"
  [ -z "${2}" ] && LEAF_NAME="leaf" || LEAF_NAME="${2}"

  [ ! -f "${CA_NAME}".crt.pem ] && [ ! -f "${CA_NAME}".key.pem ] && sc_helper_x509_ca

  openssl req \
    -nodes -new -newkey rsa:2048 \
    -subj "/C=PL/ST=Mazovia/L=Warsaw/O=Seems Cloud/OU=Untrusted Local CA/CN=${LEAF_NAME}" \
    -keyout "${LEAF_NAME}".key.pem -out "${LEAF_NAME}".csr.pem

  openssl x509 \
    -req -days 730 \
    -CA "${CA_NAME}".crt.pem -CAkey "${CA_NAME}".key.pem -CAcreateserial \
    -in "${LEAF_NAME}".csr.pem -out "${LEAF_NAME}".crt.pem
}

###################################
#
#     Exports
#
export PS1="\[\e[1;34m\]\$(sc_helper_bashrc_kube)\[\e[m\][\[\e[32m\]\u\[\e[m\]]@[\[\e[1;34m\]\h\[\e[m\]][\[\e[1;36m\]\W\[\e[m\]]\$(sc_helper_bashrc_cursor) \[\e[33m\]\$(sc_helper_bashrc_branch)\[\e[m\]"
export HISTSIZE="10000"
export HISTFILESIZE="10000"
export HISTTIMEFORMAT="%Y-%m-%d %T "
export EDITOR="vim"
1
