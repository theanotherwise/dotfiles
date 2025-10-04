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

Notes:

- Prompt rysowany bez cache; kontekst kube po prawej w PS1.
- Functions, aliases and completions are loaded only for interactive shells.

Profile startup time quickly:

```bash
time bash -ic exit
```