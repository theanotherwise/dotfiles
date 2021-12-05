```bash
find ~/ -mindepth 1 -maxdepth 1 -exec rm -rf {} \;
```

```bash
git init ~/
git remote add origin https://github.com/seemscloud/dotfiles.git
git fetch --all
git checkout linux

bash ~/.dotfiles

su - 
```
