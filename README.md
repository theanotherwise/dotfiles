```bash
rm -f .bash_profile .bashrc .gitconfig .gitignore .vimrc README.md
rm -rf "${HOME}"/.git 
rm -rf "${HOME}"/.dotfiles
rm -rf "${HOME}"/binaries

git init "${HOME}"
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
git checkout main

```

```bash
python3 "${HOME}"/.dotfiles/init.py
```
