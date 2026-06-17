" Let junegunn/vim-plug handle plugins
exec 'source '.PackHome().'/plug.vim'
call plug#begin(PackHome())
"
" List the plugins with Plug commands
Plug 'tpope/vim-fugitive'
Plug 'yegappan/lsp'
"Plug 'puremourning/vimspector'
"Plug 'Freed-Wu/cppinsights.vim'
"Plug 'girishji/devdocs.vim'
"Plug 'diepm/vim-rest-console'
Plug 'tomasiser/vim-code-dark'
Plug 'dfxyz/CandyPaper.vim'
"Plug 'madox2/vim-ai'
call plug#end()
" INITIALIZATION OF PLUGINs

"
" use optional plugin with packadd command
" silently ignored in unsupported versions
silent! packadd! editorconfig

"
" 查词典
nnoremap <leader>di  :!start https://www.bing.com/dict/search?q=<cword>&FORM=BDVSP6&cc=cn<CR>

" shows tree view in netrw window
let g:netrw_liststyle=3
let g:netrw_keepdir=0

"
" colorscheme
"
"colo codedark
set background=light
colo CandyPaper


"
" Settings Plug 'yegappan/lsp'
"
"{
  let lspServers = []
  if executable('clangd')
    let lspServers += [#{
          \  name: 'clang',
          \  filetype: ['c', 'cpp'],
          \  path: 'clangd',
          \  args: ['--background-index', '--clang-tidy', '--header-insertion=never', '--completion-style=detailed'],
          \  initializationOptions: #{
          \    completion: #{
          \      detailedLabel: v:true,
          \      placeholder: v:false
          \    },
          \    diagnostics: #{
          \      unusedIncludes: v:true
          \    }
          \  }
          \}]
  endif
  if executable('cmake-language-server')
    let lspServers += [#{
          \  name: 'cmakelsp',
          \  filetype: 'cmake',
          \  path: 'cmake-language-server',
          \  initializationOptions: #{
          \    buildDirectory: ProjectDir()
          \  }
          \}]
  endif
  if executable('rust-analyzer')
    let lspServers += [#{
          \  name: 'rustanalyzer',
          \  filetype: ['rust'],
          \  path: 'rust-analyzer',
          \  args: [],
          \  syncInit: v:true,
          \  initializationOptions: #{
          \    inlayHints: #{
          \      typeHints: #{
          \        enable: v:true
          \      },
          \      parameterHints: #{
          \        enable: v:true
          \      }
          \    },
          \  }
          \}]
  endif
  if executable('lua-language-server')
    let lspServers += [#{
          \  name: 'lua',
          \  filetype: ['lua'],
          \  path: 'lua-language-server',
          \  args: []
          \}]
  endif
  if executable('pylsp')
    let lspServers += [#{
          \  name: 'pylsp',
          \  filetype: 'python',
          \  path: 'pylsp',
          \  args: [],
          \  initializationOptions: #{
          \    configurationSources: ['flake8'],
          \    plugins: #{
          \      pycodestyle: #{ enabled: v:true },
          \      pyflakes: #{ enabled: v:true }
          \    }
          \  }
          \}]
  endif

  let lspOpts = #{
      \ autoHighlightDiags: v:true
  \}


  function! OnLspAttached()
      setlocal formatexpr=lsp#lsp#FormatExpr()
      " To jump to the symbol definition using the vim tag-commands Ctrl-]
      if exists('+tagfunc') | setlocal tagfunc=lsp#lsp#TagFunc | endif
      "Switch between source and header files.
      nnoremap <buffer> gO :LspSwitchSourceHeader<CR>
      nnoremap <buffer> gD :LspGotoDeclaration<CR>
      nnoremap <buffer> gd :LspGotoDefinition<CR>
      nnoremap <buffer> gi :LspGotoImpl<CR>
      nnoremap <buffer> gt :LspGotoTypeDef<CR>
      nnoremap <buffer> gs :LspDocumentSymbol<CR>
      nnoremap <buffer> gS :LspSymbolSearch<CR>
      nnoremap <buffer> gr :LspPeekReferences<CR>
      nnoremap <buffer> [g :LspDiagPrev<CR>
      nnoremap <buffer> ]g :LspDiagNext<CR>
      nnoremap <buffer> K  :LspHover<CR>
      nnoremap <buffer> <leader>rn :LspRename<CR>
      nnoremap <buffer> <leader>ca :LspCodeAction<CR>
      vnoremap <buffer> <leader>fm :LspFormat<CR>
  endfunction


  augroup lsp_config
    au!
    autocmd User LspSetup call LspOptionsSet(lspOpts)
    autocmd User LspSetup call LspAddServer(lspServers)
    autocmd User LspAttached call OnLspAttached()
  augroup END
"}


"
" local envs
"
"let $PATH = g:my_toolbox."/scripts;".$PATH    " Got env of my scripts
"if exists('&pythonthreehome') | let &pythonthreehome=expand("$HOME/.conda/envs/py38") | let $PATH = &pythonthreehome.";".&pythonthreehome."/Scripts;".$PATH | endif
" http_proxy and https_proxy pointing to px (http://127.0.0.1:3128)
"let $HTTP_PROXY="http://127.0.0.1:3128"
"let $HTTPS_PROXY="http://127.0.0.1:3128"


" Function: Copy files with extern tools
" Sync files between local source and destination (ssh config is for remote).
function! SyncFiles(src, dest)
  if a:src == '' | echohl ErrorMsg | echomsg printf('source cannot be empty.') | echohl NONE | endif
  let host = '' | let source = a:src | let destination = a:dest | let tmpfmt = a:src.' %s'
  if destination == ''
    let choices='' | let i = 1 | let h = '' | let hosts=['NA']
    echo 'Hosts:' | echo printf(' [%d] local', i) | call add(hosts, h) | let i+=1
    let sshconfig = expand('$HOME/.ssh/config')
    if filereadable(sshconfig)
      let items = filter(readfile(sshconfig), 'v:val =~ "^Host\\s\\+"')
      for h in items
        let h = substitute(h, '^\s*Host\s\+\(.*\)\s*', '\1', 'g')
        echo printf(' [%d] %s', i, h) | call add(hosts, h.':') | let i+=1
      endfor
    endif
    let host = get(hosts, input("To:"), 'NA') | let tmpfmt = source.' '.host.'%s'
    if host ==# 'NA' | let host = get(hosts, input("From:"), 'NA') | let tmpfmt = host.'%s '.source | endif
    let destination = input("destination:")
  endif
  if host != 'NA' && destination != ''
    if executable('rsync')
      let cmd = printf('rsync -zahcvv --stats '.tmpfmt, destination)
      let fltconfig = executable('rg')? get(glob('`rg --files | rg rsync_filter.txt`', 0, 1), 0, '')
            \: findfile('rsync_filter.txt', '**/*')  " Downward search
      if fltconfig != '' | let cmd = cmd.' --filter="merge '.fltconfig.'"' | endif
      call JobStart('SyncFiles[rsync]'.destination, cmd)
    elseif executable('scp')
      call JobStart('SyncFiles[scp]'.destination, printf("scp -Cprv ".tmpfmt, destination))
    else
      echohl ErrorMsg | echomsg printf('No executable sync tool.') | echohl NONE
    endif
  endif
endfunction
command! -bar -nargs=+ -complete=file Sync call SyncFiles(<f-args>)
command! -bar -nargs=+ -complete=file SyncI call SyncFiles(<q-args>, '')



if has('nvim')
  let g:python3_host_prog = expand("$HOME/.conda/envs/py38/python.exe")
lua << EOF
print('additional config for nvim')

vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  settings = {
    ['rust-analyzer'] = {}
  }
})

vim.lsp.enable('rust_analyzer')


local function switch_source_header(bufnr, client)
  local method_name = 'textDocument/switchSourceHeader'
  ---@diagnostic disable-next-line:param-type-mismatch
  if not client or not client:supports_method(method_name) then
    return vim.notify(('method %s is not supported by any servers active on the current buffer'):format(method_name))
  end
  local params = vim.lsp.util.make_text_document_params(bufnr)
  ---@diagnostic disable-next-line:param-type-mismatch
  client:request(method_name, params, function(err, result)
    if err then
      error(tostring(err))
    end
    if not result then
      vim.notify('corresponding file cannot be determined')
      return
    end
    vim.cmd.edit(vim.uri_to_fname(result))
  end, bufnr)
end

local function symbol_info(bufnr, client)
  local method_name = 'textDocument/symbolInfo'
  ---@diagnostic disable-next-line:param-type-mismatch
  if not client or not client:supports_method(method_name) then
    return vim.notify('Clangd client not found', vim.log.levels.ERROR)
  end
  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  ---@diagnostic disable-next-line:param-type-mismatch
  client:request(method_name, params, function(err, res)
    if err or #res == 0 then
      -- Clangd always returns an error, there is no reason to parse it
      return
    end
    local container = string.format('container: %s', res[1].containerName) ---@type string
    local name = string.format('name: %s', res[1].name) ---@type string
    vim.lsp.util.open_floating_preview({ name, container }, '', {
      height = 2,
      width = math.max(string.len(name), string.len(container)),
      focusable = false,
      focus = false,
      title = 'Symbol Info',
    })
  end, bufnr)
end

---@class ClangdInitializeResult: lsp.InitializeResult
---@field offsetEncoding? string

---@type vim.lsp.Config
vim.lsp.config ('clangd',
  {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  root_dir = vim.fn.ProjectDir(),
  --- root_markers = {
  ---   '.clangd',
  ---   '.clang-tidy',
  ---   '.clang-format',
  ---   'compile_commands.json',
  ---   'compile_flags.txt',
  ---   'configure.ac', -- AutoTools
  ---   '.git',
  --- },
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { 'utf-8', 'utf-16' },
  },
  ---@param init_result ClangdInitializeResult
  on_init = function(client, init_result)
    if init_result.offsetEncoding then
      client.offset_encoding = init_result.offsetEncoding
    end
  end,
  on_attach = function(client, bufnr)
    vim.lsp.completion.enable(true, client.id, bufnr, {
      autotrigger = true,
      convert = function(item)
        return { abbr = item.label:gsub('%b()', '') }
      end,
    })
    vim.keymap.set('n', 'gO', switch_source_header, {noremap=true, silent=true, buffer=bufnr})
    vim.keymap.set('n', 'gS', symbol_info, {noremap=true, silent=true, buffer=bufnr})
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {noremap=true, silent=true, buffer=bufnr})
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {noremap=true, silent=true, buffer=bufnr})
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, {noremap=true, silent=true, buffer=bufnr})
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {noremap=true, silent=true, buffer=bufnr})
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, {noremap=true, silent=true, buffer=bufnr})
    vim.keymap.set('n', 'gs', vim.lsp.buf.document_symbol, {noremap=true, silent=true, buffer=bufnr})
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, {noremap=true, silent=true, buffer=bufnr})
  end,
})

vim.lsp.enable('clangd')

EOF
endif



"
" local settings
if filereadable(ProjectDir().'/.vimrc.local')
  exec 'source '.ProjectDir().'/.vimrc.local'
endif


finish





--- -------------
title: vim notes
--- -------------

# Notes

vim notes.

## Practice and Tips

0. jk                          : Escape from Insert Mode
1. <leader>w                   : 敲CTRL-W太费指头, mapping for wincmd is nice. 例如敲 <leader>wL 就能 Move window right
2. Launch .                    : Windows Explorer中打开当前工作目录（linux也适用）
3. Launch %或!start %          : 用Windows上默认应用程序（!start /B %）打开当前文件；Visual Mode下选中目标文件敲 gx 打开 (linux也适用gx)
4. :cd %:h                     : 切到当前文件所在目录，用<leader>cd更容易；CD %:h切换ProiectDir为当前文件目录；
5. :CD!                        : Seek ProjectDir that contains current file; CD切换当前目录到ProjectDir；
6. :on                         : Command would close all windows but the current one, see ":h only"
7. :q或<leader>wq              : 关闭当前window.
8. winid+<leader>ww            : 敲winid(显示在状态栏右下角)再敲<leader>ww可以快速跳到目标window
9. <C-K/J/L/H>                 : resize window
10. :Find/Find!/Finda          : search target file
11. :Grep/Grep!/Grepa          : search target content; 'Grep content %' searchs content from current file
12. :Run                       : Run vimscript lines or line ranges.
13. <space><enter>             : Execute the visual selection (Visual Mode) as a shell command
14. <leader>ai                 : 呼出AIChat, nnoremap <leader>ai :AIChat <space> <space>和vnoremap <leader>ai :AIChat<space><space>
15. :edit <C-R><C-F>           : 编辑或新建文件；文件fullpath可以来自<C-R><C-F>（光标下textobject）给出的文件路径；<C-R><C-F>也可以获取netrw中光标下路径
16. gf 或 gF                   : go to file under the cursor (file name is checked with &isfname option)
17. :Red ol 或 :Recent         : Red重定向Command输出到窗口；组合Red ol列出recent files之后进一步搜索目标文件，敲入gf就可以打开；
18. <leader>gb                 : 根据光标下<cWORD>(通常是ls命令列出的buffer number)显示buffer到当前window；
19. <Tab>f                     : to get a completation of file name under Insert Mode
20. g; 或 g,                   : jump to [count] older/newer position in change 1ist, which is different of CTRL-O/CTRL-i.
21. :marks                     : show all marks. Jumping with marks ('A and 'a; uppercase marks are valid between files; lowercase marks are valid within one file)
22. "<reg><leader>mm           : MACRO Recorder，把寄存器中的宏转换成一个给寄存器赋值的语句，以实现持久化保存该宏。
23. :earlier 1m or 5m          : undo, to the old text state about 1or5 minute before.
24. :Git stash push <cfile>    : to stash the file under cursor, based on plugin 'tpope/vim-fugitive'
25. :Fmt %#X                   : format text based on format string like printf style.
26. <C-E>                      : under Insert Mode, eval expr in register (@") and put result at cursor position
27. gv"vy                      : yank previous selection (previous area in Visual Mode) with register v.
28. :r !tree %:h               : 引用命令输出；外部命令tree输出当前文件所在目录下子目录（树形结构）
29. :e %:p 或 :edit %:p        : type <tab> key to expand `%:p` to a full path
30. :g或:global                : 对于满足pattern的行执行命令cmd，`:g/{pattern}/{cmd}`
31. <leader>di                 : 查字典 nnoremap <leader>di  :!start https://www.bing.com/dict/search?q=<cword>&FORM=BDVSP6&cc=cn<CR>
32. M/H/L                      : 快速移动光标到窗口所显示内容的中部/头部/底部
33. <leader>x或:Rexplore       : 回到Explore目录netrw窗口或从Explore目录netrw窗口离开
34. <leader>X或直接敲:Lexplore : 左侧展示Explore窗口；窗口(netrw)内敲I隐藏banner,小i变换显示方式,小r是排序,小o新窗口打开文件,大O是Obtain远端文件,回车也是打开文件。
35. MOVE MOVE                  : 使用hijk或count +E/e/B/b移动光标靠近目标text object
36. MOVE FAST  : f/F/t/T +目标字符或附近的容易字符快速到达目标或附近，然后hijk移动到目标；如果有重复字符导致f/F/t/T还没有靠近目标，则使用;/,重复上一次f/F/t/T以快速靠近目标。
37. y.         : yank full path of file in current buffer, and full path of file under the cursor in netrw window
38. za         : 常规模式下敲zi键来开关光标行所在行的折叠（注：zR 展开所有折叠，zM 关闭所有折叠）


Regexp in vim: Vim 有自己独特的正则语法风格，既不是 POSIX，也不是 PCRE。但它支持两种正则模式:

- “Magic” 模式（默认）：需要给很多字符加反斜杠（如 \+，\?和\(）；比较繁琐，历史遗留风格。
- “Very Magic” 模式（\v）：更接近 PCRE 风格。无需给大多数元字符加反斜杠（比如直接写+，?，|，(，)）

所以说，Vim 的正则是自成一派的，但开启 \v 后可写出更接近现代风格的表达式。所以，如果熟悉python或Javascript的正则，则推荐开启 Very Magic 模式。


## Nice Plugins

1. [fzf](https://github.com/junegunn/fzf), a general-purpose command line fuzzy finder.

 - Plug 'junegunn/fzf'
 - Plug 'junegunn/fzf.vim'

Settings for fzf:
```vimscript
if isdirectory(PackHome().'/fzf')
  let g:fzf_command_prefix = 'Fz'
  command! -bang FzDiffs call fzf#vim#files(ProjectDir(), {'sink': 'diffsplit'}, <bang>0)
  if has('popupwin')
      let g:fzf_layout={'window':{'width':0.9, 'height':0.6, 'border':'rounded', 'highlight':'Question'}}
  endif
  if executable('fzf') && !exists('g:loaded_fzf')
      let fzf_script_needed = expand($HOME).'/.fzf/plugin/fzf.vim'
      if filereadable(fzf_script_needed)
          exec 'source '.fzf_script_needed
      endif
  endif
  command! -bang Fd  call fzf#vim#files(ProjectDir(), fzf#vim#with_preview({'source':'rg --files                      --follow'}), <bang>0)
  command! -bang Fda call fzf#vim#files(ProjectDir(), fzf#vim#with_preview({'source':'rg --files --no-ignore --hidden --follow'}), <bang>0)
  command! -nargs=? -bang Rg  CD | call fzf#vim#grep('rg      --column --line-number --no-heading --color=always --smart-case -- '.fzf#shellescape(<q-args>), fzf#vim#with_preview(), <bang>0)
  command! -nargs=? -bang Rga CD | call fzf#vim#grep('rg -uuu --column --line-number --no-heading --color=always --smart-case -- '.fzf#shellescape(<q-args>), fzf#vim#with_preview(), <bang>0)
  command! -bang Fb FzBuffers
  nmap <leader><tab> <plug>(fzf-maps-n)
  xmap <leader><tab> <plug>(fzf-maps-x)
  omap <leader><tab> <plug>(fzf-maps-o)
endif
```

FZF Tips:
- Can I copy selections from fzf.vim window to quickfix window? Yes, type <tab> to select targets and the press <enter>

2. good practice with tags in vim

 - Plug 'ludovicchabant/vim-gutentags'
 - Plug 'skywind3000/gutentags_plus'

Settings:
```vimscript
if isdirectory(PackHome().'/vim-gutentags')
  let g:gutentags_project_root = g:this_project.markers
  let g:gutentags_add_default_project_roots = 0
  let g:gutentags_modules = []
  if executable('ctags')
      let g:gutentags_modules += ['ctags']
  endif
  if executable('gtags') && executable('gtags-cscope')
      let g:gutentags_modules += ['gtags_cscope']
  endif
  let g:gutentags_ctags_tagfile = '.cache/.tags'
  let g:gutentags_gtags_dbpath = '.cache/tags'
  let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
  let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
  let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
  let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']
  let g:gutentags_auto_add_gtags_cscope = 0
  let g:gutentags_define_advanced_commands = 1
  let g:gutentags_plus_switch = 1
endif
```

3. AI plugin

How can I talk with AI via cmdline?

  - [vim9-ollama](https://github.com/greeschenko/vim9-ollama)
  - [vim-ai](https://github.com/madox2/vim-ai)


## Trouble shooting

1. Which one is making vim slow?

- startup slowly? Trace the log with `vim --startuptime vim-startup.log`

- a specific slow action, trace with:

  ```vimscript
  :profile start profile.log
  :profile func *
  :profile file *
  " At this point do slow actions
  :profile pause
  :noautocmd qall!
  ```
> See, [vimscript debugging](https://stackoverflow.com/questions/12213597/how-to-see-which-plugins-are-making-vim-slow)

2. Performance of a function calling? Easy performance testing with reltime() of vimscript

    ```vimscript
    CD
    let g:time_start = reltime()
    call Tst_BarMethod()
    echomsg "Elapsed time: " reltimefloat(reltime(g:time_start)) "seconds."
    ```


3. a lot red block _ (underscore) in my markdown document. **Turn off

 highlighting *_* for the underscore in vim** Refs.:
  - [markdownError](https://stackoverflow.com/questions/19137601/turn-off-highlighting-a-certain-pattern-in-vim)
  - [red block](https://github.com/tpope/vim-markdown/pull/40)

4. Quickly output diagram with plantuml.jar? add custom command:

    ```vimscript
    command! -range Puml exec 'normal! gv"vy' | bo new | setl bt=nofile bh=wipe nobl noswf nu | exec 'normal! "vP' |
          \ exec '%!java -jar '.'/../tools.libs.scripts/tools/plantuml.jar -v -tsvg -pipe > #<-diagram.svg'
    ```

5. How can I print git status of all repos? Traversal of the current directory:
    ```vimscript
    cd /path/to/root/dir
    let subitems = readdir('./')
    for item in subitems
        if isdirectory(item)
            exec 'cd '.item
            Git status
            exec 'cd ../'
        endif
    endfor
    ```
6. Can vim give me spelling suggestions under Insert Mode?

`<tab>s` is a mapping of <CTRL-X>s, see help doc.
help i_CTRL-X_s

7. spell: Misspellings

  - Navigate between spelling mistakes with ]s and [s in Normal Mode.
  - To fix a misspelling, put your cursor over the word and type z= to see a list of suggested replacements

  > Select the First Suggestion
  > You may as well try `1z=` to select the first suggestion.

  > How to repeat fixes? By repeating "z="?
  > If you made a good fix with z=, you can repeat that replacement for all matches of the replaced word in the
  > current window: `:spellrepall` or `:spellr`

  - Teach Vim Words it Doesn’t Know! Put cursor over the word and type zg.

  > To undo this action use zw, which comments out the line in the dictionary file. You can
  > also remove the entry by hand from the spell file (defined by :set spf?).

  " Good practice:
  if &spell
    let &spf = 'path/to/spell.'.&encoding.'.add'
    " Easy to open the word list file
    nnoremap <leader>vz :exec 'vs' &spf<CR>
  endif

8. Quickfix: Using `:cdo` to execute command on every item in quickfix list.

`:cdo s/{pattern}/{replacement} | update` for replacing and saving.

9. Jump with CTRL-o/CTRL-i, which is based on jumplist (see :jumps).

`CTRL-o` jump to an older position, and `CTRL-i`(or <tab>) brings you to a newer position. The mnemonic
would be O = OUT, I = IN => Ctrl-O brings you out, Ctrl-I brings you in. If every jump likes going through
a door, that is. NOTE: set jumpoptions+=stack to use stack-based jumps is better than classic one.

10. Why does vim expand wildcards? I want disable it!

Example, searching content of "%lu", use `:Grep %lu ./` instead of `:Grep %lu`

11. How can I insert invisible keys into the MACRO key sequence?

Press CTRL-V and then press invisible keys to input.

```
CTRL-@ ==>^@==><LF>(new line?)==>(LF?CR?)==>'\n
```

12. How can I switch header file and cpp implementation file quickly?

Example:
```
:e %<.cpp
:e %<.h
:e %:r.h
:e %:r.cpp
```

>
> special modifiers
>
>  % 当前完整的文件名
>  %:h 文件名的头部，即文件目录.例如../path/test.c就会为../path
>  %:t 文件名的尾部.例如../path/test.c就会为test.c
>  %:r 无扩展名的文件名.例如../path/test就会成为test
>  %:e 扩展名

13. How can I open a recently used file?

`:Red ol` and navigate to target file in the list, then type `gf` to open it! And an alternative way is
`:browse ol`, which can list and allows to make a choice in the list file.

14. What's the good practice browsing folder and files of my project?

netrw: netrw重新打开是否可以保持上次打开时候导航到的folder？
不能，但可以使用书签功能。netrw中敲击mb给当前folder设置书签b；下次打开netrw后按gb即可跳转到书签目录。

>**Navigation** (https://vonheikemen.github.io/devlog/tools/using-netrw-vim-builtin-file-explorer/)
> If we want to move between directories and files these are the keymaps we need to know:
>
>  1. Enter: Opens a directory or a file.
>  2. -: Go up to the parent directory.
>  3. u: Go back to the previous directory in the history.
>  4. gb: Jump to the most recent directory saved on the "Bookmarks". To create a bookmark we use mb.
>
> Let's recap. If we want to "go down a directory" we use Enter. To "go up" we use -. To go back, u.
> And if we want to "jump" quickly to a directory of our choosing we should first add it to the bookmarks (using mb) and then we can use gb to go there.
>

15. 为什么GitLog命令通过jobstart输出7万行到buffer(通过setbufline函数)需要53s？同样的脚本回调处理逻辑，为什么nvim输出7万行到buffer不足1s！

实验和比对实现代码，根本原因是vim的channel是按行调用回调函数，nvim的channel是遇到eof或临时缓存满时调用一次回调函数。所以，实验发现同样的业务逻辑和回调数据量，vim中的回调的被调用了7万次，而nvim中被回调7次。
vim repo: src\channel.c (2707)
static void invoke_one_time_callback( channel_T   *channel, cbq_T          *cbhead, cbq_T             *item, typval_T    *argv)
nvim repo: src\nvim\channel.c (730)
void channel_reader_callbacks(Channel *chan, CallbackReader *reader)

