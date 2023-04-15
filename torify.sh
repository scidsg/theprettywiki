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

# Route network traffic through Tor
# Install torsocks
sudo apt install -y torsocks

# Configure Tor for routing all network traffic
sudo bash -c 'cat >> /etc/tor/torrc << EOL
VirtualAddrNetworkIPv4 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 9040
DNSPort 5353
EOL'

# Restart the Tor service
sudo systemctl restart tor

sudo iptables -t nat -A OUTPUT -p tcp -d 10.0.0.0/8 -j RETURN
sudo iptables -t nat -A OUTPUT -p tcp -d 172.16.0.0/12 -j RETURN
sudo iptables -t nat -A OUTPUT -p tcp -d 192.168.0.0/16 -j RETURN
sudo iptables -t nat -A OUTPUT -p tcp -j REDIRECT --to-ports 9040
sudo iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 5353

# Retrieve the onion service hostname
sleep 10
onion_hostname=$(sudo cat /var/lib/tor/mediawiki_onion_service/hostname)

# Update MediaWiki's LocalSettings.php to use the onion hostname
sudo bash -c "echo -e \"\\\$wgServer = 'http://$onion_hostname';\" >> /var/www/html/mediawiki/LocalSettings.php"

# Display the onion service URL
function display_service_status() {
    local tor_status=$(systemctl is-active tor)
    local apache_status=$(systemctl is-active apache2)

    if [[ $tor_status == "active" && $apache_status == "active" ]]; then
        echo -e "\033[32m●\033[0m The MediaWiki Tor onion service is running."
    else
        echo -e "\033[31m●\033[0m The MediaWiki Tor onion service is not running."
    fi

    local onion_hostname=$(sudo cat /var/lib/tor/mediawiki_onion_service/hostname 2>/dev/null)
    if [[ -n $onion_hostname ]]; then
        echo "http://${onion_hostname}"
    else
        echo "Onion address not found."
    fi
}

# Wait a few seconds for the onion service to start
sleep 5
display_service_status

# Display status on login
echo 'display_service_status' >> ~/.bashrc
