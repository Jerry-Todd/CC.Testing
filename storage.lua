

local path = "data.dat"

local function load()
  if not fs.exists(path) then return {} end
  local file = fs.open(path, "r")
  local data = textutils.unserialize(file.readAll())
  file.close()
  return data or {}
end

local function save(tbl)
  local file = fs.open(path, "w")
  file.write(textutils.serialize(tbl))
  file.close()
end

local M = {}

function M.get(key)
  local data = load()
  return data[key]
end

function M.set(key, value)
  local data = load()
  data[key] = value
  save(data)
end

return M
