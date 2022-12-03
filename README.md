```bash
git init "${HOME}"
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
git checkout linux

clear
```

```bash
INSTALL_PORTABLE="yes" /bin/bash .dotfiles/initialize.sh
```
