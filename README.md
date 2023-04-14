# The Pretty Wiki

The Pretty Wiki builds on top of Mediawiki's Vector 2022 skin. It highlights accessibility guidelines:

- Use a large enough font size for body text so that people can comfortably read. 
- Maintain a line length that promotes comfortable reading.
- Choose a typeface that emphasizes clarity and legibility.
- https://accessibility.digital.gov/visual-design/typography/

Our paragraphs are easier to read with its max-width set to 640px, font-size 1rem/16pm, and line-height 1.6. Our body typeface uses Atkinson Hyperlegible, a new typeface by the Braille Institute for low-vision readers, and headings use higher contrast type-scales. 

These simple style changes will transform your Wiki experience.

## Installation

### Step 1
First, install Mediawiki on your updated server with root access:

```
curl -sSL https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/install.sh | bash
```

You'll need to reuse your database credentials created during install.

### Step 2 - Enable Your Wiki
 1. Visit your server's IP address or domain name and complete the MediaWiki installation. 
 2. Download the generated LocalSettings.php file that's generated at the end of the installation process. Open it in a text editor and copy it's contents.
 3. Back in the Terminal, create a LocalSettings.php file and paste the downloaded contents:
 
 ```
nano /var/www/html/mediawiki/LocalSettings.php 
 ```

You should be able to enter your Wiki now.

![Screen Shot 2023-04-13 at 17 26 08](https://user-images.githubusercontent.com/28545431/232121037-8e7c720b-7148-4692-afca-04f209370dfd.png)

### Step 3 - Prettify
Now, we'll prettify your Wiki! In the terminal, run:

```
curl -sSL https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/prettify.sh | bash
```

Reload your page for your updated WikI!
