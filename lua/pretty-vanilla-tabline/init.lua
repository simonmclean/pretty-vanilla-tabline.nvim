local api = vim.api

local default_config = {
  filetype_icons = {},
  formatter = function(icon, title, win_count)
    return icon .. ' ' .. title .. ' [' .. win_count .. ']'
  end,
  empty_tab_title = '[empty tab]'
}

local setup = function(config)
  local required_version = '0.8.1'

  if (vim.fn.has('nvim-' .. required_version) == 0) then
    local msg = "pretty-vanilla-tabline requires neovim version " .. required_version .. " or above"
    api.nvim_echo({ { msg, "WarningMsg" } }, true, {})
    return
  end

  config = {
    filetype_icons = config.filetype_icons or default_config.filetype_icons,
    formatter = config.formatter or default_config.formatter,
    empty_tab_title = config.empty_tab_title or default_config.empty_tab_title
  }

  local _ = require 'pretty-vanilla-tabline.utils'
  local devicon_installed, devicons = pcall(require, 'nvim-web-devicons')

  local function with_padding(str)
    return ' ' .. str .. ' '
  end

  local function with_highlight_group(group_name, str)
    return '%#' .. group_name .. '#' .. str
  end

  local function with_click_handler(tab_id, str)
    return '%' .. tab_id .. '@v:lua.pretty_vanilla_tabline_switch_tab@' .. str .. '%T'
  end

  local function get_tab_win_buf_tree()
    --[[
  The final result will be a table of [tab_id] to [data] where [data] contains:
  tab_id : number
  title : string (filename or filetype)
  is_active : boolean
  win_count : number
  active_win.win_id : number
  active_win.buf_id : number
  active_win.buf_name : string
  active_win.buf_filetype : string
  active_win.buf_filetype_icon : string
  --]]
    local result = {}

    -- Get IDs for all tabs and windows
    local tabs = api.nvim_list_tabpages()
    local windows = api.nvim_list_wins()

    -- Get the currently active tab
    local current_tab = api.nvim_get_current_tabpage()

    -- Add tab data to the tree
    _.list_foreach(tabs, function(tab_id)
      -- indexing this way to preserve the order returned by nvim_list_tabpages
      result[tab_id] = {
        tab_id = tab_id,
        is_active = tab_id == current_tab,
      }
    end)

    -- Add window and buffer data to the tree
    _.list_foreach(windows, function(win_id)
      local tab_id = api.nvim_win_get_tabpage(win_id)
      local is_active_win = api.nvim_tabpage_get_win(tab_id) == win_id

      if is_active_win then
        local buf_id = api.nvim_win_get_buf(win_id)
        local buf_filetype = api.nvim_buf_get_option(buf_id, 'filetype')
        local buf_filetype_icon = _.eval(function()
          -- Check if config specifies an icon
          if (config.filetype_icons[buf_filetype]) then
            return config.filetype_icons[buf_filetype]
          end
          -- Otherwise try to get one from devicons
          if (devicon_installed and buf_filetype) then
            local icon = devicons.get_icon_by_filetype(buf_filetype)
            if (icon) then
              return icon
            end
          end
          return ''
        end)
        result[tab_id]['active_win'] = {
          win_id = win_id,
          buf_id = buf_id,
          buf_name = api.nvim_buf_get_name(buf_id),
          buf_filetype = buf_filetype,
          buf_filetype_icon = buf_filetype_icon
        }
      end

      result[tab_id]['win_count'] = (result[tab_id]['win_count'] or 0) + 1
    end)

    -- The way we're indexing puts the tabs out of order. Fixing that here
    local result_ordered = _.list_map(tabs, function(tab_id)
      return result[tab_id]
    end)

    return result_ordered
  end

  _G.pretty_vanilla_tabline_switch_tab = function(id)
    api.nvim_set_current_tabpage(id)
  end

  _G.pretty_vanilla_tabline = function()
    -- For each tab set the title
    local tabs = _.list_map(get_tab_win_buf_tree(), function(tab)
      local filename = _.last(_.split_string(tab.active_win.buf_name, '/'))

      tab.title = _.eval(function()
        if (filename == "") then
          if (tab.active_win.buf_filetype == "") then
            return config.empty_tab_title
          else
            return tab.active_win.buf_filetype
          end
        end
        return filename
      end)

      return tab
    end)

    -- Create the tabline strings, including highlight groups
    local tabline_strings = _.list_map(tabs, function(tab)
      local full_tab_title = config.formatter(
        tab.active_win.buf_filetype_icon,
        tab.title,
        tab.win_count
      )

      local highlight_group = _.eval(function()
        if (tab.is_active) then
          return 'TabLineSel'
        end
        return 'TabLine'
      end)

      return with_highlight_group(
        highlight_group,
        with_padding(
          with_click_handler(tab.tab_id, full_tab_title)
        )
      )
    end)

    local tabline = _.list_join(tabline_strings) .. '%#TabLineFill#%='

    return tabline
  end

  vim.o.tabline = '%!v:lua.pretty_vanilla_tabline()'

end

return {
  setup = setup
}
