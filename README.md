```bash
git init .
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
```

```bash
rm -f .bashrc .bash_profile .vimrc .gitignore .dotfiles README.md

git checkout master
```