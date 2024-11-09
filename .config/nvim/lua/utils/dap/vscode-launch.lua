local launch_type_to_dap_adapter = {
  ['node'] = 'pwa-node',
  ['pwa-node'] = 'pwa-node',
}
local dap_adapter_factory = {
  ['pwa-node'] = {
    type = 'server',
    port = 8123,
    executable = {
      command = 'js-debug-adapter',
      args = { '8123' },
      -- cwd = vim.fn.getcwd(),
    },
    options = {
      max_retries = 40,
    },
  },
}

local function log(msg, level)
    level = level or "info"

    -- Compose the message
    local logMessage = string.format("[%s][nvim-dap-vscode-launch] %s", level:upper(), msg)

    -- Print to Neovim's command line
    print(logMessage)
end

local function log_error(message)
  log(message, 'error')
end
local function log_debug(message)
  if vim.g.nvim_dap_vscode_launch_debug == 1 then
    log(message, 'debug')
  end
end

local function table_contains(tbl, value)
    for key, val in pairs(tbl) do
        if val == value then
            return true
        end end
    return false
end

local function validate_field(tbl, field, typ, name)
  -- log_debug("Validating field '" .. field .. "' in configuration '" .. name .. "'")
  if not tbl[field] then
    log_error("Configuration '" .. name .. "' is missing '" .. field .. "' field")
    return false
  end
  if type(tbl[field]) ~= typ then
    log_error(
      "Expected '" .. field .. "' to be of type '" .. typ .. "' but got '" ..
      type(tbl[field]) .. "' in configuration '" .. name .. "'"
    )
    return false
  end
  -- log_debug("Validated field '" .. field .. "' in configuration '" .. name .. "'")
  return true
end

local function replace_templates(config)
  if type(config) == 'string' then
    return config:gsub('${workspaceFolder}', vim.fn.getcwd())
  elseif type(config) == 'table' then
    local new_config = {}
    for key, value in pairs(config) do
      new_config[key] = replace_templates(value)
    end
    return new_config
  else
    return config
  end
end

local function handle_configuration(config, i)
  -- log_debug("Handling configuration '" .. (config.name or i) .. "'")

  -- Require config to have name, type, and our custom dap fields
  if not validate_field(config, 'name', 'string', i) then return end
  local name = config.name

  -- log_debug("Required top-level field 'name' in configuration")

  if not validate_field(config, 'type', 'string', name) then return end
  local typ = config.type

  -- log_debug("Required top-level field 'type' in configuration '" .. name .. "'")

  if not validate_field(config, 'dap', 'table', name) then return end
  local dap = config.dap

  -- log_debug("Required top-level fields present in configuration '" .. name .. "' " .. type(dap.filetypes))

  -- Require dap to have filetypes field of type string array
  if not validate_field(dap, 'filetypes', 'table', name) then return end
  for _, filetypes in ipairs(dap.filetypes) do
    if type(filetypes) ~= 'string' then
      log_error("Expected 'dap.filetypes' to be a table of strings but included '" .. type(filetypes) .. "' in configuration '" .. name .. "'")
      return
    end
  end
  local filetypes = dap.filetypes

  -- log_debug("Required dap fields present in configuration '" .. name .. "'")

  -- Check that we support the launch type
  if not launch_type_to_dap_adapter[typ] then
    log_error("Unsupported launch type '" .. typ .. "' in configuration '" .. name .. "'")
    return
  end

  -- log_debug("Supported launch type '" .. typ .. "' in configuration '" .. name .. "'")

  local dap_adapter = launch_type_to_dap_adapter[typ]
  local resolved_config = replace_templates(config)
  resolved_config.type = dap_adapter
  resolved_config.dap = nil

  return dap_adapter, filetypes, resolved_config
end

local function handle_launch_json(launch)
  local required_adapters = {}
  local configurations = {}

  -- For each launch.configurations
  for i, raw_config in ipairs(launch.configurations) do
    -- log_debug("Handling configuration '" .. (raw_config.name or i) .. "'")
    local adapter, filetypes, config = handle_configuration(raw_config, i)
    if not adapter or not filetypes or not config then
      -- log_debug("Failed to handle configuration '" .. (raw_config.name or i) .. "'")
      return
    end

    -- Add the adapter to the required adapters
    if not table_contains(required_adapters, adapter) then
      table.insert(required_adapters, adapter)
    end

    -- Add the configuration to the configurations
    for _, filetype in ipairs(filetypes) do
      if not configurations[filetype] then configurations[filetype] = {} end
      table.insert(configurations[filetype], config)
    end
  end

  return required_adapters, configurations
end

local function nvim_dap_vscode_launch(dap)
  -- local dap = require 'dap'

  log_debug("Checking for launch.json")

  local ws_path = vim.fn.getcwd()
  local ws_configuration_path = ws_path .. '/.vscode/launch.json'

  if vim.fn.filereadable(ws_configuration_path) == 1 then
    log_debug("Found launch.json. Parsing...")

    local ws_configuration_lines = vim.fn.readfile(ws_configuration_path)
    local ws_configuration = vim.fn.json_decode(table.concat(ws_configuration_lines, ''))

    log_debug("Parsed launch.json. Handling...")

    local required_adapters, configurations = handle_launch_json(ws_configuration)
    if not required_adapters or not configurations then
      log_error("Failed to parse launch.json")
      return
    end

    for _, adapter in ipairs(required_adapters) do
      local adapter_definition = dap_adapter_factory[adapter]
      log_debug("Adding adapter '" .. adapter .. "': " .. vim.inspect(adapter_definition))
      dap.adapters[adapter] = adapter_definition
    end

    for filetype, configs in pairs(configurations) do
      log_debug("Adding configurations for filetype '" .. filetype .. "': " .. vim.inspect(configs))
      dap.configurations[filetype] = configs
    end
  end
end

return nvim_dap_vscode_launch
