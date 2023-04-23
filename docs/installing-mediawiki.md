# Installing Mediawiki

## Easy Installer

```
curl -sSL https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/install-mediawiki.sh | bash
```

This command is used to download and execute the install-mediawiki.sh script, which automates the process of installing Mediawiki, a popular open-source wiki software. Let's break down the command:

1. curl: This is a command-line utility used for transferring data to or from a server. In this case, it's used to download the install-mediawiki.sh script from the specified URL.
2. -sSL: These are flags passed to the curl command:
* -s: This flag stands for "silent" and is used to suppress the download progress bar and error messages.
* -S: This flag is used to show an error message if the download fails, despite the -s flag suppressing other error messages.
* -L: This flag tells curl to follow any redirects if the provided URL points to a different location.
3. https://raw.githubusercontent.com/scidsg/the-pretty-wiki/main/install-mediawiki.sh: This is the URL of the install-mediawiki.sh script hosted on GitHub. The script is part of the "the-pretty-wiki" repository.
4. |: This is a pipe symbol, which is used to redirect the output of one command (in this case, the curl command) as input to another command (in this case, the bash command).
5. bash: This command is used to execute the install-mediawiki.sh script. Since the script is downloaded by curl and piped directly into the bash command, it doesn't need to be saved to a file first.

To summarize, this command downloads the install-mediawiki.sh script from the specified URL and pipes it directly into the bash command for execution, thereby automating the Mediawiki installation process.

### Update The System

```
#!/bin/bash

# Update the system
sudo apt update
sudo apt -y dist-upgrade
sudo apt -y autoremove
```

This is the first block of the install-mediawiki.sh script. It starts with a shebang (#!/bin/bash) line, followed by a series of commands to update the system. Let's go through each line:

1. #!/bin/bash: This is called a shebang or a hashbang. It is used to specify which interpreter should be used to run the script. In this case, the script is intended to be executed by the bash shell.
2. sudo apt update: This command updates the package lists for all repositories and PPAs configured on the system. sudo is used to execute the command with root privileges, apt is the package management tool, and update is the operation performed by apt.
3. sudo apt -y dist-upgrade: This command upgrades the system to a new release by intelligently handling dependencies and installing new packages as needed. The -y flag is used to automatically answer "yes" to any prompts, allowing the upgrade to proceed without user intervention.
4. sudo apt -y autoremove: This command removes any packages that were automatically installed to satisfy dependencies for other packages, but are no longer needed. The -y flag is used here as well, to automatically confirm the removal of packages.

In summary, this block of the script updates the package lists, upgrades the system to the latest release, and removes any unneeded packages.
