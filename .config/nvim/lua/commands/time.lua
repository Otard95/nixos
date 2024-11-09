local buffer = require 'utils.buffer'

local function unix()
  local time = tostring(os.time())
  buffer.insert_text(time)
end
return unix
