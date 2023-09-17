# The Pretty Wiki

The Pretty Wiki builds on top of Mediawiki's Vector 2022 skin. It includes a new homepage and [accessibility improvements from the guidelines published by Digitial.gov](https://accessibility.digital.gov/visual-design/typography/). Additionally, our body typeface, Atkinson Hyperlegible, is from created by the Braille Institute and made to be legible for people with low vision.

These simple style changes will transform your Wiki experience.

## Links
[🧑‍💻 Try The Pretty Wiki](https://try.thepretty.wiki)

[🌎 Public Site](https://thepretty.wiki)

![wiki-cover](https://user-images.githubusercontent.com/28545431/235380727-52cdb8b3-800e-4241-a5a6-5537b6a51c7a.png)

## Installation

### Step 1: Install Mediawiki
First, install Mediawiki on your updated server with root access:

```
curl -sSL https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/install.sh | bash
```

You'll need to reuse your database credentials created during install.

### Step 2: Enable Your Wiki
 1. Complete the MediaWiki installation by visiting your server's IP address or domain name. When it's complete you'll download LocalSettings.php
 2. Back in the Terminal, create a LocalSettings.php file and paste the downloaded contents:
 
 ```
nano /var/www/html/mediawiki/LocalSettings.php 
 ```

### Step 3: Prettify
Now, we'll prettify your Wiki! In the terminal, run:

```
curl -sSL https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/prettify.sh | bash
```

Clear your cache or open a new Incognito or Private window, then load the page again. 


## Optional Steps

### Create Backups
You can easily create daily encrypted backups of your database by executing:

```
curl -sSL https://raw.githubusercontent.com/scidsg/tools/main/encrypted-mysql-backups.sh | bash
```

### Update The Pretty Wiki
To update your wiki, just run:

```
curl -sSL https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/update.sh | bash
```

Don't worry, previous versions of the updated files will be preserved.

### Make a Hidden Wiki
You can use a Tor onion service to make your wiki available without needing to purchase a new domain name, or if you want to keep your site private.

```
curl -sSL https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/torify.sh | bash
```

Reload your page for your updated Wiki!

