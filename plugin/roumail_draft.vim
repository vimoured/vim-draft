" vim-draft: drafts, text written in a buffer that isn't a file. A plugin's
" draft is opened by another plugin and hands its text on when it closes; a
" scratch is a draft you open yourself, with nowhere to send it. Any draft
" can be kept as a file: Draft before a command's name acts on drafts
" (:DraftSave, :Drafts), Draft after it writes a command's text in a
" plugin's draft (:CommentDraft, :AiDraft).

" Scratches are kept in vim-draft/ in the XDG state directory, a plugin's
" drafts where vim-place keeps plugins' files

" New scratch in a vertical split (!: in the current window)
command! -bang Scratch call roumail_draft#scratch#new(<bang>0)

" Scratch in the current window with the output of a shell command
command! -nargs=+ -complete=customlist,roumail_draft#scratch#complete_from ScratchFrom
      \ call roumail_draft#scratch#from(<q-args>)

" Copy a buffer into a new scratch, keeping its filetype.
" No argument or %: current buffer, limited to the range if one is given.
" Otherwise: that whole buffer (name, number or #), or else that file, read
" without opening it (<Tab> completes both).
command! -bang -range=% -nargs=? -complete=customlist,roumail_draft#scratch#complete_buf ScratchBuf
      \ call roumail_draft#scratch#buf(<bang>0, <line1>, <line2>, <q-args>)

" Keep the draft (or any other buffer, as a draft) as a file, which it stays
" apart from, as vim-place's save contract has it: a name, a path, a
" directory, or nothing for the file it was last kept in
command! -bang -nargs=? -complete=customlist,roumail_draft#complete DraftSave
      \ call roumail_draft#save(<bang>0, <q-args>)

" Kept drafts: this repository's (or directory's), and scratches, as
" vim-lists' list of saves
command! -bar Drafts call roumail_draft#drafts()
