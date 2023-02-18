# tmux

## ToC

1. [Table of Contents](#toc)
1. [Installation](#installation)
1. [Files](#files)
1. [Plugins](#plugins)

## Installation

1. Install the tmux config by copying `tmux.conf` to `~/.tmux.conf`.
    1. Setup the correct way of copying to your systems clipboard. Both lines should be in file, uncomment the correct one for your system. Look for `ACTION REQUIRED` in the file.
        * `xclip` for Linux
        * `pbcopy` for MacOS
1. Install [Tmux Plugin Manager (tpm)](https://github.com/tmux-plugins/tpm)
    1. Clone the repository to tmux plugins
    ```bash
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ```
    1. The plugin manager is already configured in the `tmux.conf`, so you should be ready to go
1. Install the rest of the configured plugins by pressing `prefix` + `i` (by default: `Ctrl`+`b` `i`). See [plugins](#plugins) for the list of used plugins

## Files

* `tmux.conf` -> `~/.tmux.conf`
* `default-layout.conf` -> You can use customize the file and use [tmux.sh](/scripts/tmux.sh) to run your desired configuration

## Plugins

* [Tmux Plugin Manager (tpm)](https://github.com/tmux-plugins/tpm) - plugins manager
* [Dracula theme](https://github.com/dracula/tmux/) - theme for the tmux. It makes it nice. It's preconfigured in the `tmux.conf`.
