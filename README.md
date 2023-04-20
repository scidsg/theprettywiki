# The Pretty Wiki

https://try.thepretty.wiki

![wiki-cover](https://user-images.githubusercontent.com/28545431/233209272-550367c1-3c48-4055-85b1-b7fc36350cd5.png)

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
 1. Complete the MediaWiki installation by visiting your server's IP address or domain name.

![232121037-8e7c720b-7148-4692-afca-04f209370dfd 1](https://user-images.githubusercontent.com/28545431/232261159-43984bda-076e-46bf-ba7c-6ba3eece6c81.png)

 2. Download the LocalSettings.php file that's generated at the end of the installation process. Open it in a text editor and copy it's contents.
 
 ### Step 3: Update Your Wiki's Settings
 3. Back in the Terminal, create a LocalSettings.php file and paste the downloaded contents:
 
 ```
nano /var/www/html/mediawiki/LocalSettings.php 
 ```

You should be able to enter your Wiki now.

### Step 4: Prettify
Now, we'll prettify your Wiki! In the terminal, run:

```
curl -sSL https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/prettify.sh | bash
```

Clear your cache or open a new Incognito or Private window, then load the page again. 

![Screen Shot 2023-04-19 at 20 27 1](https://user-images.githubusercontent.com/28545431/233251029-3950ae39-9fcf-4537-939d-ebf0c9bc46b5.png)

### Step 5 (optional): Make a Hidden Wiki
You can use a Tor onion service to make your wiki available without needing to purchase a new domain name, or if you want to keep your site private.

```
curl -sSL https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/torify.sh | bash
```

Reload your page for your updated Wiki!

