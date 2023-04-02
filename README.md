```bash
git init "${HOME}"
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
git checkout main

clear
```

```bash
INSTALL_PORTABLE="yes" /bin/bash .dotfiles/initialize.sh
```

## Fresh Install

```bash
rm -rf binaries

rm -rf .git .dotfiles

rm -f .bash_profile .bashrc .gitconfig .gitignore .vimrc README.md

git init "${HOME}"
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
git checkout main

INSTALL_PORTABLE="yes" /bin/bash .dotfiles/initialize.sh

```
