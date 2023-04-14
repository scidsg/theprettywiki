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

# Update MediaWiki Apache configuration file to use the onion service port
sudo sed -i 's/<VirtualHost *:80>/<VirtualHost 127.0.0.1:8080>/' /etc/apache2/sites-available/mediawiki.conf

# Disable clearnet access to the MediaWiki site
sudo a2dissite 000-default

# Restart Apache and Tor
sudo systemctl restart apache2
sudo systemctl restart tor

# Retrieve the onion service hostname
onion_hostname=$(sudo cat /var/lib/tor/mediawiki_onion_service/hostname)

# Display the onion service URL
echo "Your MediaWiki site is now accessible exclusively as a Tor onion service at the following URL:"
echo "http://${onion_hostname}"
