local function get_standard()
    local operation = [[
        local results = {stack[:a:](stack[:a:+1],stack[:a:+2])}

        for i=1,:c: do
            stack[:a:+2+i] = results[i]
        end

        if stack[:a:+3] then
            stack[:a:+2] = stack[:a:+3]
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
