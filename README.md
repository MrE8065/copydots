# copydots
Simple CLI tool to copy your dotfiles. Made with [Bashly](https://bashly.dev).
Create a config file, specify which files you want to copy and keep track of them.

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