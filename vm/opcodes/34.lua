local function get_standard()
    local operation = [[
        if :c: == 0 then
            ip = ip - 1
        end

        local lim = :b:
        if lim == 0 then lim = top - :a: + 1 end

        for i=1,lim do
            stack[:a:][(:c:-1)*50+i] = stack[:a:+i]
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
