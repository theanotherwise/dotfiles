```bash
rm -f binaries .bash_profile .bashrc .gitconfig .gitignore .vimrc README.md

git init "${HOME}"
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
git checkout main

```

```bash
git pull && INSTALL_PORTABLE="yes" /bin/bash .dotfiles/initialize.sh
```
