local function get_standard()
    local operation = [[
        local func = stack[:a:]
        local args = {}

        local lim = :a: + :b: - 1
        if :b: == 0 then lim = top + 1 end

        for i=:a:+1, lim do
            table_insert(args, stack[i])
        end

        top = :a:-1

        local results = {func(unpack(args))}

        if :c: < 1 then
            for i=:a:, :a:+#results-1 do
                stack[i] = results[i+1-:a:]
            end
        elseif :c: > 1 then
            for i=:a:,:a:+:c:-2 do
                stack[i] = results[i+1-:a:]
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
