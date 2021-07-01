```bash
git init .
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all

rm -f .bashrc .bash_profile .bash_dotfiles .vimrc README.md
git checkout master
```