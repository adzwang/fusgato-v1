local function get_standard()
    local operation = [[
        if stack[:b:] == (:c: ~= 0) then
            stack[:a:] = stack[:b:]
        else
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
