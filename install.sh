#!/bin/sh

echo "Setting up your Mac..."

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi


## INSTALL SYMLINKS

# Add global gitignore
ln -s $HOME/.dotfiles/shell/.global-gitignore $HOME/.global-gitignore
git config --global core.excludesfile $HOME/.global-gitignore

# Symlink zsh prefs
rm $HOME/.zshrc
ln -s $HOME/.dotfiles/shell/.zshrc $HOME/.zshrc

# Symlink vim prefs
rm $HOME/.vimrc
ln -s $HOME/.dotfiles/shell/.vimrc $HOME/.vimrc
rm $HOME/.vim
ln -s $HOME/.dotfiles/shell/.vim $HOME/.vim

# Symlink yarn prefs
rm $HOME/.yarnrc
ln -s $HOME/.dotfiles/shell/.yarnrc $HOME/.yarnrc

# Symlink the Mackup config
ln -s $HOME/.dotfiles/macos/.mackup.cfg $HOME/.mackup.cfg

# Fix missing font characters (see https://github.com/robbyrussell/oh-my-zsh/issues/1906)
cd ~/.oh-my-zsh/themes/
git checkout d6a36b1 agnoster.zsh-theme

# Activate z
cd ~/.dotfiles/shell
chmod +x z.sh


#### INSTALL HOMEBREW PACKAGES

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle
brew analytics off

# Set default MySQL root password and auth type
mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'rootroot'; FLUSH PRIVILEGES;"

# Install PHP extensions with PECL
pecl install imagick memcached redis swoole xdebug

# If imagick is giving an error for pcre2 (installed with brew), try to simlink it
# ln -s /opt/homebrew/Cellar/pcre2/10.37_1/include/pcre2.h /opt/homebrew/Cellar/php/8.0.8_1/include/php/ext/pcre/pcre2.h

# For memcached we should have installed libmemcached, zlib and memcached with brew, but we need to link them when installing with pecl
# > pecl install memcached
# libmemcached directory [no] : /opt/homebrew/opt/libmemcached/
# zlib directory [no] : /opt/homebrew/opt/zlib/
# use system fastlz [no] :
# enable igbinary serializer [no] :
# enable msgpack serializer [no] :
# enable json serializer [no] :
# enable server protocol [no] :
# enable sasl [yes] :
# enable sessions [yes] :

# Then suddenly swoole would also install...

# Install global Composer packages
composer global require laravel/installer laravel/valet laravel/envoy laravel/forge-cli beyondcode/expose beyondcode/forge-cli phpunit/phpunit vlucas/phpdotenv 

#added from freekmurze
# composer global require spatie/phpunit-watcher
# composer global require spatie/mixed-model-scanner-cli
# 

# Spatie Browsershot requires puppeteer
npm install puppeteer --global
# There seems to be an issue where php/Symfony process is looking to find npm and node in /usr/local/bin and not reading the $PATH vars, so lets make symlinks to solve this
sudo ln -s /opt/homebrew/bin/node /usr/local/bin/node
sudo ln -s /opt/homebrew/bin/npm /usr/local/bin/npm

# Install Laravel Valet
valet install

# Create a Sites directory
mkdir $HOME/Code

# Create sites subdirectories
mkdir $HOME/Code/Sites

# Clone Github repositories
./code/clone.sh

# Set macOS preferences - we will run this last because this will reload the shell
source macos/set-defaults.sh

echo '++++++++++++++++++++++++++++++'
echo '++++++++++++++++++++++++++++++'
echo 'All done!'
echo 'Things to do to make the agnoster terminal theme work:'
echo '1. Install menlo patched font included in ~/.dotfiles/misc https://gist.github.com/qrush/1595572/raw/Menlo-Powerline.otf'
echo '2. Install patched solarized theme included in ~/.dotfiles/misc'

echo '++++++++++++++++++++++++++++++'
echo 'Some optional tidbits'

echo '1. Make sure dropbox is running first. If you have not backed up via Mackup yet, then run `mackup backup` to symlink preferences for a wide collection of apps to your dropbox. If you already had a backup via mackup run `mackup restore` You'\''ll find more info on Mackup here: https://github.com/lra/mackup.'
echo '2. Set some sensible os x defaults by running: $HOME/.dotfiles/macos/set-defaults.sh'
echo '3. Make a .dotfiles-custom/shell/.aliases for your personal commands'

echo '++++++++++++++++++++++++++++++'
echo '++++++++++++++++++++++++++++++'
