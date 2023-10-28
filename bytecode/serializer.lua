local serializer = {}

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
local a,b,c,bx,sbx = "a","b","c","bx","sbx"

local opcode_mappings = {
    iABC = {0,2,3,4,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21,23,24,25,26,27,28,29,30,33,34,35,37},
    iABx = {1,5,7,36},
    iAsBx = {22,31,32}
}

local function find(tbl,value)
    for i,v in pairs(tbl) do
        if v == value then return i end
    end
end

local function leftpad(str,count,char)
    local char = char or "0"

    str = char:rep(count-#str) .. str
    return str
end

local function to_bits(num)
    local bit_rep = ""
        
    while num > 0 do
        if num % 2 == 0 then
            bit_rep = "0" .. bit_rep
        else
            bit_rep = "1" .. bit_rep
        end

        num = bit.rshift(num, 1)
    end

    return bit_rep
end

function serializer.spread_chunk(chunk)
    local sorted_chunk = {}

    table.insert(sorted_chunk, chunk.upvalue_count)
    table.insert(sorted_chunk, chunk.instr_offset)

    for i,upvalue in pairs(chunk.upvalues) do
        table.insert(sorted_chunk, upvalue)
    end

    -- from now on these can be shuffled

    local total_count = #chunk.instructions + #chunk.constants + #chunk.protos

    while total_count > 0 do
        local ubound = 3
        local proto = 0
        local valids = {}

        if #chunk.instructions == 0 then ubound = ubound - 1 else table.insert(valids,chunk.instructions) end
        if #chunk.constants == 0 then ubound = ubound - 1 else table.insert(valids,chunk.constants) end
        if #chunk.protos == 0 then ubound = ubound - 1 else
            table.insert(valids,chunk.protos)
            proto = #valids
        end

        local selection = math.random(1,ubound)

        if selection == 1 then
            local item = table.remove(valids[1],1)
            if proto == selection then
                item = serializer.spread_chunk(item)
            end
            table.insert(sorted_chunk,item)
        elseif selection == 2 then
            local item = table.remove(valids[2],1)
            if proto == selection then
                item = serializer.spread_chunk(item)
            end
            table.insert(sorted_chunk,item)
        elseif selection == 3 then
            local item = table.remove(valids[3],1)
            if proto == selection then
                item = serializer.spread_chunk(item)
            end
            table.insert(sorted_chunk,item)
        end

        total_count = total_count - 1
    end
    
    return sorted_chunk
end

function serializer.chunk(sorted_chunk, top_level)
    if top_level == nil then top_level = true end

    local pointer = 1
    local bytecode = (not top_level) and "" or flags.proto

    local upvalue_count = sorted_chunk[pointer]
    bytecode = bytecode .. serializer.constant(upvalue_count)
    pointer = pointer + 1

    local instr_offset = sorted_chunk[pointer]
    bytecode = bytecode .. serializer.constant(instr_offset)

    for i=1,upvalue_count do
        pointer = pointer + 1
        bytecode = bytecode .. serializer.upvalue(sorted_chunk[pointer])
    end

    while pointer < #sorted_chunk do
        pointer = pointer + 1

        local item = sorted_chunk[pointer]
        if type(item) == "table" then
            if type(item[1]) == "number" then
                bytecode = bytecode .. flags.proto .. serializer.chunk(item, false)
            else
                bytecode = bytecode .. serializer.instruction(item)
            end
        else
            bytecode = bytecode .. serializer.constant(item)
        end
    end

    if not top_level then
        bytecode = serializer.constant(#bytecode) .. bytecode
    end

    return bytecode
end

function serializer.format()
end

function serializer.constant(const)
    local typ = type(const)
    local bytecode = flags[typ]

    if typ == "boolean" then
        bytecode = bytecode .. (const and "1" or "0")
    elseif typ == "number" then
        if tostring(const) == "1.1125369292536e-308" then const = 0 end
        
        local str_num = tostring(const)
        local result = str_num:find("%.")
        if result then
            bytecode = flags["double"]
            local int,dec = str_num:sub(1,result-1), str_num:sub(result+1,-1)
            bytecode = bytecode .. serializer.constant(tonumber(int)) .. serializer.constant(tonumber(dec))
        else
            if const > 2147483647 then
                logging.error("serializing number > 32 bits")
            end

            bytecode = bytecode .. leftpad(to_bits(const), 32)
        end
    elseif typ == "string" then
        bytecode = bytecode .. serializer.constant(#const)

        for c in const:gmatch(".") do
            bytecode = bytecode .. leftpad(to_bits(c:byte()), 8)
        end
    elseif typ == "userdata" then
        -- nothing
    end

    return bytecode
end

function serializer.instruction(instr) --[[the instructions will be parsed
                                        with a b c bx and sbx, the instruction 
                                        chosen will just determine what it will
                                        be]]
    -- organise it as abc
    local bytecode = flags.instruction
    bytecode = bytecode .. leftpad(to_bits(instr[a]), 8)

    if find(opcode_mappings.iABC,instr.opcode) then
        bytecode = bytecode .. leftpad(to_bits(instr[b]), 9) .. leftpad(to_bits(instr[c]), 9)
    elseif find(opcode_mappings.iABx,instr.opcode) then
        bytecode = bytecode .. leftpad(to_bits(instr[bx]), 18)
    elseif find(opcode_mappings.iAsBx,instr.opcode) then
        local val = instr[sbx]

        if val > 0 then
            bytecode = bytecode .. "0" .. leftpad(to_bits(instr[sbx]), 17)
        else
            bytecode = bytecode .. "1" .. leftpad(to_bits(math.abs(instr[sbx])), 17)
        end
    end

    return bytecode
end

function serializer.upvalue(upvalue)
    return flags.upvalue .. serializer.constant(upvalue)
end

return serializer