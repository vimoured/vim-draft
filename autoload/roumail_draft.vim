function! roumail_draft#open(name, lines, OnClose, ...) abort
  let l:opts = extend({'split': 'belowright new',
        \ 'saved': 'Draft saved: closing hands it on',
        \ 'empty': 'Draft empty: closing hands nothing on'}, get(a:, 1, {}))
  let l:from = bufnr()
  execute l:opts.split
  setlocal buftype=acwrite bufhidden=wipe noswapfile
  execute 'silent file' fnameescape(bufexists(a:name) ? a:name . '/' . bufnr() : a:name)
  call setline(1, a:lines)
  setlocal nomodified
  let b:roumail_draft = {'kind': 'draft', 'path': '', 'text': '', 'OnClose': a:OnClose,
        \ 'from': l:from, 'saved': l:opts.saved, 'empty': l:opts.empty}
  augroup roumail_draft
    autocmd! * <buffer>
    autocmd BufWriteCmd <buffer> call s:save()
    autocmd QuitPre <buffer> call s:keep_vim()
    autocmd BufWipeout <buffer> call s:close(str2nr(expand('<abuf>')))
  augroup END
  normal! G$
endfunction

function! s:save() abort
  let l:lines = getline(1, '$')
  while !empty(l:lines) && l:lines[-1] =~# '^\s*$'
    call remove(l:lines, -1)
  endwhile
  while !empty(l:lines) && l:lines[0] =~# '^\s*$'
    call remove(l:lines, 0)
  endwhile
  let b:roumail_draft.text = join(l:lines, "\n")
  setlocal nomodified
  echo empty(l:lines) ? b:roumail_draft.empty : b:roumail_draft.saved
endfunction

function! s:keep_vim() abort
  " Quitting Vim would lose the text
  if len(getwininfo()) > 1
    return
  endif
  let l:from = b:roumail_draft.from
  execute 'topleft' (bufexists(l:from) ? 'sbuffer ' . l:from : 'new')
  wincmd p
endfunction

function! s:close(bufnr) abort
  let l:draft = getbufvar(a:bufnr, 'roumail_draft')
  if empty(l:draft) || empty(l:draft.text)
    return
  endif
  try
    call l:draft.OnClose(l:draft.text)
  catch
    " The buffer is gone: its text would be too
    throw 'vim-draft: handing on failed (' . v:exception . '); '
          \ . s:keep(l:draft, getbufvar(a:bufnr, '&filetype'))
  endtry
endfunction

" Writes the text a draft failed to hand on to a new file where :DraftSave
" would, else to the unnamed register, and says where
function! s:keep(draft, filetype) abort
  try
    let l:dir = !empty(globpath(&runtimepath, 'autoload/roumail_place.vim', 1))
          \ ? roumail_place#dir('vim-draft', {'bufnr': a:draft.from}) : s:scratch_dir()
    let l:path = s:new_file(l:dir, a:filetype)
    call writefile(split(a:draft.text, "\n", 1), l:path)
    return 'text kept in ' . fnamemodify(l:path, ':~')
  catch
  endtry
  call setreg('"', a:draft.text, 'l')
  return 'text kept in the unnamed register'
endfunction

" Writes the text as it is now to a file, leaving the buffer as it was: a
" draft still hands on what :w last saved when it closes. Any other buffer
" is saved as a draft opened from itself. The argument is vim-place's save
" contract, with the deviations in the README (no names)
function! roumail_draft#save(bang, arg) abort
  if !exists('b:roumail_draft')
    let b:roumail_draft = {'kind': 'buffer', 'path': '', 'from': bufnr()}
  endif
  let l:draft = b:roumail_draft
  let l:path = s:target(l:draft, a:arg)
  if empty(l:path)
    return
  endif
  " A name is the draft's to save again; a path you gave, only with !
  if s:is_path(a:arg) && filereadable(l:path) && !a:bang && l:path !=# l:draft.path
    echoerr 'DraftSave: ' . fnamemodify(l:path, ':~') . ' exists (add ! to overwrite)'
  endif
  call mkdir(fnamemodify(l:path, ':h'), 'p')
  " A failed write is an error before the path is taken: the buffer stays as
  " it was
  call writefile(getline(1, '$'), l:path)
  let l:draft.path = l:path
  echo 'DraftSave: wrote ' . fnamemodify(l:path, ':~')
endfunction

" A path has a / or starts with ~ or .; anything else is a save's name
function! s:is_path(arg) abort
  return a:arg =~# '/' || a:arg =~# '^[~.]'
endfunction

function! s:ext(filetype) abort
  return a:filetype ==# 'markdown' ? '.md' : '.txt'
endfunction

" The file last written, unless the argument names another file, a
" directory to write a new one in, or a save by name
function! s:target(draft, arg) abort
  if empty(a:arg)
    if empty(a:draft.path) && a:draft.kind !=# 'scratch' && !s:requires(':DraftSave of a draft')
      return ''
    endif
    return empty(a:draft.path) ? s:new_file(s:save_dir(a:draft), &filetype) : a:draft.path
  elseif !s:is_path(a:arg)
    if a:draft.kind !=# 'scratch' && !s:requires(':DraftSave of a name')
      return ''
    endif
    return s:save_dir(a:draft) . '/' . a:arg . s:ext(&filetype)
  endif
  let l:path = fnamemodify(a:arg =~# '^[~$]' ? expand(a:arg) : a:arg, ':p')
  " :p ends an existing directory with /
  return l:path =~# '/$'
        \ ? s:new_file(substitute(l:path, '/\+$', '', ''), &filetype) : l:path
endfunction

" Named for the time, so they sort
function! s:new_file(dir, filetype) abort
  let l:base = a:dir . '/' . strftime('%Y%m%d-%H%M%S')
  let l:ext = s:ext(a:filetype)
  let l:path = l:base . l:ext
  let l:n = 1
  while filereadable(l:path)
    let l:n += 1
    let l:path = l:base . '-' . l:n . l:ext
  endwhile
  return l:path
endfunction

" A scratch is saved outside any repository; a draft, as a plugin's files
" are, in the repository of the buffer it was opened from
function! s:save_dir(draft) abort
  return a:draft.kind ==# 'scratch' ? s:scratch_dir()
        \ : roumail_place#dir('vim-draft', {'bufnr': a:draft.from})
endfunction

" vim-draft/ in the XDG state directory
function! s:scratch_dir() abort
  let l:dir = (empty($XDG_STATE_HOME) ? expand('~/.local/state') : $XDG_STATE_HOME) . '/vim-draft'
  call mkdir(l:dir, 'p')
  return l:dir
endfunction

" The saves where names are, newest first, then files once it's a path
function! roumail_draft#complete(lead, cmdline, pos) abort
  if s:is_path(a:lead) || empty(globpath(&runtimepath, 'autoload/roumail_place.vim', 1))
    return getcompletion(a:lead, 'file')
  endif
  let l:draft = get(b:, 'roumail_draft', {'kind': 'buffer', 'from': bufnr()})
  return filter(map(s:files([s:save_dir(l:draft)]), 'fnamemodify(v:val, ":t:r")'),
        \ 'stridx(v:val, a:lead) == 0')
endfunction

" The files in dirs, newest first
function! s:files(dirs) abort
  let l:files = []
  for l:dir in filter(copy(a:dirs), '!empty(v:val)')
    call extend(l:files, filter(glob(l:dir . '/*', 1, 1), 'filereadable(v:val)'))
  endfor
  return sort(l:files, {a, b -> getftime(a) != getftime(b)
        \ ? getftime(b) - getftime(a) : a ==# b ? 0 : a <# b ? 1 : -1})
endfunction

" :Drafts: saved drafts of this repository or directory, and saved
" scratches, as vim-lists' list of saves
function! roumail_draft#drafts() abort
  if !s:requires(':Drafts')
    return
  endif
  if empty(globpath(&runtimepath, 'autoload/roumail_lists.vim', 1))
    echohl ErrorMsg
    echomsg 'vim-draft: :Drafts needs vim-lists, which is not installed'
    echohl None
    return
  endif
  let l:draft = get(b:, 'roumail_draft', {})
  let l:from = get(l:draft, 'kind', '') ==# 'draft' ? l:draft.from : bufnr()
  let l:dirs = uniq(sort([roumail_place#dir('vim-draft', {'bufnr': l:from}), s:scratch_dir()]))
  call roumail_lists#open('vim-draft://drafts', {
        \ 'fetch': function('s:drafts_fetch'),
        \ 'heading': {drafts -> ['Drafts (' . len(drafts) . ')']},
        \ 'rows': function('s:drafts_rows'),
        \ 'id': {d -> d.file},
        \ 'match': {d -> d.name . ' ' . d.first},
        \ 'delete': function('s:drafts_delete'),
        \ 'keys': [{'key': '<CR>', 'hint': 'open', 'call': function('s:drafts_open')}]},
        \ {'roumail_draft_dirs': l:dirs})
endfunction

function! s:drafts_fetch() abort
  return map(s:files(b:roumail_draft_dirs), {_, f -> {'file': f,
        \ 'name': fnamemodify(f, ':t:r'), 'time': getftime(f),
        \ 'first': get(readfile(f, '', 1), 0, '')}})
endfunction

function! s:drafts_rows(drafts) abort
  if empty(a:drafts)
    return [{'lines': ['(no drafts here: save one with :DraftSave)']}]
  endif
  return map(copy(a:drafts), {_, d -> {'item': d, 'lines': [printf('%-20s  %s  %s',
        \ d.name, strftime('%Y-%m-%d %H:%M', d.time), d.first)]}})
endfunction

function! s:drafts_delete(draft) abort
  if confirm('Delete ' . fnamemodify(a:draft.file, ':t') . '?', "&Yes\n&No", 2) == 1
    call delete(a:draft.file)
  endif
endfunction

" A saved draft is a file to edit: opened where the list was opened from
function! s:drafts_open() abort
  let l:draft = roumail_lists#item()
  if !empty(l:draft)
    wincmd p
    execute 'edit' fnameescape(l:draft.file)
  endif
endfunction

" vim-place keeps drafts per repository: what needs it says so when it isn't
" installed
function! s:requires(what) abort
  if !empty(globpath(&runtimepath, 'autoload/roumail_place.vim', 1))
    return 1
  endif
  echohl ErrorMsg
  echomsg 'vim-draft: ' . a:what . ' needs vim-place (with vim-fugitive), which is not installed'
  echohl None
  return 0
endfunction
