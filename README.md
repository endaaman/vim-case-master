# vim-case-master

`vim-case-master` provides functions to convert your cases.

## Installation

Use a package manager and follow its instructions. For example

```
Plug 'endaaman/vim-case-master'
```

## Usage

```
Vim is a highly_configurable_text_editor for efficiently
                                      ^
```

If you exec `:CaseMasterRotateCase` when your caret is on the `^`, the text will converted as below.

```
Vim is a highly-configurable-text-editor for efficiently
                                      ^
```

If you continue to execute `:CaseMasterRotateCase`

```
Vim is a highlyConfigurableTextEditor for efficiently
                                    ^
```

If you execute further

```
Vim is a HighlyConfigurableTextEditor for efficiently
                                    ^
```

And more

```
Vim is a highly_configurable_text_editor for efficiently
                                    ^
```

## Options

```vim
let g:case_master_verbose = 0   " Suppress logs when converting
```

## Commands

| Command | Description |
|:---|---|
| `:CaseMasterRotateCase` | Rotate case `snake_case` → `kebab-case` → `camelCase` → `PascalCase` → `snake_case` |
| `:CaseMasterConvertToSnake` | Convert into `snake_case` |
| `:CaseMasterConvertToKebab` | Convert into `kebab-case` |
| `:CaseMasterConvertToCamel` | Convert into `camelCase` |
| `:CaseMasterConvertToPascal` | Convert into `PascalCase` |
