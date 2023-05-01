#!/bin/bash

# Update the system
sudo apt update
sudo apt -y dist-upgrade
sudo apt -y autoremove

# Backup files
cd /var/www/html/mediawiki/skins/Vector/resources/skins.vector.styles/custom/

mkdir -p archive/
timestamp=$(date +%Y%m%d%H%M%S)
mv custom.less archive/$timestamp-custom.less
mv ddos.less archive/$timestamp-ddos.less
mv homepage.css archive/$timestamp-homepage.css
mv homepage.js archive/$timestamp-homepage.js

wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/custom.less
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/ddos.less
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/homepage.css
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/homepage.js