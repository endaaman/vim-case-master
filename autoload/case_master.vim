scriptencoding utf-8

if !exists('g:loaded_case_master')
  finish
endif
let g:loaded_case_master = 1

let g:case_master#verbose = get(g:, 'case_master_verbose', 1)
let g:case_master#splitter = get(g:, 'case_master_splitter', '[^a-zA-Z0-9-_]')

let s:case_snake = 'snake'
let s:case_kebab = 'kebab'
let s:case_camel = 'camel'
let s:case_pascal = 'pascal'
let s:case_macro = 'macro'
let s:case_orders = [s:case_snake, s:case_kebab, s:case_camel, s:case_pascal, s:case_macro]

let s:labels = {}
let s:labels[s:case_snake] = 'snake_case'
let s:labels[s:case_kebab] = 'kebab-case'
let s:labels[s:case_camel] = 'camelCase'
let s:labels[s:case_pascal] = 'PascalCase'
let s:labels[s:case_macro] = 'MACRO_CASE'

let s:converters = {}


function! s:log(message) abort
  if g:case_master#verbose
    echo '[CaseMaster] ' . a:message
  endif
endfunction

function! s:detect_case(chunk) abort
  if !empty(matchstr(a:chunk, '-'))
    return s:case_kebab
  endif
  if !empty(matchstr(a:chunk, '_'))
    if a:chunk =~# '^[A-Z_]*$'
      return s:case_macro
    endif
    return s:case_snake
  endif
  if a:chunk =~# '^[A-Z]*$'
    return s:case_macro
  endif
  if a:chunk[0] =~# '\u'
    return s:case_pascal
  endif
  return s:case_camel
endfunction

function! s:universal_split(chunk) abort
  let l:tmp1 = split(a:chunk, '_')

  let l:tmp2 = []
  for l:v in l:tmp1
    let l:tmp2 += split(l:v, '-')
  endfor

  let l:tmp3 = []
  for l:v in l:tmp2
    if l:v =~# '^[^a-z]*$'
      call add(l:tmp3, l:v)
      continue
    endif
    let l:tmp3 += split(l:v, '\u\@=')
  endfor
  return l:tmp3
endfunction

function! s:get_chunk_pos(line, cursor_position) abort
  let l:x = a:cursor_position
  let l:line = a:line
  if l:line[l:x - 1] =~# g:case_master#splitter
    return [l:x - 1, l:x]
  endif
  let l:start = l:x - 1
  while l:start > 0
    if l:line[l:start - 1] =~# g:case_master#splitter
      break
    endif
    let l:start -= 1
  endwhile
  let l:end = l:x - 1
  while l:end < len(l:line)
    if l:line[l:end] =~# g:case_master#splitter
      break
    endif
    let l:end += 1
  endwhile
  return [l:start, l:end]
endfunction

function! s:converters[s:case_snake](chunk) abort
  return tolower(join(s:universal_split(a:chunk), '_'))
endfunction

function! s:converters[s:case_macro](chunk) abort
  return toupper(join(s:universal_split(a:chunk), '_'))
endfunction

function! s:converters[s:case_kebab](chunk) abort
  return tolower(join(s:universal_split(a:chunk), '-'))
endfunction

function! s:convert_to_camel(chunk, first_upper) abort
  let l:words = s:universal_split(a:chunk)
  let l:first = 1
  let l:ret = ''
  for l:word in l:words
    if l:first && !a:first_upper
      let l:ret .= tolower(l:word)
    else
      let l:ret .= toupper(l:word[0]) . tolower(l:word[1:])
    endif
    let l:first = 0
  endfor
  return l:ret
endfunction

function! s:converters[s:case_camel](chunk) abort
  return s:convert_to_camel(a:chunk, 0)
endfunction

function! s:converters[s:case_pascal](chunk) abort
  return s:convert_to_camel(a:chunk, 1)
endfunction

function! s:get_next_case(current) abort
  let l:current_index = match(s:case_orders, a:current)
  let l:next_index = l:current_index + 1
  if len(s:case_orders) - 1 < l:next_index
    let l:next_index = 0
  endif
  return s:case_orders[l:next_index]
endfunction

function! case_master#convert(case) abort
  let l:line = getline('.')
  let l:pos = s:get_chunk_pos(l:line, col('.'))
  if l:pos[1] - l:pos[0] < 2
    return
  endif
  let l:chunk = strpart(l:line, l:pos[0], l:pos[1] - l:pos[0])

  let l:current_case = s:detect_case(l:chunk)
  if empty(a:case) && match(s:case_orders, a:case)
    let l:case = s:get_next_case(l:current_case)
  else
    let l:case = a:case
  endif
  let l:replacer = s:converters[l:case](l:chunk)

  let l:pre = strpart(l:line, 0, l:pos[0])
  let l:post = strpart(l:line, l:pos[1], len(l:line))
  let l:end = l:pos[0] + len(l:replacer)
  if l:end < col('.')
    call cursor(line('.'), l:end)
  endif
  call setline('.', l:pre . l:replacer . l:post)

  call s:log(s:labels[l:current_case] . ' -> ' . s:labels[l:case])
endfunction

function! case_master#convert_visual(case) abort
  if visualmode() != 'v'
    return
  endif
  let [l:row_start, l:start] = getpos("'<")[1:2]
  let [l:row_end, l:end] = getpos("'>")[1:2]
  let l:lines = getline(row_start, row_end)
  if l:row_start != l:row_end
    call s:log('The selection contains multiple lines.')
    normal! gv
    return
  endif
  if len(l:lines) != 1
    call s:log('The selection is empty.')
    return
  endif
  let l:row = l:row_start
  let l:line = l:lines[0]
  let l:chunk = strpart(l:line, l:start - 1, l:end - l:start + 1)
  if l:chunk =~# g:case_master#splitter
    call s:log('The selection contains multiple word-chunks.')
    normal! gv
    return
  endif

  let l:current_case = s:detect_case(l:chunk)
  if empty(a:case) && match(s:case_orders, a:case)
    let l:case = s:get_next_case(l:current_case)
  else
    let l:case = a:case
  endif
  let l:replacer = s:converters[l:case](l:chunk)

  let l:pre = strpart(l:line, 0, l:start - 1)
  let l:post = strpart(l:line, l:end, len(l:line))
  call setline(l:row, l:pre . l:replacer . l:post)

  " restore selection
  call setpos('.', [0, l:row, l:start])
  normal! v
  call setpos('.', [0, l:row, l:start + len(l:replacer) - 1])
  call s:log(s:labels[l:current_case] . ' -> ' . s:labels[l:case])
endfunction
