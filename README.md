```bash
git init .
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all

rm -f .bashrc .bash_profile .vimrc 
rm -f .gitignore .dotfiles README.md
git checkout master
```