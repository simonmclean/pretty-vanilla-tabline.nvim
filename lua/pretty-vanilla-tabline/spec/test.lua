local tabs = require 'pretty-vanilla-tabline.spec.test_scenarios'.tabs1
_G.pvt_mock_vim = require 'pretty-vanilla-tabline.spec.mock_vim' (tabs)

describe("_G.pretty_vanilla_tabline()", function()
  it("returns the expected tabline (default config)", function()
    require 'pretty-vanilla-tabline'.setup()
    local tabline_result = _G.pretty_vanilla_tabline()
    local tabline_expected = "%#TabLine# %1@v:lua.pretty_vanilla_tabline_switch_tab@ foo.lua [1] +%T %#TabLineSel# %2@v:lua.pretty_vanilla_tabline_switch_tab@ bar.js [1]%T %#TabLine# %3@v:lua.pretty_vanilla_tabline_switch_tab@[empty window] [1]%T %#TabLineFill#%="
    assert.equals(
      tabline_result,
      tabline_expected
    )
  end)

  it("returns the expected tabline (custom filetype_icons)", function()
    require('pretty-vanilla-tabline').setup {
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

  it("returns the expected tabline (custom empty_window_title)", function()
    require('pretty-vanilla-tabline').setup {
      empty_window_title = "(EMPTY WINDOW)"
    }
    local tabline_result = _G.pretty_vanilla_tabline()
    local tabline_expected = "%#TabLine# %1@v:lua.pretty_vanilla_tabline_switch_tab@ foo.lua [1] +%T %#TabLineSel# %2@v:lua.pretty_vanilla_tabline_switch_tab@ bar.js [1]%T %#TabLine# %3@v:lua.pretty_vanilla_tabline_switch_tab@(EMPTY WINDOW) [1]%T %#TabLineFill#%="
    assert.equals(
      tabline_result,
      tabline_expected
    )
  end)

  it("returns the expected tabline (custom highlight_groups)", function()
    require('pretty-vanilla-tabline').setup {
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

  it("returns the expected tabline (custom formatter)", function()
    require 'pretty-vanilla-tabline'.setup {
      formatter = function (icon, title, win_count, is_dirty)
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
