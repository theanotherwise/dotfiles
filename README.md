# Dotfiles

## Initialize
```bash
git init .
# git remote add origin git@github.com:theanotherwise/dotfiles.git
git remote add origin https://github.com/theanotherwise/dotfiles.git
```

## Pull changes
```bash
git pull origin master
git fetch --all
git reset --hard origin/master
```

## Make changes
```bash
git add -u
git commit -m "#"
git push --set-upstream origin master
```
