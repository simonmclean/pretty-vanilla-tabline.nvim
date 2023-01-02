local M = {}

function M.split_string(str, delimiter)
  local result = {};
  for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match);
  end
  return result;
end

function M.last(list)
  return list[#list]
end

function M.eval(fn)
  return fn()
end

function M.list_map(tbl, fn)
  local newTbl = {}
  for _, value in pairs(tbl) do
    table.insert(newTbl, fn(value))
  end
  return newTbl
end

function M.list_foreach(tbl, fn)
  for _, value in pairs(tbl) do
    fn(value)
  end
end

function M.list_join(tbl, sep)
  sep = sep or ''
  local result = ''
  M.list_foreach(tbl, function (el)
    result = result .. el .. sep
  end)
  return result
end

return M
