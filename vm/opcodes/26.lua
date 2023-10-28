local function get_standard()
    local operation = [[
        if not (stack[:a:] == (:c: ~= 0)) then
            ip = ip + 1
        end
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
