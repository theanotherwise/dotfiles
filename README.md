```bash
find ~/ -mindepth 1 -maxdepth 1 -exec rm -rf {} \;
```

```bash
git init ~/
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all
```

```bash
git checkout linux
# git checkout macos
```

```bash
/bin/bash ~/.dotfiles/initialize.sh
```
