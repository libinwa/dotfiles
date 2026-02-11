"/*********************************************************************
"- File name:  _vimrc
"- Description: This is the configuration file for vim
"
"  By copying this file to your `$HOME`, vim will then be configured.
"  Folder 'tools.libs.scripts' 包含更多的沉淀。使用前需设置正确的路径。
"
"- History:
"  2018-03-05 11:56:09 Created, 2025 updated.
"*********************************************************************/

" General Settings {
    set nocompatible         " Must be first line

    " Quote shell if it contains space and is not quoted
    if &shell =~? '^[^"].* .*[^"]'
      let &shell='"' . &shell . '"'
    endif

    let g:mapleader = ' '     " Using space/comma is better than default \
    " Instead of using $MYVIMRC, add 'g:this_vimrc' to avoid path confused.
    let g:this_vimrc = get(g:, 'this_vimrc', resolve(expand('<sfile>:p')))
    silent! function! MyVimrcDir()
      return fnamemodify(g:this_vimrc, ':h')
    endfunction

    filetype on                     " Enable file type detection
    filetype plugin on
    filetype plugin indent on

    set encoding=utf-8              " Character encoding used inside vim.
    scriptencoding utf-8    " when setting 'encoding', scriptencoding must be placed after that.
    set fileencoding=utf-8  " when buffer 'fileencoding' is different from 'encoding', conversion will be done.
    set fileencodings=ucs-bom,utf-8,gbk,gb2312,gb18030,big5,cp936,latin1

    syntax enable                   " Enable syntax highlighting.

    set shortmess+=filmnrxoOatTI    " 保留欢迎界面? set shortmess-=I
    set autoindent                  " Indent at the same level of the previous line
    set autoread                    " 当文件在外部被修改，自动更新该文件
    set backspace=indent,eol,start  " Backspace for dummies
    set expandtab                   " Tabs are spaces, not tabs
    set hidden                      " Allow buffer switching without saving
    set history=1000                " Store a ton of history (default is 20)
    set hlsearch                    " Highlight search terms
    set ignorecase                  " Case insensitive search
    set incsearch                   " `set noincsearch` " 在输入要搜索的文字时，取消实时匹配
    set iskeyword-=#                " '#' is an end of word designator
    set iskeyword-=-                " '-' is an end of word designator
    set iskeyword-=.                " '.' is an end of word designator
    set matchpairs+=<:>             " Match, to be used with %
    set mouse=a                     " Enable mouse usage
    set mousehide                   " Hide the mouse cursor while typing
    set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
    set nowrap                      " no wrap for long line
    set nospell                     " no spell checking
    set number                      " Line numbers on
    "set path+=**                    " 检索file_in_path时递归查找子目录, 递归就会拖慢
    "set relativenumber              " 有时候相对行号很好用
    set shiftwidth=2                " Use indents of 2 spaces
    set showmatch                   " Show matching brackets/parenthesis
    set smartcase                   " For the search pattern contains upper case characters.
    set smartindent                 " Enable smart indent
    set smarttab                    " 指定按一次backspace就删除shiftwidth宽度
    set softtabstop=2               " Let backspace delete indent
    set tabstop=2                   " An indentation every 2 columns
    "set vb t_vb=                    " 关闭提示音
    set viewoptions=folds,options,cursor,unix,slash    " Better Unix / Windows compatibility
    set virtualedit=onemore         " Allow for cursor beyond last character
    set wildmenu                    " Show list instead of just completing
    set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.

    set nofoldenable                " 禁用折叠 `set foldenable` " 启用折叠
    set foldmethod=indent           " indent 折叠方式 `set foldmethod=marker` " marker 折叠方式
    " 常规模式下用空格键来开关光标行所在折叠（注：zR 展开所有折叠，zM 关闭所有折叠）
    nnoremap <space><space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>

    " Enhanced configurations, silently ignored in unsupported versions (harmless)
    silent! set diffopt-=closeoff
    silent! set diffopt+=internal,indent-heuristic,vertical,hiddenoff,followwrap
    silent! set diffopt+=algorithm:patience               " Better algorithm for Vim 8.1+
    silent! set jumpoptions+=stack                        " Better jumplist for Vim 9.0+

    " pastetoggle (sane indentation on pastes)
    silent! set pastetoggle=<F12>
    if has('clipboard')
      silent! set clipboard=unnamed
      silent! set clipboard+=unnamedplus     " When possible use + register for copy-paste
    endif

    " 非可见字符不显示, `set list`可按预定字符(listchars指定)替代显示非可见字符
    set list
    " 设置非可见字符的显示时的可见字符替代方案
    set listchars=tab:›\ ,trail:•,extends:>,precedes:<,nbsp:.
    if &encoding !=? 'utf-8'
      echohl WarningMsg | echomsg 'encoding' &encoding 'might cause invalid listchars display' | echohl NONE
    endif

    " Jumping with tags:
    " A tag is an identifier that appears in "tags" files. "tags" file should be generated by a tool like
    " "ctags -R -c++-kinds=+px -fields=+iaS -extra=+q" before ":tag" and CTRL-] can be used, see ":h tags".
    "
    " The tool of "gtags" (or "cscope") is a tagging system which works the same way across diverse
    " environments. Plugins which integrated the tagging system can be easy to use.
    "
    " 以下设置索引文件名为".tags",以小数点开头更便于识别。后面的分号不要去掉!!
    " 加`;`表示若当前编辑的文件所在目录中不存在".tags"，则在其父目录中查找".tags"直至根目录。
    set tags=./.tags;
    " 缺省索引文件文件 "tags", 放最低优先级
    set tags+=tags

    " Executing grep/vimgrep with ripgrep
    if executable('rg')
      set grepprg=rg\ --vimgrep\ --no-heading\ --follow\ --smart-case
    endif

    "set backup                      " Backups are nice ...
    set nobackup                    " 设置无备份文件
    set writebackup                 " 保存文件前建立备份，保存成功后删除该备份
    set noswapfile                  " 设置无临时文件
    if has('persistent_undo')       " Check and enable persistent_undo
      set undofile                          " Saves undo history to undo file when writing a buffer
      set undolevels=1000                   " Maximum number of changes that can be undone
      set undoreload=10000                  " Maximum number lines to save for undo on a buffer reload
      let uDir = MyVimrcDir().'/.vim/undo'  " Put undofile in the unified directory
      if !isdirectory(uDir) && exists('*mkdir')
        call mkdir(uDir, 'p', 0o700)
      endif
      let &undodir = printf('%s,%s', uDir, &undodir)
    endif
" }


" UI Settings {
    set background=dark             " Set background, toggle between dark and light
    nnoremap <silent> <leader>tb <Cmd>if &bg ==? "dark"<Bar>set bg=light<Bar>else<Bar>set bg=dark<Bar>endif<CR>
    set winminheight=0              " Windows can be 0 line high
    set splitright                  " Puts new vsplit windows to the right of the current
    set splitbelow                  " Puts new split windows to the bottom of the current
    set fillchars=vert:\ ,fold:-    " Sets characters to fill the statuslines and vertical separators.
    "set t_Co=256                    " 8-bit color (256 colors) makes xterm/win32 vim shine
    set termguicolors               " Using guibg/fg attributes in terminal, true color(24-bit color) is required.
    set cursorline                  " Highlight current line
    set scrolljump=5                " Lines to scroll when cursor leaves screen
    set scrolloff=3                 " Minimum screen lines to keep above and below cursor

    set cmdheight=2                 " Set the command line height as 2，default is 1
    if has('cmdline_info')
      set ruler                     " Show the line and column number of the cursor position
      set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)       " a ruler on steroids
      set showcmd    " show command and selected chars/lines in visual mode in the last line
    endif

    if has('statusline')            " Add functions for statusline customizations
      set laststatus=2              " Set status line on
      set noshowmode                " Don't display the current mode
      let g:theModes={'n':'NORMAL', 'v':'VISUAL', 'V':'V·LINE', "\<C-V>":'V·BLOCK',
            \'i':'INSERT', 'R':'REPLACE', 'c':'COMMAND', '!':'SHELL', 't':'TERMINAL'}
      silent function! CurrentMode(m=mode())
        return get(g:theModes, a:m, a:m)
      endfunction
      silent function! FencStr()
        let fencStr = empty(&fenc) ? &enc : &fenc
        let bombStr = (exists('+bomb') && &bomb) ? ' with BOM' : ''
        return fencStr.bombStr
      endfunction
      silent function! BuffersListed()
        return len(getbufinfo({'buflisted':1}))
      endfunction
      silent function! GitBranch()
        return exists('*FugitiveHead')? FugitiveHead() : ''
      endfunction
      " Broken down into includeable segments, settings after %= is for right side
      " Highlight the bottom-right winnr for easy navigation with winnr+ <CTRL-W>w
      set stl=%#User1#\ %{&paste?'PASTE':CurrentMode()}\ %*
      set stl+=%#User2#%{GitBranch()!=#''?'\ '.GitBranch().'\ \|':''}%*
      set stl+=%#User2#\ %{exists('b:stl_title')?b:stl_title:''}%{%{->&bl&&empty(&bt)?'%t':'%f'}()%}\ %*
      set stl+=%#User2#\ %*%#User9#%M%*%#User2#%n/%{BuffersListed()}%R%H%W\ %*
      set stl+=%#User2#%=%{FencStr()},%{&ff}/%{&ft!=#''?&ft:'no\ ft'}\ %*
      set stl+=%#User2#\ %-19(%l/%L,%02c%03V\ %P\ %)%O'%02b'%*
      set stl+=%#User3#\ %{winnr()}\ %*
    endif

    " Customizations of highlight
    silent function! SetHighlights()
      " highlight groups for StatusLine
      hi! User1 ctermbg=24 guibg=#264F78 ctermfg=255 guifg=#FFFFFF
      hi! User2 ctermbg=NONE guibg=NONE
      hi! User3 ctermbg=70 ctermfg=255 guibg=#6A9955 guifg=#FFFFFF
      hi! User9 ctermfg=210 guifg=#FF9F64
      if ( 0 )  " 0 is for disable transparent, using 1 to enable it
        hi! Normal  guibg=NONE ctermbg=NONE
        hi! LineNr  guibg=NONE ctermbg=NONE
        hi! NonText guibg=NONE ctermbg=NONE
        hi! EndOfBuffer guibg=NONE ctermbg=NONE
      endif
    endfunction

    " Group of autocommands for UI settings
    augroup setUi
      autocmd!
      autocmd GUIEnter * if has('win32') || has('win64') | simalt ~x | endif   " 窗口启动时自动最大化
      autocmd VimEnter,ColorScheme * call SetHighlights()   " 自定义 highlight groups
      " Toggle line width 启用每行超过某一字符总数后给予字符变化提示（字体变蓝加下划线）
      autocmd BufWinEnter * if exists('w:line_width') && w:line_width
            \|   let w:m2 = matchadd('Underlined', printf('\%%>%dv.\+', 120), -1)
            \| elseif exists('w:m2') && w:m2 != -1
            \|   call matchdelete(w:m2) | let w:m2 = -1
            \| endif
      nnoremap <silent><leader>lw :let w:line_width = !(exists('w:line_width') && w:line_width)<CR>
            \:doautocmd setUi BufWinEnter<CR>
    augroup END

    if has('gui_running')
      winpos 100 10                     " 指定窗口出现的位置，坐标原点在屏幕左上角
      set lines=40 | set columns=120    " 指定窗口大小，lines为高度，columns为宽度
      if ( has('unix')&&!has('macunix')&&!has('win32unix') ) | set guifont=Inconsolata\ 12 | endif
      if ( has('macunix') ) | set guifont=Inconsolata:h12 | endif
      if ( has('win32') || has('win64') ) | set guifont=Consolas:h10,Inconsolata:h12 | endif
      " 显示/隐藏菜单栏、工具栏、滚动条，可用 <C-F11> 切换
      set guioptions-=m | set guioptions-=T | set guioptions-=r | set guioptions-=L
      nnoremap <silent> <C-F11> :if &guioptions =~# 'm' <Bar>
            \  set guioptions-=m <Bar> set go-=T <Bar> set go-=r <Bar> set go-=L <Bar>
            \else <Bar>
            \  set guioptions+=m <Bar> set go+=T <Bar> set go+=r <Bar> set go+=L <Bar>
            \endif<CR>
    endif
" }


" Functional {
    " Twice the Result with Half the Effort {
        function! StripTrailingWhitespaceTrimming(begin, end)
          " Preparation: save last search/cursor position.
          let _s=@/
          let l = line(".")
          let c = col(".")
          " do the business:  %s/\s\+$//e
          silent! exec printf("%d,%ds/\\s\\+$//e", a:begin, a:end)
          " clean up: restore previous search history, and cursor position
          let @/=_s
          call cursor(l, c)
        endfunction
        command! -range=% -nargs=0 Trim call StripTrailingWhitespaceTrimming(<line1>, <line2>)

        function! ClangFormat(begin, end)
          let pys = fnamemodify(exepath('clang-format'), ':p:h').'/../share/clang/clang-format.py'
          if filereadable(pys)
            let lines = a:begin.':'.a:end
            if has('python') | exec 'pyf '.pys | elseif has('python3') | exec 'py3f '.pys | endif
          endif
        endfunction
        command! -range=% -nargs=0 Cfmt call ClangFormat(<line1>, <line2>)

        function! Ripgrep(...)
          exec 'Quick rg --vimgrep --no-heading --follow  --smart-case' join(a:000, ' ')
        endfunction
        command! -bang -nargs=* -complete=dir Grep call Ripgrep((<bang>0?'':'--max-depth=4'), <f-args>)
        command!       -nargs=* -complete=dir Grepa call Ripgrep('-uuu', <f-args>)

        " Find files with ripgrep
        function! FindFiles(cmdopt_rgfiles, cmdopt_pattern='', cmdopt_path='', ...)
          " &shell is required, because of pipe was used.
          let cli = printf('%s %s "rg --files %s %s %s %s"', &shell, &shellcmdflag, a:cmdopt_rgfiles,
                \join(a:000, ' '), (a:cmdopt_path!=''? shellescape(a:cmdopt_path) : ''),
                \(a:cmdopt_pattern!=''?
                \' | rg --no-heading --smart-case --sort path '.shellescape(a:cmdopt_pattern) : ''))
          call JobStart(cli, cli, getcwd(), function('SetQfList', [{'efm':'%f'}]))
        endfunction
        command! -bang -nargs=* -complete=dir Find call FindFiles((<bang>0?'':'--max-depth=4'), <f-args>)
        command!       -nargs=* -complete=dir Finda call FindFiles('--no-ignore --hidden', <f-args>)

        function! Redirect(...)
          let cmd = join(a:000, ' ')
          let temp_reg = @"
          redir @"
          silent! execute cmd
          redir END
          let output = copy(@")
          let @" = temp_reg
          if empty(output)
            echo "---========== no output ==========---"
          else
            new
            syntax clear
            setlocal modifiable bt=nofile bh=wipe nobl noswf nowrap nospell nolist nu nornu
            nnoremap <silent><buffer> q :q!<CR>
            put! = output
            call append('$', "---")
            call append('$', "Press 'q' to quit this buffer.")
          endif
        endfunction
        command! -nargs=+ -complete=command Red call Redirect(<f-args>)

        " Toggle Quickfix window of the current tab page
        function! ToggleQuickfix()
          for win in range(1, winnr('$'))
            let wininfo = getwininfo(win_getid(win))
            if !empty(wininfo) && wininfo[0].quickfix && !wininfo[0].loclist
              cclose
              return
            endif
          endfor
          copen
        endfunction
        nnoremap <silent> Q :call ToggleQuickfix()<CR>

        " Wipe out the hidden or unloaded (after `:bdelete`) buffers
        function! Bwipeout(all) abort
          let buffers = filter(getbufinfo(), {_, v -> !v.loaded || v.hidden})
          if !empty(buffers)
            execute a:all? 'bwipeout!':'bwipeout' join(map(buffers, {_, v -> v.bufnr}))
          endif
        endfunction
        command! -bar -bang Bw call setqflist([], 'f') | call Bwipeout(<bang>0)
    " }

    " For the Projects {
        silent function! ProjectDir(seek=0, path='')
          let g:this_project = get(g:, 'this_project', {'path':'',
                \'markers': ['.git', '.svn', '.vs', '.vscode', '.editorconfig']})
          if !empty(a:path)
            let g:this_project.path = trim(fnamemodify(expand(a:path), ':p'))
          endif
          if a:seek || empty(g:this_project.path)
            let name = trim(fnamemodify(bufname(), ':p'))
            let g:this_project.path = trim(fnamemodify(name, ':h'))
            let finding = ''
            for marker in g:this_project.markers     " iterate all markers
              " search as a file
              let x = findfile(marker, name . '/;')   " Upward search
              let x = (x == '')? '' : fnamemodify(x, ':p:h')
              " search as a directory
              let y = finddir(marker, name . '/;')
              let y = (y == '')? '' : fnamemodify(y, ':p:h:h')
              " which one is the nearest directory ?
              let z = (strchars(x) > strchars(y))? x : y
              " keep the nearest one in finding
              let finding = (strchars(z) > strchars(finding))? z : finding
            endfor
            if finding != ''
              let g:this_project.path = trim(fnamemodify(finding, ':p'))
            endif
          endif
          return g:this_project.path
        endfunction

        " Return the project root directory name as the project name.
        silent function! ProjectName()
          return trim(fnamemodify(ProjectDir(), ':h:t'))
        endfunction
        command! -bar -bang -nargs=? -complete=dir CD  exec 'cd '.ProjectDir(<bang>0, <q-args>) | echo ProjectDir()
    " }

    " Job control {
        silent function! JobCallback(jid, cwd, cb, event, channel, data, streamname='')
          if !empty(a:cb) && type(a:cb) ==? type(function("tr"))
            call a:cb(a:jid, a:cwd, a:event, a:channel, a:data)
          else
            let l:job = a:channel | if exists('*ch_getjob') | let l:job = ch_getjob(a:channel) | endif
            let l:buf = bufnr(a:jid.'$') | let l:wid = bufwinid(l:buf)
            if l:wid == -1
              silent execute 'new '.a:jid | silent execute 'cd '.a:cwd | syntax clear
              setlocal modifiable bt=nofile bh=wipe nobl noswf nowrap nospell nolist nu nornu
              let l:buf = bufnr() | let l:wid = bufwinid(l:buf) | let b:ss = 0   " Hold job and scrolling switch
              nnoremap <silent><buffer><leader>ss :let b:ss = (b:ss != 0)? 0 : 1<CR>
              if exists('*job_stop') | nnoremap <silent><buffer><leader>k :call job_stop(b:job, 'kill')<CR> | endif
              if exists('*jobstop') | nnoremap <silent><buffer><leader>k :call jobstop(b:job)<CR> | endif
            endif
            if !empty(a:data) | call setbufvar(l:buf, '&ma', 1) | call setbufline(l:buf, line('$')+1, a:data) | endif
            call setbufvar(l:buf, 'job', l:job) | call setbufvar(l:buf, '&mod', 0) | call setbufvar(l:buf, '&ma', 0)
            if getbufvar(l:buf, 'ss') != 0 | call win_gotoid(l:wid) | call cursor('$', 0) | endif
            if a:event ==? 'exit'
              let l:stl_title = getbufvar(l:buf, 'stl_title') | call setbufvar(l:buf, 'stl_title', '*'.l:stl_title)
            endif
          endif
        endfunction

        " Usage: JobStart(jid, cmd, [cwd], [callback])
        silent function! JobStart(jid, cmd, cwd=getcwd(), callback={})
          let jid = substitute(strpart(a:jid, 0, 64), '\W', '-', 'g')
          if exists('*job_start') && exists('*job_status')
            let job = job_start(a:cmd, { 'out_cb':  function('JobCallback', [jid, a:cwd, a:callback, 'stdout']),
                  \                      'err_cb':  function('JobCallback', [jid, a:cwd, a:callback, 'stderr']),
                  \                      'exit_cb': function('JobCallback', [jid, a:cwd, a:callback, 'exit']),
                  \                      'mode': 'nl',
                  \                      'cwd': a:cwd })
            if job_status(job) !=? 'run'
              echohl ErrorMsg | echomsg 'Failed to start (jobinfo:' job_info(job) '):' a:cmd | echohl NONE
            else
              echomsg 'Successfully started (jobinfo:' job '):' a:cmd
              call JobCallback(jid, a:cwd, a:callback, 'init', job_getchannel(job), '')
            endif
          elseif exists('*jobstart')
            let job = jobstart(a:cmd, { 'on_stdout': function('JobCallback', [jid, a:cwd, a:callback, 'stdout']),
                  \                     'on_stderr': function('JobCallback', [jid, a:cwd, a:callback, 'stderr']),
                  \                     'on_exit':   function('JobCallback', [jid, a:cwd, a:callback, 'exit']),
                  \                     'cwd': a:cwd })
            if job <= 0
              echohl ErrorMsg | echomsg 'Failed to start (errcode:' job '):' a:cmd | echohl NONE
            else
              echomsg 'Successfully started:' a:cmd
              call JobCallback(jid, a:cwd, a:callback, 'init', job, '')
            endif
          else
              echohl ErrorMsg | echomsg 'Job API is not available, VIM:' v:progpath | echohl NONE
          endif
        endfunction
        command! -nargs=+ -complete=file_in_path Start call JobStart(<q-args>, <q-args>)

        " Output data to QuickFix list
        silent function! SetQfList(qfopts, jid, cwd, event, channel, data)
          let l:qfbufnr = getqflist({'qfbufnr':0}).qfbufnr | let l:job = getbufvar(l:qfbufnr, 'job')
          if a:event ==? 'init'
            if type(l:job) ==? type({}) && has_key(l:job, a:jid)
              silent exec 'cd '.a:cwd | cclose | copen
              call setqflist([], 'a', {'id': l:job[a:jid].id, 'title': a:jid}->extend(a:qfopts))
              silent exec getqflist({'id': l:job[a:jid].id, 'nr':0}).nr.'chistory'
            else
              silent exec 'cd '.a:cwd | copen
              call setqflist([], ' ', {'nr':'$', 'title': a:jid, 'lines':[]}->extend(a:qfopts))
              if exists('*job_stop')
                nnoremap <silent><buffer><leader>k :call job_stop(ch_getjob(b:job[getqflist({'id':0}).id].chn),'kill')<CR>
              endif
              if exists('*jobstop')
                nnoremap <silent><buffer><leader>k :call jobstop(b:job[getqflist({'id':0}).id].chn)<CR>
              endif
            endif
            let l:qflstid = getqflist({'id':0}).id | let l:m = {l:qflstid : {'chn': a:channel}, a:jid : {'id': l:qflstid}}
            call setbufvar(getqflist({'qfbufnr':0}).qfbufnr, 'job', (type(l:job) != type({})? l:m : extend(l:job, l:m)))
          else
            if type(l:job) ==? type({}) && has_key(l:job, a:jid)
              if a:event ==? 'exit'
                cclose | call setqflist([], 'a', {'id': l:job[a:jid].id, 'title': '*'.a:jid}) | copen
              else
                let lines = a:data | if type(a:data) != type([]) | let lines = [a:data] | endif
                call setqflist([], 'a', {'id': l:job[a:jid].id, 'lines': lines}->extend(a:qfopts))
              endif
            endif
          endif
        endfunction
        command! -nargs=+ -complete=file_in_path Quick call JobStart(<q-args>, <q-args>, getcwd(), function('SetQfList', [{}]))
    " }
" }


" Key Mappings / Commands / Autocmds {
    inoremap jk <ESC>
    nnoremap <BS> :noh<CR>
    " 注：在常规模式下，按<leader>键再按c键再按M键（无须同时，允许按键间隔一秒）可清除行尾 ^M 符号
    nnoremap <leader>cM :%s/\r$//g<CR>:noh<CR>
    " 重读/在新的分屏中打开我的 ~/.vimrc 文件，命令（:vsplit $MYVIMRC<CR> 和 :source $MYVIMRC<CR>）
    nnoremap <leader>ve :exec 'vsplit '.g:this_vimrc<CR>
    nnoremap <leader>sv :exec 'source '.g:this_vimrc<CR>
    " Insert current time at the cursor position
    inoremap <silent> <C-D> <C-R>=strftime('%Y-%m-%d %H:%M:%S')<CR>
    " To insert expr result, put expr into the register first!
    inoremap <silent> <C-E> <C-R>=eval(@")<CR>
    inoremap <Tab>f <C-X><C-F>|inoremap <Tab>o <C-X><C-O>
    inoremap <Tab>l <C-X><C-L>|inoremap <Tab>s <C-X>s
    inoremap <Tab>n <C-X><C-N>|inoremap <Tab>p <C-X><C-P>
    inoremap <Tab>v <C-X><C-V>|inoremap <Tab>] <C-X><C-]>
    if !has('nvim') && has('terminal')
      nnoremap <leader>` <Cmd>terminal ++curwin<CR>
      set termwinkey=<C-L>
      tnoremap <C-L>p <Cmd>tabprevious<CR>
    else
      nnoremap <leader>` <Cmd>terminal<CR><Cmd>startinsert<CR>
      tnoremap <C-L> <C-\>
      tnoremap <C-L>N <C-\><C-N>
    endif
    " Hotkey CTRL-W is not as convenient as key mapping.
    nnoremap <leader>w <C-W>
    nnoremap <leader>q <Cmd>bdelete<CR>
    nnoremap <leader>p <Cmd>bprevious<CR>
    nnoremap <leader>n <Cmd>bnext<CR>
    nnoremap <leader>o <Cmd>b#<CR>
    nnoremap <leader>b <Cmd>Red ls<CR>
    nnoremap <leader>x <Cmd>Lexplore<CR>
    nnoremap <leader>X :Lexplore<space><space>
    nnoremap <leader>g <Cmd>Grep! <cword> .<CR>
    nnoremap <leader>f <Cmd>Find! <cword><CR>
    nnoremap <leader>G :Grep!<space><space>
    nnoremap <leader>F :Find!<space><space>
    nnoremap <leader>S :Start<space><space>
    nnoremap <leader>Q :Quick<space><space>
    nnoremap <leader>M <Cmd>Red message<CR>
    nnoremap <leader>ts <Cmd>tab split<CR>
    nnoremap <leader>tn <Cmd>tabnext<CR>
    nnoremap <leader>tp <Cmd>tabprevious<CR>
    " Toggle boolean option, inverse the option of nowrap/nospell/nolist/nopaste
    nnoremap <silent> <leader>iw <Cmd>set wrap!<CR><Cmd>set wrap?<CR>
    nnoremap <silent> <leader>is <Cmd>set spell!<CR><Cmd>set spell?<CR>
    nnoremap <silent> <leader>il <Cmd>set list!<CR><Cmd>set list?<CR>
    nnoremap <silent> <leader>ip <Cmd>set paste!<CR><Cmd>set paste?<CR>
    nnoremap <silent> [q <Cmd>cprev<CR> | nnoremap <silent> ]q <Cmd>cnext<CR>
    nnoremap <silent> [w <Cmd>lprev<CR> | nnoremap <silent> ]w <Cmd>lnext<CR>
    nnoremap <expr> <C-H> '<C-W><'.v:count1 | nnoremap <expr> <C-L> '<C-W>>'.v:count1
    nnoremap <expr> <C-J> '<C-W>+'.v:count1 | nnoremap <expr> <C-K> '<C-W>-'.v:count1
    " Create stmt to get the key sequence which is a MACRO in the target register (example w).
    " After recording a macro with w, typing "w<leader>mm can create stmt to get this macro.
    " In future, you can get this macro by executing this stmt, and execute macro with @w
    nnoremap <leader>mm :<C-U><C-R><C-R>='let @'. v:register .' = '. string(getreg(v:register))<CR><C-F><LEFT>
    nnoremap <leader>ll :let @*=expand('%:p:.').' ('.line('.').')'<CR>:echo '-=Relative Postion Copied=-'<CR>
    nnoremap <leader>cd <Cmd>cd %:p:h<CR><Cmd>pwd<CR> | nnoremap <leader>vd <Cmd>echo expand('%:p:h')<CR>
    nnoremap <leader>ed :edit <cfile><CR> | vnoremap <leader>ed "vy:exec 'edit' @v<CR>
    nnoremap <leader>gb <Cmd>exec 'buffer' expand('<cWORD>')<CR>
    nnoremap <leader>vc :execute 'vsplit' ProjectDir().'/comments.md'<CR>
    nnoremap <leader>vs :exec 'vsplit' MyVimrcDir().'/../tools.libs.scripts/snippets.md'<CR>   " 选中沉淀，Run或<space><enter>
    let &spf = MyVimrcDir().'/../tools.libs.scripts/scripts/spell.'.&encoding.'.add' | nnoremap <leader>vz :exec 'vs' &spf<CR>
    " Execute the visual selection as a shell command
    vnoremap <space><enter> "vy:bo new<CR>:setl bt=nofile bh=wipe nobl noswf nolist nu nornu<CR>"vP:exec '%!'.&shell<CR>
    " Start program or open a document/URL with default program, which is alternative to command gx.
    vnoremap <leader>W "vy:execute '!start' @v<CR> | nnoremap <leader>W :!start<space><space>
    " Run vimscript lines or line ranges.
    command! -range Run let lines=getline(<line1>,<line2>) | call execute(lines,'') | echo len(lines).' lines executed.'
    command! -bang -nargs=* Recent Red filter<bang> /<args>/ oldfiles    " Usage: Recent pattern
    command! -range=% -nargs=* GitLog
          \ exec 'Start git --no-pager log -L '.<line1>.','.<line2>.':'.expand('%:p:.').' '.<q-args>
    command! -range=% -nargs=* GitBlame
          \ exec 'Start git --no-pager blame -L '.<line1>.','.<line2>.' -- '.expand('%:p:.').' '.<q-args>
    command! -range -nargs=+ Fmt <line1>,<line2>s/\%V\w\+/\=printf(<q-args>, submatch(0))/g | noh  " Usage: Fmt %#x  Fmt %#d ...

    " Group of autocommands
    augroup VimRcAUs
      autocmd!
      autocmd VimEnter * if &buftype !=? 'terminal' && bufname() !~ "^\[A-Za-z0-9\]*://" | call ProjectDir() | endif
      " Restore cursor to file position in previous editing session.
      autocmd BufWinEnter * if line("'\"") <= line("$") | silent! normal! g`" | endif
      " Instead of reverting cursor to the last position, set it to the first line when editing git commit message
      autocmd FileType gitcommit autocmd BufWinEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
      " For reading content of quickfix again (<leader>u), setting errorformat tells vim how to read its own quickfix list
      autocmd FileType qf setl nobl nowrap nospell nolist nu nornu stl<
            \| setl errorformat=%f\|%l\ col\ %c\|%m
            \| nnoremap <buffer> K :cprev<CR>zz<C-W>p | nnoremap <buffer> J :cnext<CR>zz<C-W>p
            \| nnoremap <buffer> <leader>m :if &modifiable<Bar>setl noma nomod<Bar>else<Bar>setl ma<Bar>endif<CR>
            \| nnoremap <buffer> <leader>u :cgetbuffer<CR>:cclose<CR>:copen<CR>
            \| nnoremap <buffer> <leader>r :cdo s/// \| update<C-Left><C-Left><Left><Left><Left>
            \| nnoremap <buffer> <leader>q <Cmd>call setqflist([], 'f')<CR><Cmd>bdelete<CR>
            \| nnoremap <buffer><silent><leader>n <Cmd>cnewer<CR> | nnoremap <buffer><silent><leader>p <Cmd>colder<CR>
            \| if exists('w:quickfix_title') | let b:stl_title=w:quickfix_title | endif
    augroup END
" }


" For Plugins {
    silent function! PackHome()
      return MyVimrcDir().'/.vim/plugged'
    endfunction
    " For scanning plugins under `pack/*/start` or `pack/*/opt` in packages home directory,
    " add packages home directory to the search path.
    let &packpath = printf('%s,%s', &packpath, PackHome())
    if !isdirectory(PackHome()) && exists('*mkdir')
      call mkdir(PackHome(), 'p')
    endif
    " Plugins under `pack/*/opt` are not loaded; It is recommended to use `packadd` commands
    " in specific script file to run command. The following lines allows easy access.
    function! PluginRcfile()
      return MyVimrcDir().'/../tools.libs.scripts/vim-plugins.vim'
    endfunction
    nnoremap <leader>vp :execute 'vsplit' PluginRcfile()<CR>
    if filereadable(PluginRcfile())
      execute 'source '.PluginRcfile()
    endif

    " Furthermore, manage plugins with junegunn/vim-plug. Call this function.
    silent function! CallVimPlugMgr()
      let uri = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
      call JobStart('downloading vim-plug', 'curl -vLs -o '.PackHome().'/plug.vim '.uri, PackHome())
      if !filereadable(PluginRcfile())
        let tmplst = [ 'exec ''source ''.PackHome().''/plug.vim''',
              \ 'call plug#begin(PackHome())',
              \ 'Plug ''tpope/vim-fugitive''',
              \ 'Plug ''yegappan/lsp''',
              \ 'call plug#end()',
              \ '" INITIALIZATION OF PLUGINs']
        call writefile(tmplst, PluginRcfile(), 'b')
      endif
    endfunction
    command! -nargs=0 -bar CallVimPlug call CallVimPlugMgr() | echo 'done.'
" }
