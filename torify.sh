#!/bin/bash

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

# Get and print the onion service address
onion_address=$(sudo cat /var/lib/tor/hidden_service/hostname)
echo "Your MediaWiki onion service is available at: ${onion_address}"
