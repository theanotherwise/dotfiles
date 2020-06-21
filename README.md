# Dotfiles

## Initialize
```bash
git init .
# git remote add origin git@github.com:theanotherwise/dotfiles.git
git remote add origin https://github.com/theanotherwise/dotfiles.git
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

# Directories
```bash
mkdir -p ~/archives
mkdir -p ~/bluetooth
mkdir -p ~/captures/pictures
mkdir -p ~/captures/videos
mkdir -p ~/cheat-sheets
mkdir -p --parents ~/configurationsessions
mkdir -p ~/dashcam
mkdir -p ~/desktop
mkdir -p ~/documents
mkdir -p ~/downloads
mkdir -p ~/ebooks
mkdir -p ~/git
mkdir -p ~/iso-images
mkdir -p ~/music
mkdir -p --parents ~/pictures/wallpaper
mkdir -p ~/scripts
mkdir -p ~/portable
mkdir -p ~/projects
mkdir -p ~/captures
mkdir -p ~/temporary
mkdir -p ~/videos
mkdir -p ~/virtual-machines
mkdir -p ~/word-lists
mkdir -p ~/work

mkdir -p --parents ~/virtual-machines/vmware/archives
mkdir -p --parents ~/virtual-machines/vmware/templates
mkdir -p --parents ~/virtual-machines/vmware/workspace

mkdir -p ~/projects/android
mkdir -p ~/projects/ansible
mkdir -p ~/projects/bash
mkdir -p ~/projects/burp
mkdir -p ~/projects/c
mkdir -p ~/projects/cpp
mkdir -p ~/projects/helm
mkdir -p ~/projects/html
mkdir -p ~/projects/java
mkdir -p ~/projects/javscript
mkdir -p ~/projects/kde-plasma
mkdir -p ~/projects/node.js
mkdir -p ~/projects/php
mkdir -p ~/projects/puppet
mkdir -p ~/projects/python
mkdir -p ~/projects/python/2
mkdir -p ~/projects/python/3
mkdir -p ~/projects/ruby
mkdir -p ~/projects/ruby-on-rails
mkdir -p ~/projects/soupui
mkdir -p ~/projects/wsdl
mkdir -p ~/projects/wsdl
mkdir -p ~/projects/xca
mkdir -p ~/projects/zabbix
mkdir -p ~/projects/others
```
