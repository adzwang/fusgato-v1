local function get_standard()
    local operation = [[
        local func = stack[:a:]
        local args = {}

        local lim = :a: + :b: - 1

        if :b: == 0 then lim = top+1 end

        for i=:a:+1,:a:+:b:-1 do
            table_insert(args,stack[i])
        end

        return func(unpack(args))
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
