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

DOT_HOME="${HOME}" INSTALL_PORTABLE="yes" sudo -E -u root /bin/bash /root/.dotfiles/initialize.sh
```
