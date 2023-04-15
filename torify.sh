#!/bin/bash

# Update the system
sudo apt update
sudo apt -y upgrade

# Install Tor
sudo apt install -y tor

# Configure Tor to create a new onion service
sudo bash -c 'cat >> /etc/tor/torrc << EOL
HiddenServiceDir /var/lib/tor/mediawiki_onion_service/
HiddenServicePort 80 127.0.0.1:8080
EOL'

# Configure Apache to listen on the local IP and the onion service port
sudo bash -c 'cat >> /etc/apache2/ports.conf << EOL
Listen 127.0.0.1:8080
EOL'

# Create a new Apache configuration file for the onion service
sudo bash -c 'cat > /etc/apache2/sites-available/mediawiki_onion.conf << EOL
<VirtualHost 127.0.0.1:8080>
    ServerName localhost
    DocumentRoot /var/www/html/mediawiki
    <Directory /var/www/html/mediawiki/>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOL'

# Enable the onion service configuration and restart Apache
sudo a2ensite mediawiki_onion

# Restart Apache and Tor
sudo systemctl restart apache2
sudo systemctl restart tor

# Retrieve the onion service hostname
sleep 10
onion_hostname=$(sudo cat /var/lib/tor/mediawiki_onion_service/hostname)

# Display the onion service URL
echo "Your MediaWiki site is now accessible exclusively as a Tor onion service at the following URL:"
echo "http://${onion_hostname}"
