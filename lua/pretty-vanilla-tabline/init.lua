local setup = function(config)
  vim.pretty_print("SETUP")
  local _vim = _G.pvt_mock_vim or vim
  local api = _vim.api
  local required_version = '0.8.1'

  if (_vim.fn.has('nvim-' .. required_version) == 0) then
    local msg = "pretty-vanilla-tabline requires neovim version " .. required_version .. " or above"
    api.nvim_echo({ { msg, "WarningMsg" } }, true, {})
    return
  end

  local default_config = {
    filetype_icons = {},
    formatter = function(icon, title, win_count, is_dirty)
      local str = ""
      if icon then
        str = icon .. ' '
      end
      str = str .. title .. " [" .. win_count .. "]"
      if is_dirty then
        str = str .. " +"
      end
      return str
    end,
    empty_window_title = '[empty window]',
    highlight_groups = {
      tab = 'TabLine',
      active_tab = 'TabLineSel',
      tabline_bg = 'TabLineFill',
    }
  }

  if config then
    config = {
      filetype_icons = config.filetype_icons or default_config.filetype_icons,
      formatter = config.formatter or default_config.formatter,
      empty_window_title = config.empty_window_title or default_config.empty_window_title,
      highlight_groups = config.highlight_groups or default_config.highlight_groups
    }
  else
    config = default_config
  end

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

  local function get_tab_win_buf_state()
    --[[
  The final result will be a table of [tab_id] to [data] where [data] contains:
  tab_id : number
  title : string (filename or filetype)
  formatted_title : string (result of the formatter function)
  is_active : boolean
  is_dirty : boolean (true if any of the windows have modified buffers)
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

    -- For each tab, set the tab_id and is_active flag
    _.list_foreach(tabs, function(tab_id)
      result[tab_id] = {
        tab_id = tab_id,
        is_active = tab_id == current_tab,
      }
    end)

    -- Add window and buffer data associated with each tab
    _.list_foreach(windows, function(win_id)
      local tab_id = api.nvim_win_get_tabpage(win_id)
      local buf_id = api.nvim_win_get_buf(win_id)
      local is_active_win = api.nvim_tabpage_get_win(tab_id) == win_id

      result[tab_id].is_dirty = result[tab_id].is_dirty or api.nvim_buf_get_option(buf_id, 'modified')

      if is_active_win then
        local buf_filetype = api.nvim_buf_get_option(buf_id, 'filetype')
        local buf_filetype_icon = _.eval(function()
          -- Check if config specifies an icon
          if (config.filetype_icons[buf_filetype]) then
            return config.filetype_icons[buf_filetype]
          end
          -- Otherwise try to get one from devicons
          if (devicon_installed and buf_filetype) then
            local icon = devicons.get_icon_by_filetype(buf_filetype)
            if (not _.is_empty(icon)) then
              return icon
            end
          end
          return nil
        end)
        result[tab_id].active_win = {
          win_id = win_id,
          buf_id = buf_id,
          buf_name = api.nvim_buf_get_name(buf_id),
          buf_filetype = buf_filetype,
          buf_filetype_icon = buf_filetype_icon,
        }
      end

      result[tab_id].win_count = (result[tab_id].win_count or 0) + 1
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
    -- used to keep track of the total width of all the tabs
    local tabline_col_width = 0
    local vim_col_width = _vim.o.columns

    -- For each tab set the title
    local tabs = _.list_map(get_tab_win_buf_state(), function(tab)
      local filename = _.last(_.split_string(tab.active_win.buf_name, '/'))

      tab.title = _.eval(function()
        if (_.is_empty(filename)) then
          if (_.is_empty(tab.active_win.buf_filetype)) then
            return config.empty_window_title
          else
            return tab.active_win.buf_filetype
          end
        end
        return filename
      end)

      tab.formatted_title = config.formatter(
        tab.active_win.buf_filetype_icon,
        tab.title,
        tab.win_count,
        tab.is_dirty
      )

      tabline_col_width = tabline_col_width + string.len(tab.formatted_title) + 2 -- plus 2 for the padding

      return tab
    end)

    -- If we can't fit all the tabs, decide how much we need to chop off percentage-wise
    local tab_truncation_factor = _.eval(function()
      if (vim_col_width >= tabline_col_width) then
        return 0
      end
      return 1 - (vim_col_width / tabline_col_width)
    end)

    -- Truncate titles if needed, then set highlight groups
    local tabline_strings = _.list_map(tabs, function(tab)
      if (tab_truncation_factor > 0) then
        tab.title = '…' .. string.sub(
          tab.title,
          math.ceil(string.len(tab.title) * tab_truncation_factor) + 1-- plus 1 for the ellipsis
        )
        tab.formatted_title = config.formatter(
          tab.active_win.buf_filetype_icon,
          tab.title,
          tab.win_count,
          tab.is_dirty
        )
      end

      local highlight_group = _.eval(function()
        if (tab.is_active) then
          return config.highlight_groups.active_tab
        end
        return config.highlight_groups.tab
      end)

      return with_highlight_group(
        highlight_group,
        with_padding(
          with_click_handler(tab.tab_id, tab.formatted_title)
        )
      )
    end)

    local tabline = _.list_join(tabline_strings) .. '%#' .. config.highlight_groups.tabline_bg .. '#%='

    return tabline
  end

  _vim.o.tabline = '%!v:lua.pretty_vanilla_tabline()'
end

return {
  setup = setup
}
