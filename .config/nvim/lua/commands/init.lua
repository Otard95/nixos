local buf_only = require 'commands.buffer'
vim.api.nvim_create_user_command('BufOnly', buf_only, {})

local uuid = require 'commands.uuid'
vim.api.nvim_create_user_command('UUID', uuid, { range = true })

local pass = require 'commands.pass'
vim.api.nvim_create_user_command('Pass', function (ctx)
  local len = tonumber(ctx.args)
  return pass(len)
end, { range = true })

local reference = require 'commands.reference'
vim.api.nvim_create_user_command('Reference', reference, { range = true })

local time = require 'commands.time'
vim.api.nvim_create_user_command('UnixTime', time, {})
