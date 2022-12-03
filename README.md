```bash
git init "${HOME}"
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
git checkout linux
clear

INSTALL_PORTABLE="yes" /bin/bash .dotfiles/initialize.sh
```
