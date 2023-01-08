-- To run test suite :PlenaryBustedFile %

local tabs = require 'pretty-vanilla-tabline.spec.fixtures'.tabs1
local create_mock_vim = require 'pretty-vanilla-tabline.spec.mock_vim'
local pretty_vanilla_tabline = require 'pretty-vanilla-tabline'

describe("setup", function()

  it("sets vim.o.tabline", function()
    _G.pvt_mock_vim = create_mock_vim(tabs)
    pretty_vanilla_tabline.setup()
    assert.equals(
      _G.pvt_mock_vim.o.tabline,
      "%!v:lua.pretty_vanilla_tabline()"
    )
  end)

  it("terminates early if nvim version requirements not met", function()
    local calls_to_list_tagpages = 0
    local calls_to_nvim_echo = 0
    _G.pvt_mock_vim = create_mock_vim(tabs, {
      fn = {
        has = function(str)
          return 0
        end
      },
      nvim_list_tabpages = function(tab_id)
        calls_to_list_tagpages = calls_to_list_tagpages + 1
      end,
      nvim_echo = function(tab_id)
        calls_to_nvim_echo = calls_to_nvim_echo + 1
      end
    })
    pretty_vanilla_tabline.setup()
    assert.are_not.equal(
      _G.pvt_mock_vim.o.tabline,
      "%!v:lua.pretty_vanilla_tabline()"
    )
    assert.equals(calls_to_list_tagpages, 0)
    assert.equals(calls_to_nvim_echo, 1)
  end)
end)

describe("setup config options", function()
  _G.pvt_mock_vim = create_mock_vim(tabs)

  it("default", function()
    pretty_vanilla_tabline.setup()
    local tabline_result = _G.pretty_vanilla_tabline()
    local tabline_expected = "%#TabLine# %1@v:lua.pretty_vanilla_tabline_switch_tab@ foo.lua [1] +%T %#TabLineSel# %2@v:lua.pretty_vanilla_tabline_switch_tab@ MyVeryLongTitleWhichMayGetTruncated.js [1]%T %#TabLine# %3@v:lua.pretty_vanilla_tabline_switch_tab@[empty window] [1]%T %#TabLineFill#%="
    assert.equals(
      tabline_result,
      tabline_expected
    )
  end)

  it("filetype_icons", function()
    pretty_vanilla_tabline.setup {
      filetype_icons = {
        javascript = "JS"
      }
    }
    local tabline_result = _G.pretty_vanilla_tabline()
    local tabline_expected = "%#TabLine# %1@v:lua.pretty_vanilla_tabline_switch_tab@ foo.lua [1] +%T %#TabLineSel# %2@v:lua.pretty_vanilla_tabline_switch_tab@JS MyVeryLongTitleWhichMayGetTruncated.js [1]%T %#TabLine# %3@v:lua.pretty_vanilla_tabline_switch_tab@[empty window] [1]%T %#TabLineFill#%="
    assert.equals(
      tabline_result,
      tabline_expected
    )
  end)

  it("empty_window_title", function()
    pretty_vanilla_tabline.setup {
      empty_window_title = "(EMPTY WINDOW)"
    }
    local tabline_result = _G.pretty_vanilla_tabline()
    local tabline_expected = "%#TabLine# %1@v:lua.pretty_vanilla_tabline_switch_tab@ foo.lua [1] +%T %#TabLineSel# %2@v:lua.pretty_vanilla_tabline_switch_tab@ MyVeryLongTitleWhichMayGetTruncated.js [1]%T %#TabLine# %3@v:lua.pretty_vanilla_tabline_switch_tab@(EMPTY WINDOW) [1]%T %#TabLineFill#%="
    assert.equals(
      tabline_result,
      tabline_expected
    )
  end)

  it("highlight_groups", function()
    pretty_vanilla_tabline.setup {
      highlight_groups = {
        tab = 'Foo',
        active_tab = 'Bar',
        tabline_bg = 'Baz',
      }
    }
    local tabline_result = _G.pretty_vanilla_tabline()
    local tabline_expected = "%#Foo# %1@v:lua.pretty_vanilla_tabline_switch_tab@ foo.lua [1] +%T %#Bar# %2@v:lua.pretty_vanilla_tabline_switch_tab@ MyVeryLongTitleWhichMayGetTruncated.js [1]%T %#Foo# %3@v:lua.pretty_vanilla_tabline_switch_tab@[empty window] [1]%T %#Baz#%="
    assert.equals(
      tabline_result,
      tabline_expected
    )
  end)

  it("formatter", function()
    pretty_vanilla_tabline.setup {
      formatter = function(icon, title, win_count, is_dirty)
        local str = title
        if icon then
          str = str .. icon
        end
        str = str .. win_count
        if is_dirty then
          str = str .. '!'
        end
        return str
      end
    }
    local tabline_result = _G.pretty_vanilla_tabline()
    local tabline_expected = "%#TabLine# %1@v:lua.pretty_vanilla_tabline_switch_tab@foo.lua1!%T %#TabLineSel# %2@v:lua.pretty_vanilla_tabline_switch_tab@MyVeryLongTitleWhichMayGetTruncated.js1%T %#TabLine# %3@v:lua.pretty_vanilla_tabline_switch_tab@[empty window]1%T %#TabLineFill#%="
    assert.equals(
      tabline_result,
      tabline_expected
    )
  end)
end)

describe("pretty_vanilla_tabline_switch_tab", function()

  it("calls vim.api.nvim_set_current_tabpage with the given tab_id", function()
    local calls = {}
    _G.pvt_mock_vim = create_mock_vim(tabs, {
      nvim_set_current_tabpage = function(tab_id)
        table.insert(calls, tab_id)
      end
    })
    pretty_vanilla_tabline.setup()
    _G.pretty_vanilla_tabline_switch_tab(6)
    assert.equals(#calls, 1)
    assert.equals(calls[1], 6)
  end)

end)

describe("pretty_vanilla_tabline", function()
  it("truncates tab titles when there is not enough column width", function()
    _G.pvt_mock_vim = create_mock_vim(tabs, {
      o = {
        columns = 70,
        tabline = ''
      }
    })
    pretty_vanilla_tabline.setup()
    local tabline_result = _G.pretty_vanilla_tabline()
    local tabline_expected = "%#TabLine# %1@v:lua.pretty_vanilla_tabline_switch_tab@ …o.lua [1] +%T %#TabLineSel# %2@v:lua.pretty_vanilla_tabline_switch_tab@ …ngTitleWhichMayGetTruncated.js [1]%T %#TabLine# %3@v:lua.pretty_vanilla_tabline_switch_tab@…pty window] [1]%T %#TabLineFill#%="
    assert.equals(
      tabline_result,
      tabline_expected
    )
  end)
end)
