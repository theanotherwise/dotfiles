# `.dotfiles`

## Setup

```bash
git -C "${HOME}" init
git -C "${HOME}" remote add origin https://github.com/theanotherwise/dotfiles.git
git -C "${HOME}" pull origin main
bash "${HOME}/.dotfiles"
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
 