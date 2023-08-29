```bash
rm -rf "${HOME}"/binaries
```

```bash
rm -f .bash_profile .bashrc .gitconfig .gitignore .vimrc README.md
rm -rf "${HOME}"/.git 
rm -rf "${HOME}"/.dotfiles

git init "${HOME}"
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
git checkout main


python3 "${HOME}"/.dotfiles/init.py
```
