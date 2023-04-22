## Introduction

This article explains a bash script that helps you install and set up MediaWiki on your system. MediaWiki is a popular open-source wiki platform, commonly used for creating and managing websites like Wikipedia. The script automates the process of installing necessary packages, downloading the latest version of MediaWiki, and configuring a web server to host it.

### Script Explanation

1. **Update the system:** The script starts by updating the system, upgrading any installed packages, and removing unnecessary ones.

2. **Install necessary packages:** The script installs required packages, such as Apache web server, PHP, and MariaDB, among others.

3. **Get the latest MediaWiki version and tarball URL:** The script fetches the latest MediaWiki version and its download URL by extracting the information from the MediaWiki download page.

4. **Download and extract MediaWiki:** The script downloads the MediaWiki tarball and extracts its contents.

5. **Move MediaWiki to the web server directory:** The script moves the extracted MediaWiki folder to the Apache web server's document root directory.

6. **Set appropriate permissions:** The script sets the required file permissions for the MediaWiki installation.

7. **Enable Apache rewrite module:** The script enables the Apache rewrite module, necessary for MediaWiki's URL rewriting.

8. **Create a MediaWiki Apache configuration file:** The script creates a configuration file for the Apache web server to correctly serve MediaWiki.

9. **Enable the MediaWiki site and disable the default site:** The script activates the MediaWiki configuration and disables the default Apache configuration.

10. **Restart Apache:** The script restarts the Apache web server to apply the changes.

11. **Get user input using whiptail:** The script asks the user to provide a database name, username, and password for the MediaWiki installation.

12. **Create the database and user:** The script creates a new database and user with the provided information and grants the user all privileges on the database.

13. **Enable the "security" and "updates" repositories:** The script enables the security and updates repositories for unattended upgrades.

14. **Configure unattended-upgrades:** The script configures the unattended-upgrades package to automatically apply security updates and remove unused packages and kernel versions.

15. **Restart unattended-upgrades:** The script restarts the unattended-upgrades service to apply the new configuration.

16. **Inform the user:** The script informs the user that automatic updates have been installed and configured.

17. **Done:** The script notifies the user that MediaWiki has been installed and provides the URL to complete the setup.

### Conclusion

This bash script simplifies the process of installing and configuring MediaWiki on your system. By following the steps outlined above, you can quickly set up a MediaWiki installation with the necessary packages, web server configuration, and automatic updates.
