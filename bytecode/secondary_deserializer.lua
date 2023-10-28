local logging = require("../logging/logger.lua")

local flags = {
    boolean = "000",
    number = "001",
    string = "010",
    instruction = "011",
    upvalue = "100",
    proto = "101",
    userdata = "110",
    double = "111"
}
local a,b,c,bx,sbx,kb,kc = "a","b","c","bx","sbx","kb","kc"

local function find(t,val)
    for i,v in pairs(t) do
        if v == val then return i end
    end
end

local function decode(bytecode, top_level)
    if top_level == nil then top_level = true end
    local pointer = 1

    local function eat(count)
        local result = bytecode:sub(pointer, pointer+count-1)

        pointer = pointer + count
        return result
    end

    local chunk = {
        instructions = {},
        upvalues = {},
        constants = {},
        protos = {}
    }

    if top_level then assert(eat(3) == flags.proto) end
    assert(eat(3) == flags.number)

    local num_upvals = tonumber(eat(32),2)
    chunk.upvalue_count = num_upvals

    assert(eat(3) == flags.number)

    local instr_offset = tonumber(eat(32),2)
    chunk.instr_offset = instr_offset

    if num_upvals > 0 then
        for i=1, num_upvals do
            assert(eat(3) == flags.upvalue)
            assert(eat(3) == flags.string)
            assert(eat(3) == flags.number)

            local len = tonumber(eat(32),2)

            local s = ""
            for i=1,len do
                s = s .. string.char(tonumber(eat(8),2))
            end

            table.insert(chunk.upvalues, s)
        end
    end

    local kst_ptr = 1

    while pointer < #bytecode do
        local fl = eat(3)
        local flag = find(flags,fl)
        
        if flag == "boolean" then
            chunk.constants[kst_ptr] = eat(1) == "1"
            kst_ptr = kst_ptr + 1
        elseif flag == "number" then
            chunk.constants[kst_ptr] = tonumber(eat(32),2)
            kst_ptr = kst_ptr + 1
        elseif flag == "string" then
            assert(eat(3) == flags.number)
            local len = tonumber(eat(32),2)
            
            local s = ""
            for i=1,len do
                s = s .. string.char(tonumber(eat(8),2))
            end

            chunk.constants[kst_ptr] = s
            kst_ptr = kst_ptr + 1
        elseif flag == "instruction" then
            local instr = {}
            local inst = tonumber(eat(26),2)

            instr[a] = bit.rshift(inst,18)
            instr[b] = bit.band(bit.rshift(inst,9),511)
            if instr[b] > 255 then instr[kb] = instr[b]-255 end
            instr[c] = bit.band(inst,511)
            if instr[c] > 255 then instr[kc] = instr[c]-255 end

            local x = bit.band(inst,262143)
            instr[bx] = x

            if x > 131072 then
                x = 131072 - x
            end
            instr[sbx] = x
            chunk.instructions[instr_offset] = instr
            instr_offset = instr_offset + 1
        elseif flag == "upvalue" then
            logging.error("upvalue where its not meant to be")
        elseif flag == "proto" then
            assert(eat(3) == flags.number)
            local length = tonumber(eat(32),2)
            local proto = decode(eat(length), false)

            table.insert(chunk.protos, proto)
        elseif flag == "newproxy" then
            kst_ptr = kst_ptr + 1
        elseif flag == "double" then
            assert(eat(3) == flags.number)
            local int = tostring(tonumber(eat(32),2))

            assert(eat(3) == flags.number)
            local dec = tostring(tonumber(eat(32),2))
            chunk.constants[kst_ptr] =  tonumber(int .. "." .. dec)
            kst_ptr = kst_ptr + 1
        end
    end

    return chunk
end

return {decode = decode}