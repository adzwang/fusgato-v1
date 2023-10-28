local function get_standard()
    local operation = [[
                stack[:a:] = ""
                for i=:b:,:c: do
                    stack[:a:] = stack[:a:] .. stack[i]
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
