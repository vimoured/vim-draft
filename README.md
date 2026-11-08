# vim-draft

Buffers to write text in, apart from files. A **draft** is opened by another
plugin and hands its text on when it closes. A **scratch** is opened by you and
is dropped when it closes.

**Vim or Neovim:** tested on Vim 9.1 and newer. It's plain Vimscript, so it may
work on Neovim, but that's untested.

## Install

```vim
Plug 'vimoured/vim-draft'
```

To save drafts per repository, and for `:DraftList`, add
[vim-place](https://github.com/vimoured/vim-place) and
[vim-fugitive](https://github.com/tpope/vim-fugitive):

```vim
Plug 'tpope/vim-fugitive'
Plug 'vimoured/vim-place'
Plug 'vimoured/vim-draft'
```

## Use

| Command | What it does |
| --- | --- |
| `:Scratch[!]` | New scratch in a vertical split (`!`: in the current window). |
| `:ScratchFrom {cmd}` | Scratch with the output of a shell command. |
| `:[range]ScratchBuf[!] [buffer\|file]` | Copy a buffer, range or file into a new scratch. |
| `:DraftSave[!] [path\|dir/]` | Write the buffer to a file and leave it as it was. |
| `:DraftList` | Saved drafts and scratches in the location list, newest first. |

A draft works like a git commit message: `:w` saves, `:wq` closes and hands on
what was saved, and `:q!` before any `:w` drops it.

## For other plugins

```vim
call roumail_draft#open('my-plugin://note', ['first line'],
      \ {text -> MyPluginSend(text)},
      \ {'split': 'botright vnew', 'saved': 'Note saved: closing sends it'})
```

## Tests

The specs in [vim-suite](https://github.com/vimoured/vim-suite) define what it
does: `test/vim-draft.vim`.
