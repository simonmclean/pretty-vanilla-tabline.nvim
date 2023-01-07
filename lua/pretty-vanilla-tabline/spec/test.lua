local tabs = require 'pretty-vanilla-tabline.spec.test_scenarios'.tabs1
_G.pvt_mock_vim = require 'pretty-vanilla-tabline.spec.mock_vim'(tabs)

describe("_G.pretty_vanilla_tabline()", function()
  it("returns the expected tabline", function()
    require 'pretty-vanilla-tabline.init'.setup()
    local tabline_result = _G.pretty_vanilla_tabline()
    local tabline_expected = "%#TabLine# %1@v:lua.pretty_vanilla_tabline_switch_tab@ foo.lua [1] +%T %#TabLineSel# %2@v:lua.pretty_vanilla_tabline_switch_tab@ bar.js [1]%T %#TabLine# %3@v:lua.pretty_vanilla_tabline_switch_tab@[empty window] [1]%T %#TabLineFill#%="
    assert.equals(
      tabline_result,
      tabline_expected
    )
  end)
end)
