local function get_standard()
    local operation = [[
        local args = {...}
        
        top = :a:-1

        for i=:a:,:a:+:b:-1 do
            stack[i] = args[i+1-:a:]
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
