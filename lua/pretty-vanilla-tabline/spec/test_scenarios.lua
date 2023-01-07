local tabs1 = {
  {
    tab_id = 1,
    is_active = false,
    windows = {
      {
        win_id = 1,
        is_active = true,
        buffer = {
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
        buffer = {
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
        buffer = {
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

return {
  tabs1 = tabs1
}
