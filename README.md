# .dotfiles

## Requirements

```bash
apt-get install -y \
  openjdk-11-jdk \
  openjdk-17-jdk \
  python3 \
  python3-pip
```

## Cleanup

```bash
rm -rf ~/binaries
```

```bash
rm -f .bash_profile .bashrc .bash_aliases .bash_completion
rm -f .gitconfig .gitignore .vimrc
rm -f  README.md
rm -rf ~/.git ~/.dotfiles
```

## Setup

### Fetch `.dotfiles`

```bash
git init ~/
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
git checkout main
```

### Download Binaries

```bash
python3 ~/.dotfiles/init.py
```
