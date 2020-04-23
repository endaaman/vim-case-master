scriptencoding utf-8

if exists('g:loaded_case_master')
  finish
endif
let g:loaded_case_master = 1

command! CaseMasterRotateCase :call case_master#convert(0)
command! CaseMasterConvertToSnake :call case_master#convert('snake')
command! CaseMasterConvertToKebab :call case_master#convert('kebab')
command! CaseMasterConvertToCamel :call case_master#convert('camel')
command! CaseMasterConvertToPascal :call case_master#convert('pascal')
command! CaseMasterConvertToMacro :call case_master#convert('macro')
