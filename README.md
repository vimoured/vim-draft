# vim-draft

Drafts: text you write in a buffer, apart from files. A **scratch** is a draft
you open yourself, with nowhere to send it. **A plugin's draft** (a comment, a
question to an agent, a reply) hands its text on when it closes. Any draft can
be kept as a file, and found again.

**Vim or Neovim:** tested on Vim 9.1 and newer. It's plain Vimscript, so it may
work on Neovim, but that's untested.

## Install

```vim
Plug 'vimoured/vim-draft'
```

To keep drafts per repository and by name, add
[vim-place](https://github.com/vimoured/vim-place) and
[vim-fugitive](https://github.com/tpope/vim-fugitive); for `:Drafts`, also
[vim-lists](https://github.com/vimoured/vim-lists):

```vim
Plug 'tpope/vim-fugitive'
Plug 'vimoured/vim-place'
Plug 'vimoured/vim-lists'
Plug 'vimoured/vim-draft'
```

## Use

| Command | What it does |
| --- | --- |
| `:Scratch[!]` | New scratch in a vertical split (`!`: in the current window). |
| `:ScratchFrom {cmd}` | Scratch with the output of a shell command. |
| `:[range]ScratchBuf[!] [buffer\|file]` | Copy a buffer, range or file into a new scratch. |
| `:DraftSave[!] [name\|path\|dir/]` | Keep the draft you're in as a file, and leave it as it was. With no argument, to the file it was last kept in, else a new one. `!` overwrites another file at that path. Any other buffer is kept as a draft too. |
| `:Drafts` | Kept drafts, newest first: `<CR>` opens one, `dd` deletes it. |

`Draft` before a command's name means it acts on drafts, of any kind:
`:DraftSave`, `:Drafts`. `Draft` after it means another command, with its text
written in a plugin's draft instead of on the command line: `:Comment` and
`:CommentDraft`, `:Ai` and `:AiDraft`, `:Reply` and `:ReplyDraft`. A plugin
adding a draft names its command that way.

`:DraftSave` keeps vim-place's
[save contract](https://github.com/vimoured/vim-place#the-save-contract), and
`:Drafts` is vim-lists'
[list of saves](https://github.com/vimoured/vim-lists#a-list-of-saves), apart
from these deviations:

| Deviation | |
| --- | --- |
| No `:DraftLoad`: a saved draft is opened as the file it is (`<CR>` in `:Drafts`). | Needed: a saved draft is a file to edit, not a buffer to make again. |
| A new file or a name's file is `.md` for a markdown buffer, else `.txt`. | Needed: the extension follows the text. |
| A scratch is kept outside any repository, under `$XDG_STATE_HOME/vim-draft`, without vim-place; `:Drafts` lists them with the repository's. | Needed: a scratch belongs to no repository. |

A plugin's draft works like a git commit message: `:w` saves, `:wq` closes and
hands on what was saved, and `:q!` before any `:w` drops it.

## For other plugins

```vim
call roumail_draft#open('my-plugin://note', ['first line'],
      \ {text -> MyPluginSend(text)},
      \ {'split': 'botright vnew', 'saved': 'Note saved: closing sends it'})
```

## Tests

The specs in [vim-suite](https://github.com/vimoured/vim-suite) define what it
does: `test/vim-draft.vim`.
