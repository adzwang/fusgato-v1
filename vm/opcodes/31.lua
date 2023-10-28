local function get_standard()
    local operation = [[
        stack[:a:] = stack[:a:] + stack[:a:+2]

        if stack[:a:+2] > 0 then
            if stack[:a:] <= stack[:a:+1] then
                ip = ip + :sbx:
                stack[:a:+3] = stack[:a:]
            end
        else
            if stack[:a:] >= stack[:a:+1] then
                ip = ip + :sbx:
                stack[:a:+3] = stack[:a:]
            end
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
