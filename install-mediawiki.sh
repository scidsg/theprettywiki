#!/bin/bash

# Update the system
sudo apt update
sudo apt -y dist-upgrade
sudo apt -y autoremove

# Install necessary packages
sudo apt install -y apache2 php libapache2-mod-php mariadb-server php-mysql php-xml php-mbstring php-apcu php-intl imagemagick php-gd php-cli curl php-curl git whiptail

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
    ServerName mediawiki.local
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
db_name=$(whiptail --inputbox "Please enter your desired database name for MediaWiki:" 8 78 --title "Database Name" 3>&1 1>&2 2>&3)
db_user=$(whiptail --inputbox "Please enter your desired database username for MediaWiki:" 8 78 --title "Database Username" 3>&1 1>&2 2>&3)
db_pass=$(whiptail --passwordbox "Please enter your desired database password for MediaWiki:" 8 78 --title "Database Password" 3>&1 1>&2 2>&3)

# Create the database and user
sudo mysql -e "CREATE DATABASE \`${db_name}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${db_user}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Done
echo "MediaWiki has been installed. Please visit http://mediawiki.local to complete the setup and apply the Vector skin."
