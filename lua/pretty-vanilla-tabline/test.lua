local _ = require 'pretty-vanilla-tabline.utils'

local tabs = {
  {
    tab_id = 1,
    is_active = false,
    windows = {
      {
        win_id = 1,
        is_active = true,
        buffers = {
          buf_id = 1,
          name = 'abc/efg/foo.lua',
          o = {
            modified = true,
            filetype = 'lua'
          }
        }
      }
    }
  },
  {
    tab_id = 2,
    is_active = true,
    windows = {
      {
        win_id = 2,
        is_active = true,
        buffers = {
          buf_id = 2,
          name = '///bar.js',
          o = {
            modified = false,
            filetype = 'javascript'
          }
        }
      }
    }
  },
  {
    tab_id = 3,
    is_active = false,
    windows = {
      {
        win_id = 3,
        is_active = true,
        buffers = {
          buf_id = 3,
          name = '',
          o = {
            modified = false,
            filetype = ''
          }
        }
      }
    }
  }
}

_G.pvt_mock_vim = {
  o = {
    columns = 300,
    tabline = ''
  },
  fn = {
    has = function()
      return true
    end
  },
  api = {
    nvim_echo = function(chunks, history, opts)
      return nil
    end,

    nvim_list_tabpages = function()
      return _.list_map(tabs, function(tab)
        return tab.tab_id
      end)
    end,

    nvim_list_wins = function()
      local win_ids = {}
      _.list_foreach(tabs, function(tab)
        _.list_foreach(tab.windows, function(win)
          _.list_concat(win_ids, win.win_id)
        end)
      end)
      return win_ids
    end,

    nvim_get_current_tabpage = function()
      local active_tab_id = nil
      _.list_foreach(tabs, function(tab)
        if (tab.is_active) then
          active_tab_id = tab.tab_id
        end
      end)
      return active_tab_id
    end,

    nvim_win_get_tabpage = function(win_id)
      local tab_id = nil
      _.list_foreach(tabs, function(tab)
        _.list_foreach(tab.windows, function(win)
          if win.win_id == win_id then
            tab_id = tab.tab_id
          end
        end)
      end)
      return tab_id
    end,

    nvim_win_get_buf = function(win_id)
      local buf_id = nil
      _.list_foreach(tabs, function(tab)
        _.list_foreach(tab.windows, function(win)
          if win.win_id == win_id then
            _.list_foreach(win.buffers, function(buf)
              if buf.is_active then
                buf_id = buf.buf_id
              end
            end)
          end
        end)
      end)
      return buf_id
    end,

    nvim_tabpage_get_win = function(tab_id)
      local win_id = nil
      _.list_foreach(tabs, function(tab)
        if (tab.tab_id == tab_id) then
          _.list_foreach(tab.windows, function(win)
            if win.is_active then
              win_id = win.win_id
            end
          end)
        end
      end)
      return win_id
    end,

    nvim_buf_get_option = function(buf_id, option)
      local result = nil
      _.list_foreach(tabs, function(tab)
        _.list_foreach(tab.windows, function(win)
          _.list_foreach(win.buffers, function(buf)
            if buf.buf_id == buf_id then
              result = buf.o[option]
            end
          end)
        end)
      end)
      return result
    end,

    nvim_buf_get_name = function(buf_id)
      local name = nil
      _.list_foreach(tabs, function(tab)
        _.list_foreach(tab.windows, function(win)
          _.list_foreach(win.buffers, function(buf)
            if buf.buf_id == buf_id then
              name = buf.name
            end
          end)
        end)
      end)
      return name
    end,

    nvim_set_current_tabpage = function(tab_id)
      return nil
    end
  }
}

require 'pretty-vanilla-tabline.init'.setup()
local tabline_func = _G.pretty_vanilla_tabline
    vim.pretty_print(_G.pvt_mock_vim.api.nvim_list_tabpages())
    tabline_func()

describe("pretty-vanilla-tabline", function()
  it("works", function()
    -- vim.pretty_print(_G.pvt_mock_vim.api.nvim_list_tabpages())
    -- tabline_func()
    -- assert.equals(
    --   tabline_func(),
    --   "hello"
    -- )
  end)
end)
