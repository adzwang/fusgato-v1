local function get_standard()
    local operation = [[
        local results = {}

        if :b: == 0 then
            for i=:a:,top do
                table_insert(results,stack[i])
            end
        elseif :b: > 1 then
            for i=:a:,:a:+:b:-2 do
                table_insert(results,stack[i])
            end
        end

        return unpack(results)
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
