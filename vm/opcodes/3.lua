local function get_standard()
    local operation = [[
stack[:a:] = stack[:a:]
]]

    return operation
end

local function get_custom()
end

local function get_premium()
end

return {
    standard = get_standard,
    premium = get_premium,
    custom = get_custom
}
