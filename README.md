```bash
find ~/ -mindepth 1 -maxdepth 1 -not \( -path ~/.ssh \) -exec rm -rf {} \;
git init ~/
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all

git checkout linux
```

```bash
INSTALL_PORTABLE="yes" /bin/bash ~/.dotfiles/initialize.sh

DOT_HOME="/root" INSTALL_PORTABLE="yes" sudo -E -u root /bin/bash /root/.dotfiles/initialize.sh
```
