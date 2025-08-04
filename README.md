# copydots
Simple CLI tool to copy your dotfiles. Made with [Bashly](https://bashly.dev).

Create a config file, specify which files you want to copy and keep track of them. Can also set custom output directory for individual files/directories or all.

Simple tracking system: 
  - If a copy gets deleted and its still in the config file, tries to get it back.
  - If the original file/directory gets deleted, the copy gets deleted too.
  - If the entry gets deleted, the file/directory is not tracked anymore, so it doesn't gets restored after deleted.

## Install

```
curl -sL https://raw.githubusercontent.com/MrE8065/copydots/refs/heads/main/copydots | sudo tee /usr/local/bin/copydots > /dev/null
sudo chmod +x /usr/local/bin/copydots
```

## Usage

```
copydots - Copy your dotfiles anywhere

Usage:
  copydots COMMAND
  copydots [COMMAND] --help | -h
  copydots --version | -v

Commands:
  init   Create the config file
  add    Copy the files/folders in the config file to a folder (current directory if not specified)
  show   Show all the entries in the config file

Options:
  --help, -h
    Show this help

  --version, -v
    Show version number
```