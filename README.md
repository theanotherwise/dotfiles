# .dotfiles

## Requirements

```bash
sudo apt-get install -y \
  openjdk-11-jdk \
  openjdk-17-jdk \
  python3 \
  python3-pip
```

## Cleanup

```bash
rm -rf ${HOME}/binaries
```

```bash
rm -f \
  "${HOME}/.bash_profile" \
  "${HOME}/.bashrc" \
  "${HOME}/.bash_aliases" \
  "${HOME}/.bash_completion" \
  "${HOME}/.gitconfig" \
  "${HOME}/.gitignore" \
  "${HOME}/.vimrc" \
  "${HOME}/README.md" \
  ${HOME}/.git \
  ${HOME}/.dotfiles

```

## Setup

### Fetch `.dotfiles`

```bash
git init "${HOME}"
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
git checkout main
```

### Download Binaries

```bash
python3 ${HOME}/.dotfiles/init.py
```
