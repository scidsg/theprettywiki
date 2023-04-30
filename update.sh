#!/bin/bash

# Update the system
sudo apt update
sudo apt -y upgrade
sudo apt -y autoremove

# Backup files
cd /var/www/html/mediawiki/skins/Vector/resources/skins.vector.styles/custom/

mkdir -p archive/
timestamp=$(date +%Y%m%d%H%M%S)
mv custom.less archive/custom.less.$timestamp
mv ddos.less archive/ddos.less.$timestamp
mv homepage.css archive/homepage.css.$timestamp
mv homepage.js archive/homepage.js.$timestamp

wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/custom.less
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/ddos.less
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/homepage.css
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/homepage.js