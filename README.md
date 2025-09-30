# My dotfiles

`git clone --depth=1 https://github.com/libinwa/dotfiles.git`

## vimrc
 By copying `dotfiles/_vimrc` to your `$HOME`, vim will then be configured.


## Navigating file system quickly

when [fzf](https://github.com/junegunn/fzf) and [fd](https://github.com/sharkdp/fd) are executable on your env, adding env variables:

```
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git --max-depth 6"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git --max-depth 5"
```

try:
- Press `<CTRL-T>` To fuzzily select a file or directory
- Press `<ALT-C>` To fuzzily change current directory
- Press `<CTRL-R>` To fuzzily search CLI history

> fd is designed to search for files by name, [rg](https://github.com/BurntSushi/ripgrep) is designed to search the contents of files.
> But ripgrep can be used to search for files by name rather than contents.

