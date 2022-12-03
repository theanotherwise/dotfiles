```bash
find "${HOME}" \
  -mindepth 1 \
  -maxdepth 1 \
  -not \( -path ~/.ssh \) \
  -not \( -path ~/.kube \) \
  -exec rm -rf {} \;
```
 
```bash
git init "${HOME}"
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
git checkout linux
clear

INSTALL_PORTABLE="yes" /bin/bash .dotfiles/initialize.sh
```
