#!/bin/bash

##
# Utility Shell Scripts
#
# LICENSE
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# @copyright    Copyright (c) 2005-2014 Bijay Rungta http://bijayrungta.com
# @license      http://www.gnu.org/licenses/gpl-2.0.html GNU GENERAL PUBLIC LICENSE
##

##
# Development Environment for LAMP in Ubuntu.
# OS: Install a latest 64 bit version of Ubuntu LTS (Currently Ubuntu 12.04)
# You can install any version actually. But these Scripts have been written after test on Ubuntu 12.04
#
# Softwares: Install the following Softwares.
# CAUTION: You should not run this script directly. It is advised to run individual Scripts.
# NOTE: Make sure to enable Canonical Partners in Software Sources.
##

# Install openssh so that you can connect from other machine.
sudo apt-get install ssh openssh-server openssh-blacklist openssh-blacklist-extra rssh openssh-client screen

# Install Kubuntu Desktop (This will install general tools bundled with kde version of Ubuntu. Some of them are very useful)
# This will need to download more than 500 MB of Data.
sudo apt-get install kubuntu-desktop

# Install Konqueror
sudo apt-get install konqueror konqueror-plugin-gnash konqueror-plugin-searchbar konqueror-nsplugins

# Install Chat Softwares: Skype and Pidgin, Canonical Partners is needed for Skype.
sudo apt-get install skype pidgin pidgin-skype

# Install light weight utilities for file editing
sudo apt-get install vim vim-scripts vim-doc

# Install utilities for File Compression and Extraction
sudo apt-get install rar unrar gzip mysql-admin

# Install Utilities
sudo apt-get install htop xclip lynx gimp imagemagick

# Install Curl, Java etc needed for other Software.
# Note: You should probably install latest Java version 7. This installs 1.6
sudo apt-get install curl sun-java6-bin sun-java6-jdk

# Install LAMP: Apache, MySQL, phpMyAdmin, PHP, PEAR.
sudo apt-get install apache2 php5-mysql libapache2-mod-php5 mysql-server phpmyadmin \
    mysql-client apache2-doc php-pear tinyca libapache2-mod-auth-mysql php5-mysql

# Install commonly used PHP Extensions
sudo apt-get install php5-curl php5-tidy php5-xdebug php5-ldap php5-xmlrpc php5-imagick

# Install Memcache and its PHP Libraries
sudo apt-get install memcached php5-memcache php5-memcached

# Install GIT and other Version Control Tools
sudo apt-get install git mercurial gitg git-cvs git-svn git-gui gitk meld kfilereplace regexxer

# Install CVS and SVN and related Tools
sudo apt-get install cvs tkcvs cervisia subversion subversion-tools patchutils kdesvn

# To install Subversion version 1.7.x, which has some advanced tools, do this:
# @see http://kovshenin.com/2013/subversion-1-7-on-ubuntu-12-04/
sudo echo <<EOD
deb http://ppa.launchpad.net/svn/ppa/ubuntu precise main
deb-src http://ppa.launchpad.net/svn/ppa/ubuntu precise main
EOD > /etc/apt/sources.list.d/subversion.ppa.list
sudo apt-get update
sudo apt-get install subversion

# Install Utilities
sudo apt-get install gparted htop xclip lynx gimp ntfs-3g

# Install Command line Dictionary and Calculator (Optional)
sudo apt-get install apcalc dictd dict opendict dict-freedict-eng-hin gcalcli gnome-dictionary dict-gcide dict-moby-thesaurus

# File Sharing
sudo apt-get install samba smbclient

# Commonly used Restricted(Proprietary) packages for Ubuntu
# Installing this package will pull in support for MP3 playback and decoding,
# support for various other audio formats (GStreamer plugins), Microsoft fonts,
# Java runtime environment, Flash plugin, LAME (to create compressed audio
# files), and DVD playback.
sudo apt-get install ubuntu-restricted-extras kubuntu-restricted-extras

# install libdvdcss in order to play DVDs
sudo /usr/share/doc/libdvdread4/install-css.sh

# Install GUI Utilities for Ubuntu
sudo apt-get install gcalcli alacarte gnome-panel gnome-tweak-tool gnome-shell

#### Not Essentials ####
sudo apt-get install picasa kpartx kchmviewer okular wakoopa filezilla konversation vlc wkhtmltopdf

# Install Cheat Codes.
sudo gem install cheat

# Install Komodo Edit.
sudo add-apt-repository ppa:mystic-mirage/komodo-edit
sudo apt-get update; sudo apt-get install komodo-edit

# Wine
sudo apt-get install wine

# Multimedia Utilities. Need Canonical Partners for acroread
sudo apt-get install vuze acroread chromium-browser

# Prism
sudo apt-get install prism prism-twitter prism-facebook prism-google-mail prism-google-docs prism-google-analytics

# Get Composer (http://getcomposer.org/doc/00-intro.md)
mkdir -p ~/tmp; cd ~/tmp; curl -sS https://getcomposer.org/installer | php \
                mv composer.phar /usr/local/bin/composer

# Install pyrus PEAR2 (http://pear2.php.net/)

# Install PHP_CodeSniffer using pear (http://pear.php.net/package/PHP_CodeSniffer)
sudo pear install PHP_CodeSniffer

# Install PHP Mesh Detector (http://phpmd.org/)
sudo pear channel-discover pear.phpmd.org
sudo pear channel-discover pear.pdepend.org
sudo pear install --alldeps phpmd/PHP_PMD

# PHP_Beautifier
sudo pear install PHP_Beautifier-0.1.15

# Alternative method using pyrus (@TODO Has problems Doesn't work as expected.)
sudo php pyrus.phar install pear/PHP_Beautifier-0.1.15

##
# Install these softwares separately by downloading from Software Repository at LAN
#   Netbeans, Chrome, Firebug for Firefox
##
