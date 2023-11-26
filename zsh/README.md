# ZSH

## ToC

1. [Table of Contents](#toc)
1. [brew](#brew)
1. [oh-my-zsh](#oh-my-zsh)
    1. [Plugins](#plugins)
1. [Configuration](#config)
1. [Tools](#tools)
1. [Aliases](#aliases)

## Installation

1. TODO: install zsh - on MacOS it's a default
1. Install [brew](#brew)
1. Install [oh-my-zsh](#oh-my-zsh)
    1. Install [plugins](#plugins) for oh-my-zsh
1. Make sure you have the correct way of setting up the [configuration](#config)
1. Install useful [tools](#tools)
1. Install [tmux](/tmux/README.md)
1. Create configurations and setup aliases for your [tmux workspaces](#aliases)

## brew

Brew seems to be a nice package manager. I like it, especially for Mac. <https://brew.sh/>

## oh-my-zsh

Oh My Zsh is a very nice configuration manager for zsh. I like it, I like the included themes and the plugins. <https://github.com/ohmyzsh/ohmyzsh>

### Plugins

* [zsh-z](https://github.com/agkozak/zsh-z)

## Config

I'm writing it after I somehow managed to nuke my `.zshrc` configuration. I don't think I can save the whole file in this repository, as the config requires installation of all the different things. If I blindly commit the file, the configuration might be fault. Therefore, I have a different idea:

I'll commit the most basic configuration I can have with only customizing things available everywhere. The rest of the configuration should be **outside** the `.zshrc` file in different places, like:

* `.zsh_aliases` - for different aliases
* `.zsh_path` - for updating the `PATH` variable
* `.zsh_programs` - for different programs configurations

This should reduce the blast radius of accidental removal of `.zshrc` file.

I should also consider having a backup of the file on each laptop, just in case...

```bash
export VISUAL=vim
export EDITOR=vim
```

## Tools

* [bat](https://github.com/sharkdp/bat)
* [delta](https://github.com/dandavison/delta)
* [fx](https://github.com/antonmedv/fx) (Function eXecution)
* [fzf](https://github.com/junegunn/fzf)
* [lazygit](https://github.com/jesseduffield/lazygit)
* [ranger](https://github.com/ranger/ranger)
* [scm_breez](https://github.com/scmbreeze/scm_breeze)
* [thefuck](https://github.com/nvbn/thefuck)
* [tig](https://github.com/jonas/tig)

## Aliases

* Create a config for `tmux` for each project using the [defaulut config](/tmux/default-layout.conf) and add to alias to start with the [tmux script](/scripts/tmux.sh)
* Add an alias for the `lazygit` command to make it just `lg`. It makes using it much easier.
