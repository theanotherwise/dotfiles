echo "Loading file: $(basename "${BASH_SOURCE[0]}")"

sc_helper_bashrc_branch() {
  if git branch >/dev/null 2>&1; then
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
  fi
}

sc_helper_bashrc_kube() {
  if kubectl config view --minify -o jsonpath="{}" >/dev/null 2>&1; then
    printf "%*s\r%s" $((COLUMNS - 1)) "$(kubectl config view --minify -o jsonpath="{.clusters[].name}/{.contexts[].context.namespace}")"
  fi
}

sc_helper_bashrc_cursor() {
  [[ "${UID}" == "0" ]] && echo '#' || echo '$'
}

sc_helper_x509_decode (){
  if [ -z "${1}" ] ; then
    while IFS= read -r LINE; do
      lines="${lines}${LINE}\n"
    done
    echo -e "${lines}" | openssl x509 -noout -text
  else
    openssl x509 -noout -text -in "${1}"
  fi
}

sc_helper_x509_san_names(){
  SAN_NAMES=""

  for i in $(echo "${1}" | tr ',' '\n') ; do
    SAN_NAMES="DNS:${i},${SAN_NAMES}"
  done

  echo "$(echo "${SAN_NAMES}" | sed "s/,$//g")"
}

sc_helper_x509_ca_make() {
  [ "${1}" == "-" ] || [ -z "${1}" ] && CA_NAME="ca" || CA_NAME="${1}"
  [ "${2}" == "-" ] || [ -z "${2}" ] && CA_CN_NAME="CA" || CA_CN_NAME="${2}"
  [ "${3}" == "-" ] || [ -z "${3}" ] && CA_DAYS="9125" || CA_DAYS="${3}"
  [ "${4}" == "-" ] || [ -z "${4}" ] && CA_SIZE="4096" || CA_SIZE="${4}"

  echo "CA, Files: '${CA_NAME}.(crt|key).pem', CN: '${CA_CN_NAME}', Days: '${CA_DAYS}', Size: '${CA_SIZE}'"

  openssl req \
    -nodes -x509 -days "${CA_DAYS}" -newkey rsa:"${CA_SIZE}" \
    -subj "/CN=${CA_CN_NAME}" \
    -keyout "${CA_NAME}".key.pem -out "${CA_NAME}".crt.pem
}

sc_helper_x509_ca_make_leaf() {
  [ "${1}" == "-" ] || [ -z "${1}" ] && LEAF_NAME="leaf" || LEAF_NAME="${1}"
  [ "${2}" == "-" ] || [ -z "${2}" ] && LEAF_FILENAME="-" || LEAF_FILENAME="${2}"
  [ "${3}" == "-" ] || [ -z "${3}" ] && LEAF_SANS="-" || LEAF_SANS="${3}"
  [ "${4}" == "-" ] || [ -z "${4}" ] && CA_NAME="ca" || CA_NAME="${4}"
  [ "${5}" == "-" ] || [ -z "${5}" ] && LEAF_DAYS="1825" || LEAF_DAYS="${5}"
  [ "${6}" == "-" ] || [ -z "${6}" ] && LEAF_SIZE="2048" || LEAF_SIZE="${6}"

  CA_FILENAME="${CA_NAME}"
  [ ! -f "${CA_FILENAME}".crt.pem ] && [ ! -f "${CA_FILENAME}".key.pem ] && echo "CA Does Not Exists" && return

  if [ "${LEAF_FILENAME}" == "-" ] ; then
    LEAF_FILENAME="${CA_NAME}-${LEAF_NAME}"
  fi
  echo "Certificate, File: '${LEAF_FILENAME}.(crt|key).pem', CN: '${LEAF_NAME})', Days: '${CA_DAYS}', Size: '${CA_SIZE}'"

  openssl req \
    -nodes -new -newkey rsa:"${LEAF_SIZE}" \
    -subj "/CN=${LEAF_NAME}" \
    -keyout "${LEAF_FILENAME}".key.pem -out "${LEAF_FILENAME}".csr.pem

  if [ -z "${LEAF_SANS}" ] || [ "${LEAF_SANS}" == "-" ] ; then
    openssl x509 \
      -req -days "${LEAF_DAYS}" \
      -CA "${CA_FILENAME}".crt.pem -CAkey "${CA_FILENAME}".key.pem -CAcreateserial \
      -in "${LEAF_FILENAME}".csr.pem -out "${LEAF_FILENAME}".crt.pem
  else
    SAN_NAMES="$(sc_helper_x509_san_names "${LEAF_SANS},${LEAF_NAME}")"
    echo "SAN Names: ${SAN_NAMES}"
    openssl x509 \
      -req -days "${LEAF_DAYS}" \
      -CA "${CA_FILENAME}".crt.pem -CAkey "${CA_FILENAME}".key.pem -CAcreateserial \
      -in "${LEAF_FILENAME}".csr.pem -out "${LEAF_FILENAME}".crt.pem \
      -extfile <(printf "subjectAltName=${SAN_NAMES}")
  fi
}

sc_helper_curl_format_file(){
cat > .curl-timing-format.txt << EndOfMessage
\t%{time_namelookup}s\tNamelookup (DNS)\n
\t%{time_connect}s\tConnect (TCP)\n
\t%{time_appconnect}s\tApp Connect (SSL/SSH/etc.)\n
\t%{time_pretransfer}s\tPretransfer (just before want to start sending)\n
\t%{time_starttransfer}s\tStart Transfer (first byte + Pretransfer)\n
\t%{time_redirect}s\tRedirect (all before final request)\n
------------------------------\n
\t%{time_total}s:\tTotal\n
EndOfMessage
}

sc_helper_tcp_linux_check(){
  [ -z "${1}" ] && DEST_NAME="google.com" || DEST_NAME="${1}"
  [ -z "${2}" ] && DEST_PORT="80" || DEST_PORT="${2}"

  timeout 5 bash -c "(echo > /dev/tcp/${DEST_NAME}/${DEST_PORT}) >/dev/null 2>&1 && echo UP || echo DOWN" || echo TIMEOUT
}

sc_helper_git_log_n_commits(){
  [ -z "${1}" ] && N_COMMITS="5" || N_COMMITS="${1}"

  git log -n "${N_COMMITS}" --oneline --format='%h' | xargs -I {} sh -c 'git diff {}^..{}'
}

sc_helper_kube_secret() {
  if [[ "$1" == "-n" ]]; then
    ns=$2
    shift 2
  else
    ns=$(kubectl config view --minify -o jsonpath='{..namespace}')
    [[ -z "$ns" ]] && ns=default
  fi
  secret=$1
  kubectl get secret "$secret" -n "$ns" -o json \
    | jq -r '.data | to_entries[] | "\(.key): \(.value | @base64d)"'
}

sc_helper_git_tag_push() {
  T=$(date -u +"%Y-%m-%d.%H-%M-%S").$(git rev-parse --short HEAD)
  git tag "$T"
  echo "tag: $T"
  read -p "Push Tags? [y/N]: " a
  if [[ $a == [yY] ]]; then
    git push origin "$T"
  fi
}

sc_helper_source_reload() {
  source "${HOME}/.bash_profile"
  echo "🔄 Reloaded ${HOME}/.bash_profile"
}
