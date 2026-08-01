# Git

## Intallation

Go to your home directory and link the config there:

```bash
ln -s <PATH_TO_DOTFILES>/git/gitconfig .gitconfig
```

## Pager

The pager is [delta](https://github.com/dandavison/delta), themed to Ayu Dark.
Its `syntax-theme` is vendored through [bat](../bat/README.md), so on a fresh
machine set that config up and run `bat cache --build` — otherwise delta falls
back to its default theme.

