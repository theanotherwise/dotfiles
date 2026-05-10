if [[ -n "${SC_BASH_SHOW_LOADING:-}" ]]; then
  echo "Loading file: $(basename "${BASH_SOURCE[0]}")"
fi

sc_helper_bashrc_branch() {
  if git branch >/dev/null 2>&1; then
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
  fi
}

sc_helper_bashrc_kube() {
  local kube_ctx

  command -v kubectl >/dev/null 2>&1 || return 0
  kube_ctx="$(kubectl config view --minify -o jsonpath="{.clusters[].name}/{.contexts[].context.namespace}" 2>/dev/null)"
  [ -n "${kube_ctx}" ] || return 0

  printf "%*s\r%s" "$((COLUMNS - 1))" "${kube_ctx}"
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

sc_helper_akamai_staging() {
  local host="${1:-www.reserved.com}"
  nslookup "${host}.edgekey-staging.net" | awk '/^Address: / && $2 !~ /#/ { print $2; exit }'
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

sc_helper_kube_containers() {
  if ! command -v kubectl >/dev/null 2>&1; then
    echo "kubectl not found" 1>&2
    return 127
  fi

  local ns pod
  if [[ "$1" == "-n" ]]; then
    ns="$2"
    pod="$3"
  else
    pod="$1"
    ns="$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)"
    [ -n "${ns}" ] || ns=default
  fi

  if [ -z "${pod}" ] || [ -z "${ns}" ]; then
    echo "Usage: kcontainers [-n namespace] <pod>" 1>&2
    return 2
  fi

  local containers init_containers
  containers="$(kubectl get pod "${pod}" -n "${ns}" -o jsonpath='{range .spec.containers[*]}{.name}{" "}{end}' 2>/dev/null | sed -E 's/[[:space:]]+$//')"
  init_containers="$(kubectl get pod "${pod}" -n "${ns}" -o jsonpath='{range .spec.initContainers[*]}{.name}{" "}{end}' 2>/dev/null | sed -E 's/[[:space:]]+$//')"

  if [ -z "${containers}" ] && [ -z "${init_containers}" ]; then
    if ! kubectl get pod "${pod}" -n "${ns}" >/dev/null 2>&1; then
      echo "Pod '${pod}' not found in namespace '${ns}'" 1>&2
      return 1
    fi
  fi

  [ -n "${containers}" ] || containers="-"
  [ -n "${init_containers}" ] || init_containers="-"

  echo "containers: ${containers}"
  echo "initContainers: ${init_containers}"
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

sc_helper_gitconfig() {
  local identity_file="${HOME}/.gitconfig.identity"

  case "${1:-}" in
    priv)
      git config --file "${identity_file}" user.name "Mateusz Adam Katana"
      git config --file "${identity_file}" user.email "mateusz.adam.katana@gmail.com"
      ;;
    silky)
      git config --file "${identity_file}" user.name "Mateusz Katana"
      git config --file "${identity_file}" user.email "mateusz.katana@silkycoders.com"
      ;;
    irgit)
      git config --file "${identity_file}" user.name "Mateusz Katana"
      git config --file "${identity_file}" user.email "mateusz.katana@irgit.pl"
      ;;
    stonex)
      git config --file "${identity_file}" user.name "Mateusz Katana"
      git config --file "${identity_file}" user.email "mateusz.katana@stonex.com"
      ;;
    citi)
      git config --file "${identity_file}" user.name "Mateusz Katana"
      git config --file "${identity_file}" user.email "mateusz.katana@citi.com"
      ;;
    sc)
      git config --file "${identity_file}" user.name "Mateusz Katana"
      git config --file "${identity_file}" user.email "mateusz.katana@seems.cloud"
      ;;
    psem)
      git config --file "${identity_file}" user.name "Mateusz Katana"
      git config --file "${identity_file}" user.email "mateusz.katana@presemantic.com"
      ;;
    tvn)
      git config --file "${identity_file}" user.name "Mateusz Katana"
      git config --file "${identity_file}" user.email "mateusz_katana@tvn.pl"
      ;;
    *)
      echo "Usage: gitconfig {priv|silky|irgit|stonex|citi|sc|psem|tvn}" >&2
      return 2
      ;;
  esac

  git config --file "${identity_file}" --get-regexp '^user\.(name|email)$'
}

sc_helper_dotreload() {
  source "${HOME}/.bash_profile"
}

sc_helper_dotsetup() {
  bash "${HOME}/.dotfiles"
}

sc_helper_dotfiles_remove_tree_file_by_file() {
  local target="$1"
  local entry restore_nullglob restore_dotglob

  [ -e "${target}" ] || return 0

  if [ -d "${target}" ] && [ ! -L "${target}" ]; then
    restore_nullglob="$(shopt -p nullglob)"
    restore_dotglob="$(shopt -p dotglob)"
    shopt -s nullglob dotglob

    for entry in "${target}"/*; do
      sc_helper_dotfiles_remove_tree_file_by_file "${entry}"
    done

    eval "${restore_nullglob}"
    eval "${restore_dotglob}"

    command rmdir -- "${target}" 2>/dev/null || true
  else
    command rm -f -- "${target}"
  fi
}

sc_helper_dotflush() {
  # Completion cache used by shell startup.
  sc_helper_dotfiles_remove_tree_file_by_file "${HOME}/.dotfiles.cache"

  # Best-effort cleanup of stale installer temp directories.
  local -a _dotfiles_tmp
  local _tmp_dir _restore_nullglob
  _restore_nullglob="$(shopt -p nullglob)"
  shopt -s nullglob
  _dotfiles_tmp=(/tmp/dotfiles-*)
  eval "${_restore_nullglob}"

  for _tmp_dir in "${_dotfiles_tmp[@]}"; do
    [[ "${_tmp_dir}" == /tmp/dotfiles-* ]] || continue
    sc_helper_dotfiles_remove_tree_file_by_file "${_tmp_dir}"
  done
}

sc_helper_dotcache() {
  sc_helper_dotflush

  if [ -f "${HOME}/.bash_completion" ]; then
    unset SC_BASH_COMPLETION_LOADED_PID
    unset SC_BASH_COMPLETION_LOADED
    . "${HOME}/.bash_completion"
  fi
}

sc_helper_pod_status_breakdown() {
  local scope="$1"
  local statuses
  if [ "$scope" = "all" ]; then
    statuses=$(kubectl get pods -A --no-headers 2>/dev/null | awk '{print $4}')
  else
    statuses=$(kubectl get pods -n "$scope" --no-headers 2>/dev/null | awk '{print $4}')
  fi
  [ -n "$statuses" ] || { echo "-"; return; }

  local running pending crash completed error imagepull terminating unknown
  running=$(echo "$statuses" | grep -c '^Running$' 2>/dev/null || true)
  pending=$(echo "$statuses" | grep -c '^Pending$' 2>/dev/null || true)
  crash=$(echo "$statuses" | grep -c 'CrashLoopBackOff' 2>/dev/null || true)
  completed=$(echo "$statuses" | grep -c '^Completed$' 2>/dev/null || true)
  error=$(echo "$statuses" | grep -c '^Error$' 2>/dev/null || true)
  imagepull=$(echo "$statuses" | grep -E -c 'ImagePullBackOff|ErrImagePull' 2>/dev/null || true)
  terminating=$(echo "$statuses" | grep -c 'Terminating' 2>/dev/null || true)
  unknown=$(echo "$statuses" | grep -E -c 'Unknown|Init:' 2>/dev/null || true)
  echo "Run:${running} Pen:${pending} CLB:${crash} Cmp:${completed} Err:${error} Img:${imagepull} Ter:${terminating} Unk:${unknown}"
}

# Print only context (Kube/Namespace/GCP/Azure)
sc_helper_context_info() {
  local ctx ns gproj asub
  local cR="\033[0m" cV="\033[97m"
  local lK="\033[1;34m" lN="\033[1;34m" lG="\033[1;33m" lA="\033[1;35m" lR="\033[1;31m"
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

  printf "\n"
  printf "%b%-${W}s%b %b%s%b\n" "$lR" "Kube:" "$cR" "$cV" "$ctx" "$cR"
  printf "%b%-${W}s%b %b%s%b\n" "$lR" "Namespace:" "$cR" "$cV" "$ns" "$cR"
  printf "%b%-${W}s%b %b%s%b\n" "$lR" "GCP (proj.):" "$cR" "$cV" "$gproj" "$cR"
  printf "%b%-${W}s%b %b%s%b\n" "$lR" "Azure (sub.):" "$cR" "$cV" "$asub" "$cR"
  printf "\n"
}

# Print only live cluster summary
sc_helper_kube_summary() {
  local ctx ns
  local cR="\033[0m" cV="\033[97m" lK="\033[1;34m"
  local W=14

  if command -v kubectl >/dev/null 2>&1; then
    ctx=$(kubectl config current-context 2>/dev/null)
    ns=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
    [ -z "$ns" ] && ns=default
    [ -n "$ctx" ] || ctx="- (no context)"
  else
    ctx=""
    ns=""
  fi

  local pods_all="-" pods_count="-" pods_all_b="-" pods_ns_b="-" pvc_all="-" pvc_ns="-" svc_all="-" svc_ns="-" svc_ext="-" sc_names="-" nodes_count="-" nodes_ready="-" nodes_notready="-" nodes_schedoff="-"
  if command -v kubectl >/dev/null 2>&1 && [ -n "$ctx" ] && [ "$ctx" != "- (no context)" ]; then
    pods_all=$(kubectl get pods -A -o name 2>/dev/null | wc -l | tr -d ' ')
    [ -n "$pods_all" ] || pods_all="-"
    pods_count=$(kubectl get pods -n "$ns" -o name 2>/dev/null | wc -l | tr -d ' ')
    [ -n "$pods_count" ] || pods_count="-"
    pods_all_b=$(sc_helper_pod_status_breakdown all)
    pods_ns_b=$(sc_helper_pod_status_breakdown "$ns")
    pvc_all=$(kubectl get pvc -A -o name 2>/dev/null | wc -l | tr -d ' ')
    [ -n "$pvc_all" ] || pvc_all="-"
    pvc_ns=$(kubectl get pvc -n "$ns" -o name 2>/dev/null | wc -l | tr -d ' ')
    [ -n "$pvc_ns" ] || pvc_ns="-"
    svc_all=$(kubectl get svc -A -o name 2>/dev/null | wc -l | tr -d ' ')
    [ -n "$svc_all" ] || svc_all="-"
    svc_ns=$(kubectl get svc -n "$ns" -o name 2>/dev/null | wc -l | tr -d ' ')
    [ -n "$svc_ns" ] || svc_ns="-"
    svc_ext=$(kubectl get svc -A -o jsonpath='{range .items[*]}{.status.loadBalancer.ingress[*].ip} {.spec.externalIPs[*]}{"\n"}{end}' 2>/dev/null | awk 'NF>0' | wc -l | tr -d ' ')
    [ -n "$svc_ext" ] || svc_ext="-"
    sc_names=$(kubectl get sc -o jsonpath='{range .items[*]}{.metadata.name}{" "}{end}' 2>/dev/null | sed -E 's/[[:space:]]+$//')
    [ -n "$sc_names" ] || sc_names="-"
    nodes_count=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
    [ -n "$nodes_count" ] || nodes_count="-"
    nodes_ready=$(kubectl get nodes --no-headers 2>/dev/null | awk '{print $2}' | grep -c '^Ready$' 2>/dev/null || true)
    nodes_notready=$(kubectl get nodes --no-headers 2>/dev/null | awk '{print $2}' | grep -vc '^Ready$' 2>/dev/null || true)
    nodes_schedoff=$(kubectl get nodes -o json 2>/dev/null | jq -r '.items[] | select(.spec.unschedulable==true) | .metadata.name' | wc -l | tr -d ' ')
  fi

  printf "\n"
  printf "%b%-${W}s%b %bNs:%s All:%s%b  %b%s%b\n" "$lK" "Pods:" "$cR" "$cV" "$pods_count" "$pods_all" "$cR" "$cV" "$pods_all_b" "$cR"
  printf "%b%-${W}s%b %bNs:%s All:%s%b\n" "$lK" "PVC:" "$cR" "$cV" "$pvc_ns" "$pvc_all" "$cR"
  printf "%b%-${W}s%b %bNs:%s All:%s Ext:%s%b\n" "$lK" "Svc:" "$cR" "$cV" "$svc_ns" "$svc_all" "$svc_ext" "$cR"
  printf "%b%-${W}s%b %b%s%b\n" "$lK" "SC:" "$cR" "$cV" "$sc_names" "$cR"
  printf "%b%-${W}s%b %b%s%b  %b(Ready:%s NotReady:%s SchedOff:%s)%b\n" "$lK" "Nodes:" "$cR" "$cV" "$nodes_count" "$cR" "$cV" "$nodes_ready" "$nodes_notready" "$nodes_schedoff" "$cR"
  printf "\n"
}

sc_helper_kube() {
  sc_helper_kube_summary
}

sc_helper_po() {
  case "$1" in
    get|"")
      sc_helper_context_info
      ;;
    kube)
      sc_helper_kube_summary
      ;;
    *)
      echo "Usage: po {get|kube}" 1>&2
      return 2
      ;;
  esac
}

# Print primary context info (only)
sc_helper_context_get() {
  sc_helper_context_info
}

sc_helper_zseed() {
  if ! command -v zoxide >/dev/null 2>&1; then
    echo "zoxide not found" 1>&2
    return 127
  fi

  local root="${1:-${HOME}/projects}"
  if [ ! -d "${root}" ]; then
    echo "Directory not found: ${root}" 1>&2
    return 1
  fi

  zoxide query -l 2>/dev/null \
    | while IFS= read -r dir; do
        case "${dir}" in
          */.git|*/.git/*|*/node_modules|*/node_modules/*|*/.terraform|*/.terraform/*|*/.terragrunt-cache|*/.terragrunt-cache/*|*/.venv|*/.venv/*|*/__pycache__|*/__pycache__/*)
            zoxide remove "${dir}"
            ;;
        esac
      done

  find "${root}" \
    \( -name .git -o -name node_modules -o -name .terraform -o -name .terragrunt-cache -o -name .venv -o -name __pycache__ \) -prune \
    -o -type d -print0 \
    | while IFS= read -r -d '' dir; do
        zoxide add "${dir}"
      done
}

sc_helper_zoxide_init() {
  command -v zoxide >/dev/null 2>&1 || return 0

  local zoxide_excludes
  zoxide_excludes="${HOME}/**/.git:${HOME}/**/.git/**:${HOME}/**/node_modules:${HOME}/**/node_modules/**:${HOME}/**/.terraform:${HOME}/**/.terraform/**:${HOME}/**/.terragrunt-cache:${HOME}/**/.terragrunt-cache/**:${HOME}/**/.venv:${HOME}/**/.venv/**:${HOME}/**/__pycache__:${HOME}/**/__pycache__/**"

  case ":${_ZO_EXCLUDE_DIRS:-}:" in
    *":${zoxide_excludes}:"*) ;;
    *) export _ZO_EXCLUDE_DIRS="${_ZO_EXCLUDE_DIRS:+${_ZO_EXCLUDE_DIRS}:}${zoxide_excludes}" ;;
  esac

  eval "$(zoxide init bash)"
  declare -F sc_helper_zoxide_z_completion >/dev/null 2>&1 && complete -F sc_helper_zoxide_z_completion -o filenames z
}

sc_helper_fzf_init() {
  command -v fzf >/dev/null 2>&1 || return 0
  command -v fd >/dev/null 2>&1 || return 0

  local fd_excludes fd_base walker_skip
  fd_excludes="--exclude '.*' --exclude .git --exclude .hg --exclude .svn --exclude .pyenv --exclude __pycache__ --exclude node_modules --exclude .venv --exclude venv --exclude env --exclude .tox --exclude .nox --exclude .pytest_cache --exclude .mypy_cache --exclude .ruff_cache --exclude .cache --exclude .terraform --exclude .terragrunt-cache --exclude .next --exclude .nuxt --exclude .turbo --exclude .parcel-cache --exclude .pnpm-store --exclude .yarn --exclude dist --exclude build --exclude target --exclude coverage --exclude vendor"
  fd_base="fd --color=never --strip-cwd-prefix ${fd_excludes}"

  export FZF_DEFAULT_COMMAND="${fd_base} --type f --type d"
  export FZF_CTRL_T_COMMAND="${fd_base} --type f --type d"
  export FZF_ALT_C_COMMAND="${fd_base} --type d"

  if fzf --help 2>/dev/null | grep -q -- '--walker-skip'; then
    walker_skip=".git,.hg,.svn,.pyenv,__pycache__,node_modules,.venv,venv,env,.tox,.nox,.pytest_cache,.mypy_cache,.ruff_cache,.cache,.terraform,.terragrunt-cache,.next,.nuxt,.turbo,.parcel-cache,.pnpm-store,.yarn,dist,build,target,coverage,vendor"
    case " ${FZF_DEFAULT_OPTS:-} " in
      *" --walker-skip=${walker_skip} "*) ;;
      *) export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+${FZF_DEFAULT_OPTS} }--walker-skip=${walker_skip}" ;;
    esac
  fi
}

sc_helper_zoxide_z_completion() {
  command -v zoxide >/dev/null 2>&1 || return 0

  local cur path name candidate
  local seen=$'\n'
  local -a query_terms local_dirs matches

  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  case "${cur}" in
    -*)
      return 0
      ;;
    */*|~*)
      while IFS= read -r candidate; do
        COMPREPLY+=("${candidate}")
      done < <(compgen -A directory -- "${cur}" 2>/dev/null || true)
      return 0
      ;;
  esac

  local i
  for ((i = 1; i < COMP_CWORD; i++)); do
    [ -n "${COMP_WORDS[i]}" ] && query_terms+=("${COMP_WORDS[i]}")
  done

  while IFS= read -r candidate; do
    local_dirs+=("${candidate}")
  done < <(compgen -A directory -- "${cur}" 2>/dev/null || true)
  for candidate in "${local_dirs[@]}"; do
    candidate="${candidate%/}"
    [ -n "${candidate}" ] || continue
    matches+=("${candidate}")
    seen+="${candidate}"$'\n'
  done

  if [ -z "${cur}" ] && [ "${#query_terms[@]}" -eq 0 ]; then
    COMPREPLY=("${matches[@]}")
    return 0
  fi

  while IFS= read -r path; do
    name="${path##*/}"
    [ -n "${name}" ] || continue
    [ -z "${cur}" ] || [[ "${name}" == "${cur}"* ]] || continue

    for candidate in "${query_terms[@]}"; do
      [[ "${path}" == *"${candidate}"* ]] || continue 2
    done

    [[ "${seen}" == *$'\n'"${name}"$'\n'* ]] && continue
    matches+=("${name}")
    seen+="${name}"$'\n'
  done < <(zoxide query -l 2>/dev/null)

  COMPREPLY=("${matches[@]}")
}

# Versions summary (Terraform, Terragrunt, kubectl, Helm, Kustomize)
sc_helper_versions() {
  local cR="\033[0m" cV="\033[97m" lK="\033[1;34m" W2=12
  local VT="-" VTG="-" VK="-" VH="-" VKU="-" VG="-" VGR="-" VJQ="-" VYQ="-" VN="-" VYARN="-" VDOCKER="-" VCOMPOSE="-"

  printf "\n"

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
    VCOMPOSE=$(docker compose version 2>/dev/null | grep -oE 'v?[0-9]+(\.[0-9]+)+' | head -1 | sed 's/^v//')
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
  printf "\n"
}

sc_helper_helm_unittest_binary() {
  local bin_dir="${HOME}/binaries/helm-unittest/latest/bin"
  local candidate path

  [ -d "${bin_dir}" ] || return 1

  for candidate in untt untt-macos-arm64 untt-macos-amd64 untt-linux-arm64 untt-linux-amd64; do
    path="${bin_dir}/${candidate}"
    if [ -x "${path}" ] && [ ! -d "${path}" ]; then
      printf "%s\n" "${path}"
      return 0
    fi
  done

  path="$(find -L "${bin_dir}" -maxdepth 1 -type f -perm -111 -name 'untt*' 2>/dev/null | sort | head -1)"
  [ -n "${path}" ] || return 1
  printf "%s\n" "${path}"
}

sc_helper_helm_unittest() {
  local binary

  binary="$(sc_helper_helm_unittest_binary)"
  if [ -z "${binary}" ]; then
    echo "helm-unittest binary not found in ${HOME}/binaries/helm-unittest/latest/bin" 1>&2
    return 127
  fi

  if [ "$#" -eq 1 ]; then
    case "${1}" in
      --version|version)
        sc_helper_dotversions_version helm-unittest "${binary}"
        return 0
        ;;
    esac
  fi

  "${binary}" "$@"
}

sc_helper_okd_binaries() {
  local bin_dir="${HOME}/binaries/okd/latest/bin"

  [ -d "${bin_dir}" ] || return 1

  find -L "${bin_dir}" -maxdepth 1 -type f -perm -111 -name 'oc[0-9]*' 2>/dev/null | sort -V
}

sc_helper_dotversions_binary() {
  local package="$1"
  local bin_dir="${HOME}/binaries/${package}/latest/bin"
  local candidate path name

  [ -d "${bin_dir}" ] || return 1

  case "${package}" in
    helm-unittest)
      sc_helper_helm_unittest_binary
      return 0
      ;;
    kube-popeye)
      candidate="popeye"
      ;;
    okd)
      sc_helper_okd_binaries | tail -1
      return 0
      ;;
    opentofu|tofu)
      candidate="tofu"
      ;;
    ripgrep)
      candidate="rg"
      ;;
    *)
      candidate="${package}"
      ;;
  esac

  if [ -x "${bin_dir}/${candidate}" ] && [ ! -d "${bin_dir}/${candidate}" ]; then
    printf "%s\n" "${bin_dir}/${candidate}"
    return 0
  fi

  while IFS= read -r path; do
    name="${path##*/}"
    case "${name}" in
      .*|*.1|*.bat|*.cmd|*.ico|*.js|*.md|*.txt|*.yaml|*.yml|*_completion|CHANGELOG*|COPYING|LICENSE*|README*|UNLICENSE|m2.conf|plugin.yaml)
        continue
        ;;
    esac

    printf "%s\n" "${path}"
    return 0
  done < <(find -L "${bin_dir}" -maxdepth 1 -type f -perm -111 2>/dev/null | sort)

  return 1
}

sc_helper_dotversions_exec() {
  local timeout_cmd

  if timeout_cmd="$(type -P timeout 2>/dev/null)"; then
    "${timeout_cmd}" 5 "$@"
  elif timeout_cmd="$(type -P gtimeout 2>/dev/null)"; then
    "${timeout_cmd}" 5 "$@"
  else
    "$@"
  fi
}

sc_helper_dotversions_embedded_version() {
  local binary="$1"
  local version

  command -v strings >/dev/null 2>&1 || return 1

  version="$(
    strings "${binary}" 2>/dev/null \
      | sed -nE 's/.*build[.]version=([0-9][0-9A-Za-z_.-]*).*/\1/p' \
      | head -1
  )"
  if printf "%s\n" "${version}" | grep -Eq '^[0-9]+([.][0-9A-Za-z_-]+)*$'; then
    printf "%s\n" "${version}"
    return 0
  fi

  version="$(
    strings "${binary}" 2>/dev/null \
      | grep -E '^[0-9]+([.][0-9A-Za-z_-]+)+$' \
      | head -1
  )"
  if [ -n "${version}" ]; then
    printf "%s\n" "${version}"
    return 0
  fi

  return 1
}

sc_helper_dotversions_version() {
  local package="$1"
  local binary="$2"
  local variants variant output status version name

  if [ "${package}" = "helm-unittest" ]; then
    version="$(sc_helper_dotversions_embedded_version "${binary}")"
    if [ -n "${version}" ]; then
      printf "%s\n" "${version}"
    else
      printf "%s\n" "-"
    fi
    return 0
  fi

  case "${package}" in
    go|opentofu|terraform|tofu)
      variants="version
--version"
      ;;
    argocd)
      variants="version --client --short
version --client
--version"
      ;;
    groovy)
      variants="--version
-version"
      ;;
    helm)
      variants="version --short
version
--version"
      ;;
    kubectl|okd)
      variants="version --client --short
version --client
version
--version"
      ;;
    kustomize)
      variants="version --short
version
--version"
      ;;
    terragrunt)
      variants="--version
version"
      ;;
    *)
      variants="--version
version
-v
-version
-V"
      ;;
  esac

  while IFS= read -r variant; do
    [ -n "${variant}" ] || continue
    # Intentionally split simple version-flag variants into separate arguments.
    output="$(sc_helper_dotversions_exec "${binary}" ${variant} 2>&1)"
    status=$?
    [ "${status}" -eq 0 ] || continue
    output="$(printf "%s\n" "${output}" | sed '/^[[:space:]]*$/d' | sed -n '1,20p')"
    [ -n "${output}" ] || continue

    if [ "${package}" = "go" ]; then
      version="$(printf "%s\n" "${output}" | grep -oE 'go[0-9]+([.][0-9A-Za-z_-]+)+' | head -1 | sed 's/^go//')"
    else
      version="$(printf "%s\n" "${output}" | grep -oE 'v?[0-9]+([.][0-9A-Za-z_-]+)+' | head -1 | sed 's/^v//')"
    fi

    if [ -n "${version}" ]; then
      printf "%s\n" "${version}"
      return 0
    fi
  done <<< "${variants}"

  if [ "${package}" = "okd" ]; then
    name="${binary##*/}"
    case "${name}" in
      oc[0-9]*)
        version="${name#oc}"
        if printf "%s\n" "${version}" | grep -Eq '^[0-9]+([.][0-9A-Za-z_-]+)*$'; then
          printf "%s\n" "${version}"
          return 0
        fi
        ;;
    esac
  fi

  printf "%s\n" "-"
}

sc_helper_dotversions_description() {
  local tool="$1"

  case "${tool}" in
    actionlint) printf "%s\n" "Lints GitHub Actions workflow YAML" ;;
    age) printf "%s\n" "Encrypts files with public/private keys" ;;
    argocd) printf "%s\n" "Manages Argo CD apps and syncs" ;;
    amass) printf "%s\n" "Maps external attack surface assets" ;;
    asnmap) printf "%s\n" "Maps organizations and ASNs to CIDRs" ;;
    bat) printf "%s\n" "cat with syntax highlighting and paging" ;;
    conftest) printf "%s\n" "Tests config files with OPA/Rego policies" ;;
    containerd) printf "%s\n" "Low-level container runtime used by Docker" ;;
    cosign) printf "%s\n" "Signs and verifies container images" ;;
    delta) printf "%s\n" "Syntax-highlighted pager for git diffs" ;;
    docker\ client) printf "%s\n" "Docker command-line client" ;;
    docker\ compose) printf "%s\n" "Runs multi-container Docker apps" ;;
    docker\ engine) printf "%s\n" "Docker daemon and API server" ;;
    docker-init) printf "%s\n" "Tiny init process used inside containers" ;;
    dnsx) printf "%s\n" "Resolves DNS records for host lists" ;;
    fd) printf "%s\n" "Fast, friendly alternative to find" ;;
    ffuf) printf "%s\n" "Fuzzes paths, vhosts, and parameters" ;;
    fzf) printf "%s\n" "Interactive fuzzy picker for lists" ;;
    gau) printf "%s\n" "Fetches known URLs from public archives" ;;
    gh) printf "%s\n" "GitHub CLI for repos, PRs, and issues" ;;
    github-mcp-server) printf "%s\n" "MCP bridge for GitHub automation" ;;
    go) printf "%s\n" "Go compiler and developer toolchain" ;;
    groovy) printf "%s\n" "JVM scripting language runtime" ;;
    grype) printf "%s\n" "Scans images and filesystems for CVEs" ;;
    helm) printf "%s\n" "Kubernetes package manager for charts" ;;
    helm-unittest) printf "%s\n" "Unit tests for Helm chart templates" ;;
    helmfile) printf "%s\n" "Declares and syncs Helm releases" ;;
    helmify) printf "%s\n" "Converts Kubernetes YAML into Helm charts" ;;
    httpx) printf "%s\n" "Probes live HTTP services and metadata" ;;
    jq) printf "%s\n" "Filters and transforms JSON data" ;;
    k3d) printf "%s\n" "Runs local k3s clusters in Docker" ;;
    k6) printf "%s\n" "Scriptable HTTP and load test runner" ;;
    k9s) printf "%s\n" "Terminal UI for Kubernetes clusters" ;;
    katana) printf "%s\n" "Crawls web apps for URLs and endpoints" ;;
    kube-capacity) printf "%s\n" "Shows Kubernetes node and pod resource use" ;;
    kube-linter) printf "%s\n" "Finds Kubernetes manifest problems" ;;
    kube-popeye|popeye) printf "%s\n" "Audits live Kubernetes cluster hygiene" ;;
    kubeconform) printf "%s\n" "Validates manifests against Kubernetes schemas" ;;
    kubectl) printf "%s\n" "Kubernetes CLI" ;;
    kubectl-neat) printf "%s\n" "Removes noise from kubectl YAML output" ;;
    kubectx) printf "%s\n" "Switches the current Kubernetes context" ;;
    kubens) printf "%s\n" "Switches the current Kubernetes namespace" ;;
    kubent) printf "%s\n" "Finds removed or deprecated Kubernetes APIs" ;;
    kubespy) printf "%s\n" "Watches Kubernetes resource rollouts" ;;
    kubetail) printf "%s\n" "Tails logs from many Kubernetes pods" ;;
    kustomize) printf "%s\n" "Builds patched Kubernetes manifests" ;;
    mapcidr) printf "%s\n" "Expands and slices IP/CIDR ranges" ;;
    mvn) printf "%s\n" "Builds and tests Maven/JVM projects" ;;
    naabu) printf "%s\n" "Finds open ports for recon targets" ;;
    node) printf "%s\n" "JavaScript runtime for CLIs and apps" ;;
    nuclei) printf "%s\n" "Runs template-based security checks" ;;
    oc[0-9]*) printf "%s\n" "OpenShift/OKD command-line client" ;;
    okd) printf "%s\n" "OpenShift/OKD CLI version bundle" ;;
    oras) printf "%s\n" "Pushes and pulls OCI registry artifacts" ;;
    pike) printf "%s\n" "Maps Terraform plans to IAM permissions" ;;
    pnpm) printf "%s\n" "Fast disk-efficient JS package manager" ;;
    ripgrep|rg) printf "%s\n" "Recursive regex search across files" ;;
    runc) printf "%s\n" "OCI container runtime used by Docker" ;;
    shellcheck) printf "%s\n" "Finds bugs and pitfalls in shell scripts" ;;
    shfmt) printf "%s\n" "Formats shell scripts consistently" ;;
    sops) printf "%s\n" "Encrypts YAML/JSON/env config files" ;;
    stern) printf "%s\n" "Streams logs from matching Kubernetes pods" ;;
    subfinder) printf "%s\n" "Finds subdomains from OSINT sources" ;;
    syft) printf "%s\n" "Generates SBOMs for images and filesystems" ;;
    terraform) printf "%s\n" "Plans and applies infrastructure changes" ;;
    terragrunt) printf "%s\n" "DRY wrapper around Terraform/OpenTofu" ;;
    terrascan) printf "%s\n" "Scans IaC for security and compliance issues" ;;
    tflint) printf "%s\n" "Lints Terraform modules and provider usage" ;;
    tfsec) printf "%s\n" "Finds Terraform security issues" ;;
    tofu|opentofu) printf "%s\n" "OpenTofu infrastructure as code CLI" ;;
    trivy) printf "%s\n" "Scans images, repos, and configs for risk" ;;
    tlsx) printf "%s\n" "Collects TLS certs and fingerprints" ;;
    uv) printf "%s\n" "Fast Python package and environment manager" ;;
    yarn) printf "%s\n" "JavaScript package manager and script runner" ;;
    yq) printf "%s\n" "Filters and edits YAML/JSON data" ;;
    zoxide) printf "%s\n" "cd replacement ranked by frecency" ;;
    *) printf "%s\n" "Local CLI from the binaries directory" ;;
  esac
}

sc_helper_dotversions_category() {
  local tool="$1"

  case "${tool}" in
    containerd|docker\ client|docker\ compose|docker\ engine|docker-init|k3d|oras|runc)
      printf "%s\n" "Containers"
      ;;
    argocd|helm|helm-unittest|helmfile|helmify|k9s|kube-capacity|kube-linter|kube-popeye|popeye|kubeconform|kubectl|kubectl-neat|kubectx|kubens|kubent|kubespy|kubetail|kustomize|oc[0-9]*|okd|stern)
      printf "%s\n" "Kubernetes"
      ;;
    opentofu|pike|terraform|terragrunt|terrascan|tflint|tfsec|tofu)
      printf "%s\n" "IaC"
      ;;
    age|conftest|cosign|grype|sops|syft|trivy)
      printf "%s\n" "Security"
      ;;
    actionlint|gh|github-mcp-server)
      printf "%s\n" "GitHub"
      ;;
    go|groovy|mvn|node|pnpm|uv|yarn)
      printf "%s\n" "Languages and Build"
      ;;
    bat|delta|fd|fzf|jq|ripgrep|rg|shellcheck|shfmt|yq|zoxide)
      printf "%s\n" "Shell and Terminal"
      ;;
    k6)
      printf "%s\n" "Testing and Load"
      ;;
    amass|asnmap|dnsx|ffuf|gau|httpx|katana|mapcidr|naabu|nuclei|subfinder|tlsx)
      printf "%s\n" "Recon"
      ;;
    *)
      printf "%s\n" "Other"
      ;;
  esac
}

sc_helper_dotversions_category_order() {
  printf "%s\n" \
    "Containers" \
    "Kubernetes" \
    "IaC" \
    "Security" \
    "GitHub" \
    "Languages and Build" \
    "Shell and Terminal" \
    "Testing and Load" \
    "Recon" \
    "Other"
}

sc_helper_dotversions_example() {
  local tool="$1"

  case "${tool}" in
    actionlint) printf "%s\n" "actionlint .github/workflows" ;;
    age) printf "%s\n" "age -e file.txt" ;;
    argocd) printf "%s\n" "argocd app list" ;;
    amass) printf "%s\n" "amass enum -d example.com" ;;
    asnmap) printf "%s\n" "asnmap -org GOOGLE -silent" ;;
    bat) printf "%s\n" "bat file.txt" ;;
    conftest) printf "%s\n" "conftest test policy.yaml" ;;
    containerd) printf "%s\n" "docker version" ;;
    cosign) printf "%s\n" "cosign verify image" ;;
    delta) printf "%s\n" "delta diff.patch" ;;
    docker\ client) printf "%s\n" "docker version" ;;
    docker\ compose) printf "%s\n" "docker compose ps" ;;
    docker\ engine) printf "%s\n" "docker info" ;;
    docker-init) printf "%s\n" "docker version" ;;
    dnsx) printf "%s\n" "dnsx -l hosts.txt -a -resp" ;;
    fd) printf "%s\n" "fd pattern" ;;
    ffuf) printf "%s\n" "ffuf -u https://example.com/FUZZ -w words.txt" ;;
    fzf) printf "%s\n" "fzf" ;;
    gau) printf "%s\n" "gau example.com" ;;
    gh) printf "%s\n" "gh repo view" ;;
    github-mcp-server) printf "%s\n" "github-mcp-server stdio" ;;
    go) printf "%s\n" "go test ./..." ;;
    groovy) printf "%s\n" "groovy script.groovy" ;;
    grype) printf "%s\n" "grype nginx:latest" ;;
    helm) printf "%s\n" "helm list -A" ;;
    helm-unittest) printf "%s\n" "helm-unittest charts/app" ;;
    helmfile) printf "%s\n" "helmfile list" ;;
    helmify) printf "%s\n" "helmify k8s.yaml" ;;
    httpx) printf "%s\n" "httpx -l hosts.txt -sc -title" ;;
    jq) printf "%s\n" "jq . file.json" ;;
    k3d) printf "%s\n" "k3d cluster list" ;;
    k6) printf "%s\n" "k6 run test.js" ;;
    k9s) printf "%s\n" "k9s" ;;
    katana) printf "%s\n" "katana -u https://example.com" ;;
    kube-capacity) printf "%s\n" "kube-capacity" ;;
    kube-linter) printf "%s\n" "kube-linter lint manifests" ;;
    kube-popeye|popeye) printf "%s\n" "popeye" ;;
    kubeconform) printf "%s\n" "kubeconform manifests" ;;
    kubectl) printf "%s\n" "kubectl get pods" ;;
    kubectl-neat) printf "%s\n" "kubectl-neat pod.yaml" ;;
    kubectx) printf "%s\n" "kubectx prod" ;;
    kubens) printf "%s\n" "kubens default" ;;
    kubent) printf "%s\n" "kubent" ;;
    kubespy) printf "%s\n" "kubespy trace deploy/app" ;;
    kubetail) printf "%s\n" "kubetail app" ;;
    kustomize) printf "%s\n" "kustomize build ." ;;
    mapcidr) printf "%s\n" "mapcidr -cidr 10.0.0.0/24" ;;
    mvn) printf "%s\n" "mvn test" ;;
    naabu) printf "%s\n" "naabu -host example.com" ;;
    node) printf "%s\n" "node app.js" ;;
    nuclei) printf "%s\n" "nuclei -u https://example.com" ;;
    oc[0-9]*) printf "%s\n" "${tool} get pods" ;;
    okd) printf "%s\n" "oc4.11 get pods" ;;
    oras) printf "%s\n" "oras repo tags registry/repo" ;;
    pike) printf "%s\n" "pike scan" ;;
    pnpm) printf "%s\n" "pnpm test" ;;
    ripgrep|rg) printf "%s\n" "rg pattern" ;;
    runc) printf "%s\n" "docker version" ;;
    shellcheck) printf "%s\n" "shellcheck script.sh" ;;
    shfmt) printf "%s\n" "shfmt -w script.sh" ;;
    sops) printf "%s\n" "sops file.yaml" ;;
    stern) printf "%s\n" "stern app -n ns" ;;
    subfinder) printf "%s\n" "subfinder -d example.com" ;;
    syft) printf "%s\n" "syft nginx:latest" ;;
    terraform) printf "%s\n" "terraform plan" ;;
    terragrunt) printf "%s\n" "terragrunt run plan" ;;
    terrascan) printf "%s\n" "terrascan scan" ;;
    tflint) printf "%s\n" "tflint" ;;
    tfsec) printf "%s\n" "tfsec ." ;;
    tofu|opentofu) printf "%s\n" "tofu plan" ;;
    trivy) printf "%s\n" "trivy image nginx:latest" ;;
    tlsx) printf "%s\n" "tlsx -u example.com -san" ;;
    uv) printf "%s\n" "uv run pytest" ;;
    yarn) printf "%s\n" "yarn test" ;;
    yq) printf "%s\n" "yq . file.yaml" ;;
    zoxide) printf "%s\n" "z project" ;;
    *) printf "%s\n" "${tool} --help" ;;
  esac
}

sc_helper_dotversions_print_row() {
  local tool="$1"
  local version="$2"
  local category description example

  [ -n "${version}" ] || version="-"
  version="${version#v}"

  category="$(sc_helper_dotversions_category "${tool}")"
  description="$(sc_helper_dotversions_description "${tool}")"
  example="$(sc_helper_dotversions_example "${tool}")"

  printf "%s\t%s\t%s\t%s\t%s\n" "${category}" "${tool}" "${version}" "${description}" "${example}"
}

sc_helper_dotversions_print_table_row() {
  local category="$1"
  local tool="$2"
  local version="$3"
  local description="$4"
  local example="$5"

  printf "| %-20s | %-24s | %-20s | %-48s | %-40s |\n" "${category}" "${tool}" "${version}" "${description}" "${example}"
}

sc_helper_dotversions_print_grouped_rows() {
  local rows_dir="$1"
  local category row_category tool version description example display_category last_category

  last_category=""

  while IFS= read -r category; do
    while IFS="$(printf "\t")" read -r row_category tool version description example; do
      [ -n "${row_category}" ] || continue
      [ "${row_category}" = "${category}" ] || continue

      display_category="${row_category}"
      if [ "${row_category}" = "${last_category}" ]; then
        display_category=""
      fi

      sc_helper_dotversions_print_table_row "${display_category}" "${tool}" "${version}" "${description}" "${example}"
      last_category="${row_category}"
    done < <(cat "${rows_dir}"/*.row 2>/dev/null)
  done < <(sc_helper_dotversions_category_order)
}

sc_helper_dotversions_docker_rows() {
  local output compose_version

  command -v docker >/dev/null 2>&1 || return 0

  output="$(sc_helper_dotversions_exec docker version 2>/dev/null || true)"
  if [ -n "${output}" ]; then
    printf "%s\n" "${output}" | awk '
      /^Client:/ {
        section="client"
        next
      }
      /^Server:/ {
        section="server"
        next
      }
      /^[[:space:]]Engine:/ {
        section="engine"
        next
      }
      /^[[:space:]]containerd:/ {
        section="containerd"
        next
      }
      /^[[:space:]]runc:/ {
        section="runc"
        next
      }
      /^[[:space:]]docker-init:/ {
        section="docker-init"
        next
      }
      section == "client" && /^[[:space:]]+Version:/ {
        print "docker client\t" $2
        section=""
        next
      }
      section == "engine" && /^[[:space:]]+Version:/ {
        print "docker engine\t" $2
        section=""
        next
      }
      section == "containerd" && /^[[:space:]]+Version:/ {
        print "containerd\t" $2
        section=""
        next
      }
      section == "runc" && /^[[:space:]]+Version:/ {
        print "runc\t" $2
        section=""
        next
      }
      section == "docker-init" && /^[[:space:]]+Version:/ {
        print "docker-init\t" $2
        section=""
        next
      }
    ' | while IFS="$(printf "\t")" read -r tool version; do
      sc_helper_dotversions_print_row "${tool}" "${version}"
    done
  fi

  compose_version="$(sc_helper_dotversions_exec docker compose version 2>/dev/null | grep -oE 'v?[0-9]+([.][0-9A-Za-z_-]+)+' | head -1 | sed 's/^v//')"
  if [ -n "${compose_version}" ]; then
    sc_helper_dotversions_print_row "docker compose" "${compose_version}"
  fi
}

sc_helper_dotversions_row() {
  local package="$1"
  local binary name version

  if [ "${package}" = "okd" ]; then
    while IFS= read -r binary; do
      name="${binary##*/}"
      version="${name#oc}"
      sc_helper_dotversions_print_row "${name}" "${version}"
    done < <(sc_helper_okd_binaries)
    return 0
  fi

  binary="$(sc_helper_dotversions_binary "${package}")"

  if [ -n "${binary}" ]; then
    version="$(sc_helper_dotversions_version "${package}" "${binary}")"
  else
    version="-"
  fi

  sc_helper_dotversions_print_row "${package}" "${version}"
}

sc_helper_dotversions() {
  local binaries_dir="${1:-${HOME}/binaries}"
  local package_dir package tmp_dir row_file index pids pid status

  if [ ! -d "${binaries_dir}" ]; then
    printf "Missing binaries directory: %s\n" "${binaries_dir}" >&2
    return 1
  fi

  tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/dotversions.XXXXXX")" || return 1
  sc_helper_dotversions_docker_rows >"${tmp_dir}/00000.docker.row"

  (
    index=1
    pids=""
    status=0

    while IFS= read -r package_dir; do
      package="${package_dir##*/}"
      case "${package}" in
        docker?compose)
          continue
          ;;
      esac

      row_file="${tmp_dir}/$(printf "%05d" "${index}").row"

      sc_helper_dotversions_row "${package}" >"${row_file}" &
      pids="${pids} $!"
      index=$((index + 1))
    done < <(find -L "${binaries_dir}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)

    for pid in ${pids}; do
      wait "${pid}" || status=1
    done

    exit "${status}"
  )
  status=$?

  printf "| %-20s | %-24s | %-20s | %-48s | %-40s |\n" "CATEGORY" "TOOL" "VERSION" "DESCRIPTION" "EXAMPLE"
  printf "| %-20s | %-24s | %-20s | %-48s | %-40s |\n" "--------------------" "------------------------" "--------------------" "------------------------------------------------" "----------------------------------------"

  sc_helper_dotversions_print_grouped_rows "${tmp_dir}"

  command rm -rf "${tmp_dir}"
  return "${status}"
}
