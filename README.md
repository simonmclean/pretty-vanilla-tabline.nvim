# 🌈 pretty-vanilla-tabline.nvim

Minimal plugin which makes the neovim tabline pretty and configurable, while maintaining default functionality.

Turn this 🤢

![Default tabline](assets/screenshot_default.png?raw=true "Default tabline")

into this 🤩

![Plugin tabline](assets/screenshot_plugin.png?raw=true "Plugin tabline")

## What this plugin does does

Using default configuration your tab titles will consist of

```
<filetype_icon> <filename or filetype> [<number_of_windows_in_tab>]
```

The filename and filetype will refer to the active window of each tab. Filename will take priority over filetype.

## Installation

```lua
-- Example installation using Packer
use "simonmclean/pretty-vanilla-tabline.nvim"
use "kyazdani42/nvim-web-devicons" -- optional, if you want icons to work out of the box

-- Initialize
require "pretty-vanilla-tabline".setup()
```

## Configuration

At the moment, the only configuration you can provide is filetype icons.

This plugin will try to use `require 'nvim-web-devicons'.get_icon_by_filetype` for the icons. But some filetypes won't have an associated icon. In such cases no icon will be shown, unless you specifiy one. For example, if you want to use the git icon for the `fugitive` filetype.

```lua
require 'pretty-vanilla-tabline'.setup {
  filetype_icons = {
    fugitive = require 'nvim-web-devicons'.get_icon_by_filetype('git')
  }
}
```

## TODO

- Expose formatting functions
- Handle insufficient width
