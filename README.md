# vim-case-master

`vim-case-master` provides commands to convert case of words.

## Installation

Use a package manager and follow its instructions. For example

```
Plug 'endaaman/vim-case-master'
```

## Usage

```
hoge_fuga_piyo
            ^
```

Executing `:CaseMasterRotateCase`, the text will converted as below (`^` shows your caret position).

```
hoge-fuga-piyo
            ^
```

You got `kebab-case`. If you execute `:CaseMasterRotateCase` again then

```
hogeFugaPiyo
           ^
```

You got `camelCase`. And if you execute `:CaseMasterRotateCase` again then

```
HogeFugaPiyo
           ^
```

You got `PascalCase`. And do again,

```
HOGE_FUGA_PIYO
           ^
```

You got `MACRO_CASE`. And do more again,

```
hoge_fuga_piyo
           ^
```

You are back to snake_case.


## Options

```vim
" Suppress logs when converting
let g:case_master_verbose = 0   " Default: 1
```

## Commands

| Command | Description |
|:---|---|
| `:CaseMasterRotateCase` | Rotate case `snake_case` → `kebab-case` → `camelCase` → `PascalCase` → `MACRO_CASE` → … |
| `:CaseMasterConvertToSnake` | Convert into `snake_case` |
| `:CaseMasterConvertToKebab` | Convert into `kebab-case` |
| `:CaseMasterConvertToCamel` | Convert into `camelCase` |
| `:CaseMasterConvertToPascal` | Convert into `PascalCase` |
| `:CaseMasterConvertToMacro` | Convert into `MACRO_CASE` |
| `:CaseMasterRoateVisual` | Rotate case when visual mode. |

## Example

```vim
nnoremap <silent> <C-e> :<C-u>CaseMasterRotateCase<CR>
vnoremap <silent> <C-e> :<C-u>CaseMasterRotateCaseVisual<CR>
```
