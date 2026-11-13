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

`:DraftSave` keeps vim-place's
[save contract](https://github.com/vimoured/vim-place#the-save-contract), and
`:DraftList` shows the saves as vim-lists'
[list of saves](https://github.com/vimoured/vim-lists#a-list-of-saves), apart
from these deviations:

| Deviation | |
| --- | --- |
| `:DraftSave` takes no names: a word is a file in the current directory, and `<Tab>` completes files only. | To align: it came before the contract. |
| `:DraftList` is named for the verb; it would be `:Drafts`. | To align: it came before the contract. |
| `:DraftList` is a location list, not a vim-lists list: no title with a count, no `dd`, `/` or `r`, and no row when nothing is saved. | To align: it came before the contract. |
| No `:DraftLoad`: a saved draft is opened as the file it is (`<CR>` in `:DraftList`). | Needed: a saved draft is a file to edit, not a buffer to make again. |
| A new file is `.md` for a markdown buffer, else `.txt`. | Needed: the extension follows the text. |
| A scratch saves without vim-place, under `$XDG_STATE_HOME/vim-draft`, and `:DraftList` lists those too. | Needed: a scratch belongs to no repository. |

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
