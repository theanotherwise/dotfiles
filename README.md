```bash
git init .
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
```

```bash
rm -f .bashrc .bash_profile .vimrc .gitignore .dotfiles

git checkout master

rm -f README.md
```
