local M = {}

local colors = require('config.galaxyline.colors')

-- =============================================================================
--                      Private functions and variables
-- =============================================================================

local condition_slug = 'UND' -- ........... Variable to store the condition slug
local temp = 'UND'           -- .............. Variable to store the temperature
local temp_max = 'UND'       -- ...... Variable to store the maximum temperature
local temp_min = 'UND'       -- ...... Variable to store the minimum temperature

-- Dictionary to convert the condition slug into an icon.
local dict_condition = {
  ['storm']         = '',
  ['snow']          = '',
  ['hail']          = '晴',
  ['rain']          = '',
  ['fog']           = '敖',
  ['clear_day']     = '',
  ['clear_night']   = '',
  ['cloud']         = '',
  ['cloudly_day']   = '',
  ['cloudly_night'] = '',
  ['none_day']      = '',
  ['none_night']    = ''
}

-- Parse the JSON weather file and return a table with the result.
local function parse_json_weather()
  local json = require('json.json')
  local fweather = io.open('/tmp/weather', 'r')

  if fweather ~= nil then
    -- We need to parse the file to check the date.
    local json_report = fweather:read('*a')
    local report = json.decode(json_report)
    return report
  else
    return nil
  end
end

-- Return the color of the temperature `temp`.
local function get_temp_color(temp)
  if temp == nil then
    return colors.fg
  end

  if temp <= 10 then
    return colors.violet
  elseif temp <= 12 then
    return colors.dark_blue
  elseif temp <= 14 then
    return colors.dark_cyan
  elseif temp <= 16 then
    return colors.blue
  elseif temp <= 18 then
    return colors.cyan
  elseif temp <= 20 then
    return colors.dark_green
  elseif temp <= 22 then
    return colors.green
  elseif temp <= 24 then
    return colors.dark_orange
  elseif temp <= 26 then
    return colors.orange
  elseif temp <= 28 then
    return colors.yellow
  elseif temp <= 30 then
    return colors.red
  elseif temp <= 32 then
    return colors.dark_red
  else
    return colors.fg
  end
end

-- Get the weather file. The weather file is requested only if the old one is
-- one hour old.
local function get_weather()
  local request_weather = false

  -- First, check if we have the files to avoid unnecessary requests to the API.
  local report = parse_json_weather()

  if report ~= nil then
    -- We need to parse the file to check the date.
    local report_date = report['results']['date']
    local report_time = report['results']['time']

    -- Convert the strings to date and time.
    local day, month, year = string.match(report_date, '(%d+)/(%d+)/(%d+)')
    local h, m = string.match(report_time, '(%d+):(%d+)')
    local report_timestamp = os.time({
      year = year,
      month = month,
      day = day,
      hour = h,
      min = m
    })

    -- Compare with the current time.
    local current_timestamp = os.time()
    local delta = os.difftime(current_timestamp, report_timestamp)

    if delta > 3600 then request_weather = true end
  else
    request_weather = true
  end

  -- If we need to request the weather, then get the JSON file from the
  -- internet.
  if request_weather then
    -- We should wait if there is a lock file to avoid problem with multiple
    -- Neovim instances. If this is the case, then the old file, if it exists,
    -- will be used.
    local handle = io.open('/tmp/weather.lock', 'r')

    if handle == nil then
      os.execute("touch /tmp/weather.lock")
      os.execute('curl -s -o /tmp/weather https://api.hgbrasil.com/weather?woeid=455912')
      os.execute("rm /tmp/weather.lock")
    else
      io.close(handle)
    end

    report = parse_json_weather()
  end

  -- Update the temperature.
  if report ~= nil then
    condition_slug = report['results']['condition_slug']
    temp = report['results']['temp']
    temp_max = report['results']['forecast'][1]['max']
    temp_min = report['results']['forecast'][1]['min']
  else
    condition_slug = 'ERR'
    temp = 'ERR'
    temp_max = 'ERR'
    temp_min = 'ERR'
  end

  -- Set the highlight colors given the new data.
  local color = get_temp_color(tonumber(temp))
  vim.cmd('highlight WeatherTemp guifg=' .. color .. ' guibg='..colors.section_bg)

  local color_max = get_temp_color(tonumber(temp_max))
  vim.cmd('highlight WeatherMaxTemp guifg=' .. color_max .. ' guibg='..colors.section_bg)

  local color_min = get_temp_color(tonumber(temp_min))
  vim.cmd('highlight WeatherMinTemp guifg=' .. color_min ..' guibg='..colors.section_bg)
end

-- Task file to run everything asynchronously. The weather task will be executed
-- periodically every 5 minutes.
local task = vim.loop.new_async(function()
  local timer = vim.loop.new_timer()
  timer:start(0, 300000, vim.schedule_wrap(function ()
    get_weather()

    -- Trigger the event informing that the weather information was updated.
    vim.api.nvim_command('doautocmd User WeatherUpdated')
  end))
end)

-- =============================================================================
--                      Public functions and variables
-- =============================================================================

-- Run the task that get the weather file periodically.
function M.init()
  -- Get the weather information the first time.
  get_weather()

  -- Initialize the asynchronous process that fetches the information
  -- periodically.
  task:send()
end

-- Return the icon indicating the current weather condition.
function M.get_condition_icon()
  local condition = dict_condition[condition_slug]

  if condition == nil then
    return ''
  else
    return condition
  end
end

-- Return the current temperature. This function also sets the highlight group
-- `WeatherTemp` accordingly.
function M.get_temp()
  return temp .. '°C'
end

-- Return the minimum temperature of the day. This function also sets the
-- highlight group `WeatherMaxTemp` accordingly.
function M.get_max_temp()
  return temp_max .. '°C'
end

-- Return the minimum temperature of the day. This function also sets the
-- highlight group `WeatherMinTemp` accordingly.
function M.get_min_temp()
  return temp_min .. '°C'
end

return M
