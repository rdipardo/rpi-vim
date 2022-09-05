"" ==========================================================================
""    Maintainer: Robert Di Pardo <dipardo.r@gmail.com>
""    License:    https://github.com/rdipardo/rpi-vim-dev/blob/main/LICENSE
"" ==========================================================================

if get(g:, 'rpi_vim_dev_autoloaded') | finish | endif
let g:rpi_vim_dev_autoloaded = 1

let s:job_options = {
  \   'out_io': 'buffer',
  \   'err_io': 'out',
  \   'out_modifiable': 0,
  \   'err_modifiable': 0,
  \   'out_msg': 0
  \ }

func! rpi#Compile(...) abort
  let cmd =
    \ 'sh ' .
    \ expand('<sfile>:p:h') . '/plugin/sh/src-asm.sh ' .
    \ expand('%:p') . ' ' .
    \ get(a:, 1, '')

  if has('channel')
    let job = job_start(cmd, s:job_options)
    exec 'sbuf ' . ch_getbufnr(job, 'out')
  else
    exec '!\' . cmd
  endif
endfunc

func! rpi#Run() abort
  let cmd =
    \ 'sh ' .
    \ expand('<sfile>:p:h') . '/plugin/sh/src-run.sh ' .
    \ expand('%:p')

  if has('channel')
    let job = job_start(cmd, s:job_options)
    exec 'sbuf ' . ch_getbufnr(job, 'out')
  else
    exec '!\' . cmd
  endif
endfunc
