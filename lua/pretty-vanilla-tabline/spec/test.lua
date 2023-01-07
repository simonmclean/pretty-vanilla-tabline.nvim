-- To run test suite :PlenaryBustedFile %

local tabs = require 'pretty-vanilla-tabline.spec.test_scenarios'.tabs1
local create_mock_vim = require 'pretty-vanilla-tabline.spec.mock_vim'
local pretty_vanilla_tabline = require 'pretty-vanilla-tabline'

describe("setup", function ()
  _G.pvt_mock_vim = create_mock_vim(tabs)

  it("sets vim.o.tabline", function ()
    pretty_vanilla_tabline.setup()
    assert.equals(
      _G.pvt_mock_vim.o.tabline,
      "%!v:lua.pretty_vanilla_tabline()"
    )
  end)
end)

describe("setup config options", function()
  _G.pvt_mock_vim = create_mock_vim(tabs)

  it("default", function()
    pretty_vanilla_tabline.setup()
    local tabline_result = _G.pretty_vanilla_tabline()
    local tabline_expected = "%#TabLine# %1@v:lua.pretty_vanilla_tabline_switch_tab@ foo.lua [1] +%T %#TabLineSel# %2@v:lua.pretty_vanilla_tabline_switch_tab@ bar.js [1]%T %#TabLine# %3@v:lua.pretty_vanilla_tabline_switch_tab@[empty window] [1]%T %#TabLineFill#%="
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
    local tabline_expected = "%#TabLine# %1@v:lua.pretty_vanilla_tabline_switch_tab@ foo.lua [1] +%T %#TabLineSel# %2@v:lua.pretty_vanilla_tabline_switch_tab@JS bar.js [1]%T %#TabLine# %3@v:lua.pretty_vanilla_tabline_switch_tab@[empty window] [1]%T %#TabLineFill#%="
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
    local tabline_expected = "%#TabLine# %1@v:lua.pretty_vanilla_tabline_switch_tab@ foo.lua [1] +%T %#TabLineSel# %2@v:lua.pretty_vanilla_tabline_switch_tab@ bar.js [1]%T %#TabLine# %3@v:lua.pretty_vanilla_tabline_switch_tab@(EMPTY WINDOW) [1]%T %#TabLineFill#%="
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
    local tabline_expected = "%#Foo# %1@v:lua.pretty_vanilla_tabline_switch_tab@ foo.lua [1] +%T %#Bar# %2@v:lua.pretty_vanilla_tabline_switch_tab@ bar.js [1]%T %#Foo# %3@v:lua.pretty_vanilla_tabline_switch_tab@[empty window] [1]%T %#Baz#%="
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
    local tabline_expected = "%#TabLine# %1@v:lua.pretty_vanilla_tabline_switch_tab@foo.lua1!%T %#TabLineSel# %2@v:lua.pretty_vanilla_tabline_switch_tab@bar.js1%T %#TabLine# %3@v:lua.pretty_vanilla_tabline_switch_tab@[empty window]1%T %#TabLineFill#%="
    assert.equals(
      tabline_result,
      tabline_expected
    )
  end)
end)

describe("pretty_vanilla_tabline_switch_tab", function()
  it("calls nvim_set_current_tabpage with the given tab_id", function()
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
