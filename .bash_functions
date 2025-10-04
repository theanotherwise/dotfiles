echo "Loading file: $(basename \"${BASH_SOURCE[0]}\")"

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

:

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

# Print primary context info
sc_helper_context_get() {
  local ctx ns gproj asub
  local cR="\033[0m" cV="\033[97m"
  local lK="\033[1;34m" lN="\033[1;34m" lG="\033[1;33m" lA="\033[1;35m"
  local W=14

  if command -v kubectl >/dev/null 2>&1; then
    ctx=$(kubectl config current-context 2>/dev/null)
    ns=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
    [ -z "$ns" ] && ns=default
    [ -n "$ctx" ] || ctx="- (no context)"
  else
    ctx="- (missing: kubectl)"
    ns="-"
  fi

  if command -v gcloud >/dev/null 2>&1; then
    gproj=$(gcloud config get-value project 2>/dev/null)
    [ "$gproj" = "(unset)" ] && gproj=""
    [ -n "$gproj" ] || gproj="-"
  else
    if [ -n "${CLOUDSDK_CORE_PROJECT:-}" ]; then
      gproj="${CLOUDSDK_CORE_PROJECT} (env)"
    else
      gproj="- (missing: gcloud)"
    fi
  fi

  if command -v az >/dev/null 2>&1; then
    asub=$(az account show --query 'name' -o tsv 2>/dev/null)
    [ -n "$asub" ] || asub=$(az account show --query 'id' -o tsv 2>/dev/null)
    [ -n "$asub" ] || asub="-"
  else
    if [ -n "${AZURE_SUBSCRIPTION_ID:-}" ]; then
      asub="${AZURE_SUBSCRIPTION_ID} (env)"
    else
      asub="- (missing: az)"
    fi
  fi

  local vKc="$cV" vNc="$cV" vGc="$cV" vAc="$cV"

  printf "%b%-${W}s%b %b%s%b\n" "$lK" "Kube:" "$cR" "$vKc" "$ctx" "$cR"
  printf "%b%-${W}s%b %b%s%b\n" "$lN" "Namespace:" "$cR" "$vNc" "$ns" "$cR"
  printf "%b%-${W}s%b %b%s%b\n" "$lG" "GCP (proj.):" "$cR" "$vGc" "$gproj" "$cR"
  printf "%b%-${W}s%b %b%s%b\n" "$lA" "Azure (sub.):" "$cR" "$vAc" "$asub" "$cR"

  # Versions table
}

# Versions summary (Terraform, Terragrunt, kubectl, Helm, Kustomize)
sc_helper_versions() {
  local cR="\033[0m" cV="\033[97m" lK="\033[1;34m" W2=12
  local VT="-" VTG="-" VK="-" VH="-" VKU="-" VG="-" VGR="-" VJQ="-" VYQ="-" VN="-" VYARN="-" VDOCKER="-" VCOMPOSE="-"

  if command -v terraform >/dev/null 2>&1; then
    VT=$(terraform version 2>/dev/null | grep -oE 'v?[0-9]+(\.[0-9]+)+' | head -1 | sed 's/^v//')
    [ -n "$VT" ] || VT="-"
  fi
  if command -v terragrunt >/dev/null 2>&1; then
    VTG=$(terragrunt --version 2>/dev/null | grep -oE 'v?[0-9]+(\.[0-9]+)+' | head -1 | sed 's/^v//')
    [ -n "$VTG" ] || VTG="-"
  fi
  if command -v kubectl >/dev/null 2>&1; then
    VK=$(kubectl version --client --short 2>/dev/null | grep -oE 'v?[0-9]+(\.[0-9]+)+' | head -1 | sed 's/^v//')
    [ -n "$VK" ] || VK="-"
  fi
  if command -v helm >/dev/null 2>&1; then
    VH=$(helm version --short 2>/dev/null | grep -oE 'v?[0-9]+(\.[0-9]+)+' | head -1 | sed 's/^v//')
    [ -n "$VH" ] || VH="-"
  fi
  if command -v kustomize >/dev/null 2>&1; then
    VKU=$(kustomize version --short 2>/dev/null | grep -oE 'v?[0-9]+(\.[0-9]+)+' | head -1 | sed 's/^v//')
    [ -n "$VKU" ] || VKU=$(kustomize version 2>/dev/null | grep -oE 'v?[0-9]+(\.[0-9]+)+' | head -1 | sed 's/^v//')
    [ -n "$VKU" ] || VKU="-"
  fi

  if command -v go >/dev/null 2>&1; then
    VG=$(go version 2>/dev/null | grep -oE 'go[0-9]+(\.[0-9]+)+' | head -1 | sed 's/^go//')
    [ -n "$VG" ] || VG="-"
  fi
  if command -v groovy >/dev/null 2>&1; then
    VGR=$( (groovy --version 2>/dev/null || groovy -version 2>/dev/null) | grep -oE '[0-9]+(\.[0-9]+){1,2}' | head -1)
    [ -n "$VGR" ] || VGR="-"
  fi
  if command -v jq >/dev/null 2>&1; then
    VJQ=$(jq --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
    [ -n "$VJQ" ] || VJQ="-"
  fi
  if command -v yq >/dev/null 2>&1; then
    VYQ=$(yq --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
    [ -n "$VYQ" ] || VYQ="-"
  fi

  if command -v node >/dev/null 2>&1; then
    VN=$(node --version 2>/dev/null | grep -oE 'v?[0-9]+(\.[0-9]+)+' | head -1 | sed 's/^v//')
    [ -n "$VN" ] || VN="-"
  fi
  if command -v yarn >/dev/null 2>&1; then
    VYARN=$(yarn --version 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
    [ -n "$VYARN" ] || VYARN="-"
  fi

  if command -v docker >/dev/null 2>&1; then
    VDOCKER=$(docker --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
    [ -n "$VDOCKER" ] || VDOCKER="-"
    # Prefer plugin syntax; fallback to standalone docker-compose
    VCOMPOSE=$(docker compose version 2>/dev/null | grep -oE 'v?[0-9]+(\.[0-9]+)+' | head -1 | sed 's/^v//')
    if [ -z "$VCOMPOSE" ] && command -v docker-compose >/dev/null 2>&1; then
      VCOMPOSE=$(docker-compose --version 2>/dev/null | grep -oE 'v?[0-9]+(\.[0-9]+)+' | head -1 | sed 's/^v//')
    fi
    [ -n "$VCOMPOSE" ] || VCOMPOSE="-"
  elif command -v docker-compose >/dev/null 2>&1; then
    VCOMPOSE=$(docker-compose --version 2>/dev/null | grep -oE 'v?[0-9]+(\.[0-9]+)+' | head -1 | sed 's/^v//')
    [ -n "$VCOMPOSE" ] || VCOMPOSE="-"
  fi

  local LW=12 VW=16
  # Terraform | Terragrunt
  printf "%b%-${LW}s%b %b%-${VW}s%b  %b%-${LW}s%b %b%-${VW}s%b\n" \
    "$lK" "Terraform:" "$cR" "$cV" "$VT" "$cR" \
    "$lK" "Terragrunt:" "$cR" "$cV" "$VTG" "$cR"
  # yq | jq
  printf "%b%-${LW}s%b %b%-${VW}s%b  %b%-${LW}s%b %b%-${VW}s%b\n" \
    "$lK" "yq:" "$cR" "$cV" "$VYQ" "$cR" \
    "$lK" "jq:" "$cR" "$cV" "$VJQ" "$cR"
  # Node | Yarn
  printf "%b%-${LW}s%b %b%-${VW}s%b  %b%-${LW}s%b %b%-${VW}s%b\n" \
    "$lK" "Node:" "$cR" "$cV" "$VN" "$cR" \
    "$lK" "Yarn:" "$cR" "$cV" "$VYARN" "$cR"
  # Docker | Compose
  printf "%b%-${LW}s%b %b%-${VW}s%b  %b%-${LW}s%b %b%-${VW}s%b\n" \
    "$lK" "Docker:" "$cR" "$cV" "$VDOCKER" "$cR" \
    "$lK" "Compose:" "$cR" "$cV" "$VCOMPOSE" "$cR"
  # Go | Groovy
  printf "%b%-${LW}s%b %b%-${VW}s%b  %b%-${LW}s%b %b%-${VW}s%b\n" \
    "$lK" "Go:" "$cR" "$cV" "$VG" "$cR" \
    "$lK" "Groovy:" "$cR" "$cV" "$VGR" "$cR"
  # kubectl | Helm | Kustomize (3 kolumny)
  printf "%b%-${LW}s%b %b%-${VW}s%b  %b%-${LW}s%b %b%-${VW}s%b  %b%-${LW}s%b %b%-${VW}s%b\n" \
    "$lK" "kubectl:" "$cR" "$cV" "$VK" "$cR" \
    "$lK" "Helm:" "$cR" "$cV" "$VH" "$cR" \
    "$lK" "Kustomize:" "$cR" "$cV" "$VKU" "$cR"
}

