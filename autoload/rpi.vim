"" ==========================================================================
""    Maintainer: Robert Di Pardo <dipardo.r@gmail.com>
""    License:    https://github.com/rdipardo/rpi-vim/blob/main/LICENSE
"" ==========================================================================

if get(g:, 'rpi#plugin#autoloaded') | finish | endif
let g:rpi#plugin#autoloaded = 1

let s:job_options = {
  \   'out_io': 'buffer',
  \   'err_io': 'out',
  \   'out_modifiable': 0,
  \   'err_modifiable': 0,
  \   'out_msg': 0
  \ }

func! s:GetPluginRoot() abort
  let root = globpath(&rtp, '**/rpi-vim', 0, 0)
  if empty(root)
    let root = expand('<sfile>:p:h')
    if !isdirectory(root . '/plugin/sh')
      echoerr 'The rpi-vim plugin is not in any path that Vim can find!'
    endif
  endif
  return expand(root)
endfunc

func! rpi#Compile(...) abort
  if empty(expand('%:p'))
    echom 'Needed the name of a buffer or directory.'
    return
  endif

  let plugin_dir = s:GetPluginRoot()
  if empty(plugin_dir) | return | endif

  let cmd =
    \ 'sh ' .
    \ plugin_dir . '/plugin/sh/src-asm.sh ' .
    \ expand('%:p') . ' ' .
    \ join(a:000)

  if has('channel')
    let job = job_start(cmd, s:job_options)
    exec 'sbuf ' . ch_getbufnr(job, 'out')
  elseif has('nvim')
    exec 'sp term://' . cmd
  else
    exec '!\' . cmd
  endif
  exec 'wincmd k'
endfunc

func! rpi#Run() abort
  let plugin_dir = s:GetPluginRoot()
  if empty(plugin_dir) | return | endif

  let cmd =
    \ 'sh ' .
    \ plugin_dir . '/plugin/sh/src-run.sh ' .
    \ expand('%:p')

  if has('channel')
    let job = job_start(cmd, s:job_options)
    exec 'sbuf ' . ch_getbufnr(job, 'out')
  elseif has('nvim')
    exec 'sp term://' . cmd
  else
    exec '!\' . cmd
  endif
  exec 'wincmd k'
endfunc

func! rpi#Init(...) abort
  let plugin_dir = s:GetPluginRoot()
  if empty(plugin_dir) | return | endif

  let cmd = 'sh ' . plugin_dir
  let verb = get(a:, 1, '')

  let scripts = {
    \ 'boot': '/boot.sh ' . expand(get(a:, 2, plugin_dir)),
    \ 'setup':
    \   '/setup.sh ' . expand(get(a:, 2, '')) . ' ' . get(a:, 3, '')
    \ }

  let term_options = {
    \ 'env': {
    \   'RPI_VIM_HOME': plugin_dir
    \ },
    \ 'norestore': 1,
    \ 'term_kill': 9
    \ }

  if has_key(scripts, verb)
    let cmd .= scripts[verb]
    if verb ==# 'boot'
      let term_options.cwd = expand(get(a:, 2, plugin_dir))
      let term_options.hidden = 1
    endif
  else
    " https://vi.stackexchange.com/a/5503
    let callee = substitute(expand('<sfile>'), '.*\(\.\.\|\s\)', '', '')
    echom 'Do not call ' . callee . ' directly! Use :RPiSetup or :RPiBoot'
    return
  endif

  func! s:ShowBootWnd(state, bufnr) abort
    if a:state > 0
       echom 'RPi VM started.'
       let switch = input('Switch to VM window now? [y/n] ')
       if switch =~? '^y' | exec 'sbuf ' . a:bufnr | endif
    endif
  endfunc

  if has('terminal')
    let bufnr = term_start(cmd, term_options)
    if verb ==# 'boot'
      call s:ShowBootWnd(bufnr, bufnr)
    endif
  elseif has('nvim')
    unlet term_options.norestore
    unlet term_options.term_kill
    let term_options.detach = 1
    let bufnr = nvim_create_buf(v:true, v:false)
    exec 'sbuf ' . bufnr
    let term = termopen(split(cmd), term_options)
    setl nomodified
    if verb ==# 'boot'
      exec 'hide'
      call s:ShowBootWnd(term, bufnr)
    endif
  elseif verb !=# 'boot'
    exec '!\' . cmd
  else
    echom 'Open a new terminal and run'
    echom '$ ' . cmd
  endif
  exec 'wincmd k'
endfunc
