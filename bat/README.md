# bat config

[bat](https://github.com/sharkdp/bat) is a `cat` clone with syntax highlighting.
It also backs [delta](https://github.com/dandavison/delta), the pager configured
in [gitconfig](../git/gitconfig) — delta borrows bat's theme set, so both are
themed from here.

## Theme

bat ships no Ayu theme, so `themes/ayu-dark.tmTheme` is vendored. It is a
`.tmTheme` conversion of the upstream Sublime scheme from
[dempfi/ayu](https://github.com/dempfi/ayu) (`ayu-dark.sublime-color-scheme`),
which bat's syntax highlighter (syntect) can read where the JSON original it was
converted from cannot. The background is pinned to `#0b0e14`, the canonical Ayu
Dark background Ghostty uses, rather than the Sublime scheme's lighter `#10141c`.

## Installation

Move the folder to `$XDG_CONFIG_HOME/bat` or if the `$XDG_CONFIG_HOME` isn't set,
move it to `~/.config/bat`.

The vendored theme is not picked up until bat's cache is rebuilt:

```shell
bat cache --build
```

Re-run that after changing anything under `themes/`. To confirm it took:

```shell
bat --list-themes | grep ayu-dark
delta --list-syntax-themes | grep ayu-dark
```
