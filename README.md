# `.dotfiles`

## Setup

```bash
git init "${HOME}"
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
git checkout main

bash .dotfiles
```

----

## Configuration

### Values

| Variable 	 | Values                                          	 |
|------------|---------------------------------------------------|
| type     	 | `tar.xz` / `tar.gz` / `zip` / `binary`          	 |
| strip    	 | `True` / `False`                                	 |
| inBin    	 | `True` / `False`                                	 |
| override 	 | `True` / `False` 	                                |

### Description

| Variable 	 | Applied To `type`           	 | Description                                            	 |
|------------|-------------------------------|----------------------------------------------------------|
| type     	 | -	                            | Type of pacakge to download	                             |
| strip    	 | `tar.xz` / `tar.gz` / `zip` 	 | Set `True` to omit first directory  	                    |
| inBin    	 | `all`                       	 | Set `True` if binaries of package are not in `bin/`    	 |
| override 	 | `all`                       	 | Delete package version files and download again        	 |
| latest     | -                             | Set link to `latest` to specified version                |

---

## Bash startup performance

Environment toggles:

- `DOTFILES_DEBUG=1` – print which dotfile is loading.
- `SC_PROMPT_KUBE_DISABLED=1` – disable kube context (enabled by default).
- `SC_PROMPT_BRANCH_TTL` – seconds to cache git branch (default: 2).
- `SC_PROMPT_KUBE_TTL` – seconds to cache kube context (default: 5).

Notes:

- Prompt content is cached by `sc_prompt_update` via `PROMPT_COMMAND` to avoid
  running `git`/`kubectl` on every prompt render.
- Functions, aliases and completions are loaded only for interactive shells.

Profile startup time quickly:

```bash
time bash -ic exit
```