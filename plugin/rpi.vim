"" ==========================================================================
""    Maintainer: Robert Di Pardo <dipardo.r@gmail.com>
""    License:    https://github.com/rdipardo/rpi-vim-dev/blob/main/LICENSE
"" ==========================================================================

if get(g:, 'rpi_vim_dev_loaded') | finish | endif
let g:rpi_vim_dev_loaded = 1

if !exists(':RPiCompile')
  com! -nargs=* RPiCompile :call rpi#Compile(<f-args>)
  nnoremap <F8> :RPiCompile<CR>
  nnoremap <F9> :exe 'RPiCompile all'<CR>
endif

if !exists(':RPiRun')
  com! RPiRun :call rpi#Run()
  nnoremap <F7> :RPiRun<CR>
endif
