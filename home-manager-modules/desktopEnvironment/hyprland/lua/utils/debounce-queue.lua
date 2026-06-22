local DebounceQueue = {}
DebounceQueue.__index = DebounceQueue

---@class DebounceQueue
---@field ms integer The number of milliseconds to debounce
---@field action function The action to take after debounce
---@field running boolean If a timer is currently pending
---@field queued any Last queued args, nil if none pending

function DebounceQueue:create(ms, action)
  local dq = { ms = ms, action = action, running = false, queued = nil }
  setmetatable(dq, DebounceQueue)
  return dq
end

function DebounceQueue:push(...)
  self.queued = table.pack(...)
  if self.running then
    return
  end
  self:_schedule()
end

function DebounceQueue:_schedule()
  self.running = true
  hl.timer(function()
    local args = self.queued
    self.queued = nil
    self.action(table.unpack(args, 1, args.n))
    self.running = false
    if self.queued then
      self:_schedule()
    end
  end, { timeout = self.ms, type = "oneshot" })
end

return DebounceQueue
