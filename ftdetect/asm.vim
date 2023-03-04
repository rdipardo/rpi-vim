"" ==========================================================================
""    This filetype plugin is part of rpi-vim
""    Maintainer: Robert Di Pardo <dipardo.r@gmail.com>
""    License:    https://github.com/rdipardo/rpi-vim/blob/main/LICENSE
"" ==========================================================================
if exists('b:did_ftplugin') | finish | endif
augroup RpiSetPreferredSyntax
  au VimEnter,BufNewFile,BufRead *.s,*.S setl filetype=arm
augroup END
let b:did_ftplugin = 1
