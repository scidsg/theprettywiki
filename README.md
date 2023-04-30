# The Pretty Wiki

## Links
[🧑‍💻 Try The Pretty Wiki](https://try.thepretty.wiki)

[🌎 Public Site](https://thepretty.wiki)

![wiki-cover](https://user-images.githubusercontent.com/28545431/235380727-52cdb8b3-800e-4241-a5a6-5537b6a51c7a.png)

The Pretty Wiki builds on top of Mediawiki's Vector 2022 skin. It includes accessibility guidelines from https://accessibility.digital.gov/visual-design/typography/ :

- Use a large enough font size for body text so that people can comfortably read. 
- Maintain a line length that promotes comfortable reading.
- Choose a typeface that emphasizes clarity and legibility.

Additionally, our body typeface is from the Braille Institute, called Atkinson Hyperlegible, a font made to be legible for people with low vision. Headings use Merriweather, a font designed to be pleasant to read on screens. It features a very large x-height, slightly condensed letterforms, mild diagonal stress, sturdy serifs, and open forms.

Our paragraphs are easier to read with its max-width set to 640px, font-size 1rem/16px, and line-height 1.6. Headings use a higher contrast type-scale, and a few additional stylistic modifications. 

These simple style changes will transform your Wiki experience.

## Installation

### Step 1: Install Mediawiki
First, install Mediawiki on your updated server with root access:

```
curl -sSL https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/install-mediawiki.sh | bash
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

