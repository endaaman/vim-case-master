scriptencoding utf-8

if !exists('g:loaded_case_master')
  finish
endif
let g:loaded_case_master = 1

let g:case_master#verbose = get(g:, 'case_master_verbose', v:true)
let g:case_master#splitter = get(g:, 'case_master_splitter', '[^a-zA-Z0-9-_]')

let s:case_snake = 'snake'
let s:case_kebab = 'kebab'
let s:case_camel = 'camel'
let s:case_pascal = 'pascal'
let s:case_orders = [s:case_snake, s:case_kebab, s:case_camel, s:case_pascal]

let s:labels = {}
let s:labels[s:case_snake] = 'snake_case'
let s:labels[s:case_kebab] = 'kebab-case'
let s:labels[s:case_camel] = 'camelCase'
let s:labels[s:case_pascal] = 'PascalCase'

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
    return s:case_snake
  endif
  return a:chunk[0] =~# '\u' ?  s:case_pascal : s:case_camel
endfunction

function! s:split_by_case(chunk) abort
  let l:a = split(a:chunk, '\u\@=')
  let l:b = []
  for l:w in l:a
    let l:b += split(l:w, '_')
  endfor
  let l:c = []
  for l:w in l:b
    let l:c += split(l:w, '-')
  endfor
  return l:c
endfunction

function! s:get_chunk_pos() abort
  let l:x = col('.')
  let l:line = getline('.')
  if l:line[l:x - 1] =~# g:case_master#splitter
    return [l:x - 1, l:x]
  endif
  let l:start = l:x - 1
  while l:start > 1
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
  return tolower(join(s:split_by_case(a:chunk), '_'))
endfunction

function! s:converters[s:case_kebab](chunk) abort
  return tolower(join(s:split_by_case(a:chunk), '-'))
endfunction

function! s:convert_capival(chunk, camel) abort
  let l:words = s:split_by_case(a:chunk)
  let l:first = v:true
  let l:ret = ''
  for l:word in l:words
    if a:camel && l:first
      let l:ret .= tolower(l:word)
    else
      let l:ret .= toupper(l:word[0]) . tolower(l:word[1:])
    endif
    let l:first = v:false
  endfor
  return l:ret
endfunction

function! s:converters[s:case_camel](chunk) abort
  return s:convert_capival(a:chunk, v:true)
endfunction

function! s:converters[s:case_pascal](chunk) abort
  return s:convert_capival(a:chunk, v:false)
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
  let l:pos = s:get_chunk_pos()
  if l:pos[1] - l:pos[0] < 2
    return
  endif
  let l:line = getline('.')
  let l:chunk = strpart(l:line, l:pos[0], l:pos[1] - l:pos[0])
  let l:current_case = s:detect_case(l:chunk)
  if empty(a:case) && match(s:case_orders, a:case)
    let l:case = s:get_next_case(l:current_case)
  else
    let l:case = a:case
  endif
  let l:replacer = s:converters[l:case](l:chunk)
  call s:log(s:labels[l:current_case] . ' -> ' . s:labels[l:case])
  let l:pre = strpart(l:line, 0, l:pos[0])
  let l:post = strpart(l:line, l:pos[1], len(l:line))
  let l:end = l:pos[0] + len(l:replacer)
  if l:end < col('.')
    call cursor(line('.'), l:end)
  endif
  call setline('.', l:pre . l:replacer . l:post)
endfunction
