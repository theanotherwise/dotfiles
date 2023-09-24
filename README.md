```bash
rm -rf ~/binaries
```

```bash
rm -f .bash_profile .bashrc .bash_aliases .bash_completion
rm -f .gitconfig .gitignore .vimrc
rm -f  README.md
rm -rf ~/.git ~/.dotfiles 

git init ~/
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
git checkout main
```

```bash
python3 ~/.dotfiles/init.py
```
