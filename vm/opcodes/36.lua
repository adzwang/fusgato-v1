local function get_standard()
    local operation = [=[
        local instr = :inst:
        local proto = protos[:bx:]

        if proto[5] == 0 then
            stack[:a:] = compile(proto)
        else
            local tkpairs = {}
            local upvalue_indexing = setmetatable({}, {
                __index = function(_,key)
                    local pair = tkpairs[key]

                    return pair[1][pair[2]]
                end,
                __newindex = function(_,key,value)
                    local pair = tkpairs[key]

                    pair[1][pair[2]] = value
                end
            })

            for i=1, proto[5] do
                ip = ip + 1
                local pseudo = instructions[ip]

                local field = pseudo[:B:]

                tkpairs[i] = {stack, field}
            end

            proto[2] = upvalue_indexing

            stack[instr[:A:]] = compile(proto)
        end
    ]=]

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
