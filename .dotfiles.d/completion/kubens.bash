sc_helper_kube_namespaces_completion()
{
  local curr_arg namespaces

  curr_arg="${COMP_WORDS[COMP_CWORD]:-}"
  namespaces="$(kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{" "}{end}' 2>/dev/null)"
  COMPREPLY=( $(compgen -W "- ${namespaces}" -- "${curr_arg}") )
}
