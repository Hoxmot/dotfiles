# herdr config

[herdr](https://herdr.dev) is a terminal workspace manager for AI coding agents.
This config is a port of [tmux.conf](../tmux/tmux.conf), so the muscle memory
carries over where herdr has an equivalent.

## Installation

Unlike the other configs here, **link the file, not the folder**. herdr writes
`herdr.log`, `herdr-client.log` and `herdr-server.log` next to its config, so
symlinking the whole directory would drop log files into this repo.

```shell
mkdir -p ~/.config/herdr
ln -s <PATH_TO_DOTFILES>/herdr/config.toml ~/.config/herdr/config.toml
```

Validate and reload without restarting:

```shell
herdr config check          # also reports invalid keybindings
herdr server reload-config
```

Note `herdr config check` exits 0 even when it reports problems — read the
output rather than the exit status.

### Plugins

Plugins install under `~/.config/herdr/plugins` and are not carried in this
repo, so they need installing separately on a new machine. `config.toml` binds
`ctrl+hjkl` to actions from
[vim-herdr-navigation](https://github.com/paulbkim-dev/vim-herdr-navigation),
which must be present or those four binds do nothing:

```shell
herdr plugin install paulbkim-dev/vim-herdr-navigation
herdr plugin list
```

It needs `jq` — without it the keys still move panes, just without vim
awareness. The editor half is configured in [nvim](../nvim), not here.

## What carried over from tmux

| tmux | herdr |
| --- | --- |
| prefix `ctrl+b` | `keys.prefix` — same default |
| `bind \|` → `split-window -h` (side by side) | `keys.split_vertical` |
| `bind -` → `split-window -v` (stacked) | `keys.split_horizontal` |
| `-c "#{pane_current_path}"` on splits | `terminal.new_cwd = "follow"` |
| `set -g mouse on` | `ui.mouse_capture` |
| `prefix + z` zoom | `keys.zoom` — same default |
| `allow-rename off` | `ui.prompt_new_tab_name` |
| `lg` alias for lazygit | `[[keys.command]]` popup on `prefix+alt+g` |
| ayu-dark via `@dracula-colors` | `theme.name = "terminal"` + `ui.accent` |
| `vim-tmux-navigator` `ctrl+hjkl` | `vim-herdr-navigation` plugin actions |

The split names invert: tmux's `-h`/`-v` describe how panes are *arranged*,
herdr's `split_vertical`/`split_horizontal` describe the *divider*. The
resulting layouts match.

### ctrl+hjkl navigation

The plugin works the same way `vim-tmux-navigator` does: the herdr side checks
the focused pane's foreground process with `herdr pane process-info`, forwards
the chord with `herdr pane send-keys` when it's vim, and otherwise moves focus
with `herdr pane focus --direction`. Two consequences:

* `ctrl+l` and `ctrl+k` shadow readline's clear-screen and kill-line in non-vim
  panes — the same tradeoff `vim-tmux-navigator` already makes.
* Other TUIs that own those chords need naming in `HERDR_NAV_PASSTHROUGH_RE`.
  [zshrc](../zsh/zshrc) sets it to `^lazygit$`. Unlike vim, those apps don't
  cross out at an edge — use `prefix+hjkl` to leave the pane.

`prefix+hjkl` is still bound too, so pane focus works even if the plugin is
missing.

herdr ships no ayu theme (`catppuccin`, `tokyo-night`, `dracula`, `nord`,
`gruvbox`, `one-dark`, `solarized`, `kanagawa`, `rose-pine`, `vesper`). Rather
than approximate it, `theme.name = "terminal"` follows the host terminal's ANSI
palette, so herdr inherits ayu from Ghostty and stays in sync automatically.
Only `ui.accent` is set by hand, because ayu's amber `#e6b450` has no ANSI slot.

## What did not carry over

* **vi copy-mode.** `mode-keys vi` and the `v`/`y`/`r` binds have no herdr
  equivalent. Selection is mouse-driven (`ui.copy_on_select`, on by default),
  with `keys.edit_scrollback` (`prefix+e`) to open scrollback in `$EDITOR`.
* **The status bar widgets.** The dracula plugin's battery, cpu-usage,
  ram-usage and time have no counterpart. herdr's sidebar reports agent and
  workspace state (`state_icon`, `workspace`, `branch`, `git_status`), not
  system metrics.
* **`history-limit`.** herdr counts scrollback in bytes, not lines, so
  `advanced.scrollback_limit_bytes` is not a direct translation.
* **`base-index 1`.** No equivalent; tabs are switched with `prefix+1..9`.
* `escape-time`, `focus-events`, `aggressive-resize` and `default-terminal` are
  tmux-internal and have no meaning here — herdr is the terminal.

## Running alongside tmux

Both default to `ctrl+b`. If herdr is launched from inside tmux, one of the two
prefixes has to move or the outer tmux swallows every prefix keypress.
