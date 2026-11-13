" vim-draft: buffers to write text in that aren't files. A draft is opened
" by another plugin and hands its text on when it closes; a scratch is
" opened by you and has nowhere to send it. Either can be saved to a file.

" Scratches are saved in vim-draft/ in the XDG state directory, drafts where
" vim-place keeps plugins' files

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

" Write the buffer to a file, which it stays apart from, as a draft unless
" it is a scratch, as vim-place's save contract has it: a name, a path, a
" directory, or nothing for the file it was last saved to
command! -bang -nargs=? -complete=customlist,roumail_draft#complete DraftSave
      \ call roumail_draft#save(<bang>0, <q-args>)

" Saved drafts of the current repository (or directory) and saved scratches,
" as vim-lists' list of saves
command! -bar Drafts call roumail_draft#drafts()
