### Initialize
```bash
find ~/ -mindepth 1 -maxdepth 1 -not \( -path ~/.ssh \) -exec rm -rf {} \;
git init ~/
git remote add origin https://github.com/theanotherwise/dotfiles.git
git fetch --all

git checkout linux
# git checkout macos
```

### Prepare in `${HOME}` directory
```bash
INSTALL_PORTABLE="yes" /bin/bash ~/.dotfiles/initialize.sh
```

### Prepare in specified directory
```bash
DOT_HOME="/root" INSTALL_PORTABLE="yes" sudo -E -u root /bin/bash /root/.dotfiles/initialize.sh
```

# Python3 / Ruby Dependencies
```bash
apt-get update
apt-get install -y build-essential curl g++ gcc wget make \
                   libbz2-dev libffi-dev libgdbm-compat-dev libgdbm-dev liblzma-dev libncurses5-dev \
                   libreadline-dev libsqlite3-dev libssl-dev libxml2-dev libyaml-dev zlib1g zlib1g-dev
```

```bash
./configure --prefix=/root/binaries/CHANGEME/VERSIONME
make
make install
```
