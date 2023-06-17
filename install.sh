#!/bin/bash

# Welcome message and ASCII art
cat << "EOF"

███    ███ ███████ ██████  ██  █████  ██     ██ ██ ██   ██ ██ 
████  ████ ██      ██   ██ ██ ██   ██ ██     ██ ██ ██  ██  ██ 
██ ████ ██ █████   ██   ██ ██ ███████ ██  █  ██ ██ █████   ██ 
██  ██  ██ ██      ██   ██ ██ ██   ██ ██ ███ ██ ██ ██  ██  ██ 
██      ██ ███████ ██████  ██ ██   ██  ███ ███  ██ ██   ██ ██ 
                                                              
📖 Easily deploy your own Mediawiki instance.
                                                            
https://thepretty.wiki
https://try.thepretty.wiki

EOF
sleep 3

# Update the system
sudo apt update
sudo apt -y dist-upgrade
sudo apt -y autoremove

# Install necessary packages
sudo apt install -y apache2 php libapache2-mod-php mariadb-server php-mysql php-xml php-mbstring php-apcu php-intl imagemagick php-gd php-cli curl php-curl git whiptail unattended-upgrades

# Get the latest MediaWiki version and tarball URL
MW_TARBALL_URL=$(curl -s https://www.mediawiki.org/wiki/Download | grep -oP '(?<=href=")[^"]+(?=\.tar\.gz")' | head -1)
MW_VERSION=$(echo $MW_TARBALL_URL | grep -oP '(?<=mediawiki-)[^/]+')

# Download MediaWiki
wget -O mediawiki-${MW_VERSION}.tar.gz "${MW_TARBALL_URL}.tar.gz"
tar xvzf mediawiki-${MW_VERSION}.tar.gz

# Move MediaWiki to the web server directory
sudo mv mediawiki-${MW_VERSION} /var/www/html/mediawiki

# Set appropriate permissions
sudo chown -R www-data:www-data /var/www/html/mediawiki
sudo chmod -R 755 /var/www/html/mediawiki

# Enable Apache rewrite module
sudo a2enmod rewrite

# Create a MediaWiki Apache configuration file
sudo bash -c 'cat > /etc/apache2/sites-available/mediawiki.conf << EOL
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/html/mediawiki
    <Directory /var/www/html/mediawiki/>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOL'

# Enable the MediaWiki site and disable the default site
sudo a2ensite mediawiki
sudo a2dissite 000-default

# Restart Apache
sudo systemctl restart apache2

# Get user input using whiptail
db_name=$(whiptail --inputbox "\nPlease enter your desired database name for MediaWiki:" 8 78 "wikidb" --title "Database Name" 3>&1 1>&2 2>&3)
db_user=$(whiptail --inputbox "\nPlease enter your desired database username for MediaWiki:" 8 78 "wikiuser" --title "Database Username" 3>&1 1>&2 2>&3)
db_pass=$(whiptail --passwordbox "\nPlease enter your desired database password for MediaWiki:" 8 78 --title "Database Password" 3>&1 1>&2 2>&3)

# Create the database and user
sudo mysql -e "CREATE DATABASE \`${db_name}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${db_user}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Enable the "security" and "updates" repositories
sudo sed -i 's/\/\/\s\+"\${distro_id}:\${distro_codename}-security";/"\${distro_id}:\${distro_codename}-security";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's/\/\/\s\+"\${distro_id}:\${distro_codename}-updates";/"\${distro_id}:\${distro_codename}-updates";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's|//\s*Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";|Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";|' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's|//\s*Unattended-Upgrade::Remove-Unused-Dependencies "true";|Unattended-Upgrade::Remove-Unused-Dependencies "true";|' /etc/apt/apt.conf.d/50unattended-upgrades

sudo dpkg-reconfigure --priority=low unattended-upgrades

# Configure unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot "true";' | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot-Time "02:00";' | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades

sudo systemctl restart unattended-upgrades

echo "Automatic updates have been installed and configured."

SERVER_IP=$(curl -s ifconfig.me)
WIDTH=$(tput cols)
whiptail --msgbox --title "Instructions" "Now, enter $SERVER_IP in a web browser to continue setup, then come back here when you're done.\n\nWhen the MediaWiki setup is complete, press Enter to finish The Pretty Wiki installation." 14 $WIDTH

# Download Science & Design brand resources
cd /var/www/html/mediawiki/skins/Vector/resources/skins.vector.styles/
mkdir custom
cd custom/
git clone https://github.com/scidsg/brand-resources.git
mv brand-resources/fonts  .
rm -r brand-resources/

# Activate New Skin
file="/var/www/html/mediawiki/LocalSettings.php"
backup_file="/var/www/html/mediawiki/LocalSettings.php.bak"

# Create a backup of the original file
cd /var/www/html/mediawiki/
cp "$file" "$backup_file"

# Enable The Pretty Wiki
sed -i 's/\$wgDefaultSkin = "vector";/\$wgDefaultSkin = "vector-2022";/g' "$file"

# Mobile enablement and enhancements 
echo "Adding viewport meta tag, theme-color, and favicons to LocalSettings.php..."
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/favicon.ico
mkdir images/ images/favicon/
cd images/favicon/
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/images/favicon/android-chrome-192x192.png
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/images/favicon/android-chrome-512x512.png
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/images/favicon/apple-touch-icon.png
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/images/favicon/favicon-16x16.png
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/images/favicon/favicon-32x32.png
cat >> /var/www/html/mediawiki/LocalSettings.php << EOL
\$wgHooks["BeforePageDisplay"][] = "addViewportMetaTag";
function addViewportMetaTag( \$out, \$skin ) {
    \$out->addHeadItem( "viewport", "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" );
    \$out->addHeadItem( "theme-color", "<meta name=\"theme-color\" content=\"#333\">" );
    \$out->addHeadItem( "apple-touch-icon", "<link rel=\"apple-touch-icon\" sizes=\"180x180\" href=\"/images/favicon/apple-touch-icon.png\">" );
    \$out->addHeadItem( "favicon-32x32", "<link rel=\"icon\" type=\"image/png\" href=\"/images/favicon/favicon-32x32.png\" sizes=\"32x32\">" );
    \$out->addHeadItem( "favicon-16x16", "<link rel=\"icon\" type=\"image/png\" href=\"/images/favicon/favicon-16x16.png\" sizes=\"16x16\">" );
    \$out->addHeadItem( "android-chrome-192x192", "<link rel=\"icon\" type=\"image/png\" href=\"/images/favicon/android-chrome-192x192.png\" sizes=\"192x192\">" );
    \$out->addHeadItem( "android-chrome-512x512", "<link rel=\"icon\" type=\"image/png\" href=\"/images/favicon/android-chrome-512x512.png\" sizes=\"512x512\">" );
    return true;
}
EOL

# Back up Vector Skin
cd /var/www/html/mediawiki/skins
cp -r Vector/ Vector-Backup/

# Back up current less file
cd Vector/resources/skins.vector.styles/
mv skin.less old-skin.less
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/skin.less

# Download skin files
cd custom/
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/custom.less
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/ddos.less
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/homepage.css
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/homepage.js
cd /var/www/html/mediawiki/extensions/
wget https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/skin/homepage.php

# Append LocalSettings
cd /var/www/html/mediawiki
echo 'require_once "$IP/extensions/homepage.php";' >> LocalSettings.php
echo '$wgEnableAPI = true;' >> LocalSettings.php

# Done
echo "👍 The Pretty Wiki is now ready."