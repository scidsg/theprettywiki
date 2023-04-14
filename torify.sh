#!/bin/bash

# Install Tor
sudo apt install -y tor

# Configure Tor for onion service
sudo bash -c 'cat >> /etc/tor/torrc << EOL
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServicePort 80 127.0.0.1:80
EOL'

# Restart Tor to apply the configuration
sudo systemctl restart tor

# Wait for the onion service to be created
sleep 10

# Get the onion service address
onion_address=$(sudo cat /var/lib/tor/hidden_service/hostname)

# Edit mediawiki-onion.conf with the onion address
sudo bash -c "cat > /etc/apache2/sites-available/mediawiki-onion.conf << EOL
<VirtualHost *:80>
    ServerName ${onion_address}
    ServerAlias *.onion
    DocumentRoot /var/www/html/mediawiki

    <Directory /var/www/html/mediawiki/>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOL"

# Enable the mediawiki-onion site and reload the Apache configuration
sudo a2ensite mediawiki-onion
sudo systemctl reload apache2

# Print the onion service address
echo "Your MediaWiki onion service is available at: ${onion_address}"
