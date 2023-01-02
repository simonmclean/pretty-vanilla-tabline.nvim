# pretty-vanilla-tabline.nvim

Minimal plugin which makes the neovim tabline pretty and configurable, while maintaining default functionality.

Turn this:

![Default tabline](screenshot_default.png?raw=true "Default tabline")

into this:

![Plugin tabline](screenshot_plugin.png?raw=true "Plugin tabline")

## What this plugin does does

With the default configuration, your tab titles will be of the form:

```
<filetype icon> <filename or filetype> <number of windows in tab>
```

The filename and filetype will refer to active window of each tab.

## Installation

```lua
use "simonmclean/pretty-vanilla-tabline.nvim"
-- optional, if you want icons to work out of the box
use "kyazdani42/nvim-web-devicons"

require "pretty-vanilla-tabline".setup()
```

## Configuration

At the moment, the only configuration you can provide is filetype icons.

This plugin will try to use `require 'nvim-web-devicons'.get_icon_by_filetype` for the icons. But some filetypes won't have an associated icon. In such cases no icon will be shown, unless you specifiy one. For example, if you want to use the git icon for the `fugitive` filetype.

```lua
require('pretty-vanilla-tabline').setup {
  filetype_icons = {
    fugitive = require 'nvim-web-devicons'.get_icon_by_filetype('git')
  }
}
```

## TODO

- Expose formatting functions
- Respond to insufficient width
