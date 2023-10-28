local function get_standard(instr)
    local operation = [[
stack[:a:] = %s
]]

    return operation:format(instr.b ~= 0 and "True" or "False")
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
