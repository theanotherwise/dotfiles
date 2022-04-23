```bash
find ~/ -mindepth 1 -maxdepth 1 -not \( -path ./.ssh \) -exec rm -rf {} \;
git init ~/
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
```

```bash
git checkout linux
# git checkout macos
```

### Install in actuall `${HOME}` directory
```bash
INSTALL_PORTABLE="yes" /bin/bash ~/.dotfiles/initialize.sh
```

### Install in specified `${HOME}` directory
```bash
DOT_HOME="/root" INSTALL_PORTABLE="yes" /bin/bash ~/.dotfiles/initialize.sh
```
