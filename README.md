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

| Variable 	 | Values                                          	 | Applied To `type`           	 |
|------------|---------------------------------------------------|-------------------------------|
| type     	 | `tar.xz` / `tar.gz` / `zip` / `binary`          	 | 	                             |
| strip    	 | `True` / `False`                                	 | `tar.xz` / `tar.gz` / `zip` 	 |
| inBin    	 | `True` / `False`                                	 | `all`                       	 |
| override 	 | `True` / `False` 	                                | `all`                       	 |

### Description

| Variable 	 | Applied To `type`           	 | Description                                            	 |
|------------|-------------------------------|----------------------------------------------------------|
| type     	 | -	                            | 	                                                        |
| strip    	 | `tar.xz` / `tar.gz` / `zip` 	 | Set `True` to omit first directory  	                    |
| inBin    	 | `all`                       	 | Set `True` if binaries of package are not in `bin/`    	 |
| override 	 | `all`                       	 | Delete package version files and download again        	 |