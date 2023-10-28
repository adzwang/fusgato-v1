local log_level = 0
local message = "%s | [%s] | %s"
local auto_reset = true

local colours = {
    grey = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    reset = 37
}

local log_levels = {
    info = 1,
    debug = 2,
    warning = 3,
    error = 4
}

local function colourise(message, colour)
    return string.format("\27[%sm%s",colours[colour],message)
end

local function reset()
    return io.write(colourise("","reset"))
end

local function get_log_level()
    return log_level
end

local function set_log_level(level)
    log_level = level
end

local function info(msg)
    local name = "info"

    if log_level > log_levels[name] then return end

    print(colourise(string.format(message, os.date("%F %T"), name:upper(), msg), "green"))

    if auto_reset then return reset() end
end

local function debug(msg)
    local name = "debug"

    if log_level > log_levels[name] then return end

    print(colourise(string.format(message, os.date("%F %T"), name:upper(), msg), "blue"))

    if auto_reset then return reset() end
end

local function warning(msg)
    local name = "warning"

    if log_level > log_levels[name] then return end

    print(colourise(string.format(message, os.date("%F %T"), name:upper(), msg), "yellow"))

    if auto_reset then return reset() end
end

local function error(msg)
    local name = "error"

    if log_level > log_levels[name] then return end

    print(colourise(string.format(message, os.date("%F %T"), name:upper(), msg), "red"))

    if auto_reset then return reset() end
end

return {
    log_level = log_levels,
    get_log_level = get_log_level,
    set_log_level = set_log_level,
    info = info,
    debug = debug,
    warning = warning,
    error = error
}
