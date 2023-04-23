# Prettify and Create a Custom Homepage

## Introduction

MediaWiki is a popular open-source wiki platform used by numerous websites, including Wikipedia. While it offers a range of features and customization options, sometimes users may want to create a custom homepage with a unique layout and design. In this article, we will walk through a script that sets up a custom homepage for a MediaWiki site with specific design elements and functionalities.

## Prerequisites

Before following the steps in this article, make sure you have a MediaWiki installation set up on your server. You should also have shell access to the server and be familiar with basic Bash commands.

## Script Overview

The script provided in this article performs the following tasks:

* Downloads the necessary resources and files for the custom homepage.
* Sets up the custom homepage by modifying HTML, JavaScript, and CSS files.
* Modifies the MediaWiki LocalSettings.php file to enable the custom homepage extension and API access.

### Step 1: Downloading Resources

To begin, the script navigates to the appropriate directory on the server using the 'cd' command:

```
cd /var/www/html/mediawiki/skins/Vector/resources
```

### Step 2: Setting up the Custom Homepage

In this step, the script creates several files, including:

* homepage.php: a PHP file that serves as the custom homepage extension.
* homepage.js: a JavaScript file that adds interactivity to the homepage, such as fetching articles by category and managing the layout.
* homepage.css: a CSS file that defines the styles for the custom homepage.

Each of these files is created using the 'cat' command and here-document (<< EOL) syntax to write the contents of the file directly within the script.

### Step 3: Modifying LocalSettings.php

Finally, the script modifies the MediaWiki LocalSettings.php file to enable the custom homepage extension and API access. This is done using the 'echo' command to append the necessary lines to the file:

```
cd /var/www/html/mediawiki
echo 'require_once "$IP/extensions/homepage.php";' >> LocalSettings.php
echo '$wgEnableAPI = true;' >> LocalSettings.php
```

### Conclusion

By following the steps in this article and using the provided script, you can create a custom homepage for your MediaWiki site with unique design elements and functionalities. This allows you to offer a more engaging and user-friendly experience for your site visitors.
