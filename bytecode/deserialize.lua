local bytecode = ""
local pointer = 1

local logging = require('../logging/logger.lua')
local fs = require('fs')

local sys_is_little_endian = require('ffi').abi("le")

local defaults = {
    version = 0x51,
    fmt = 0,
    int_size = 4,
    instr_size = 4,
    lua_Number = 8
}

local opcode_mappings = {
    iABC = {0,2,3,4,6,8,9,10,11,12,13,14,15,16,17,18,19,20,21,23,24,25,26,27,28,29,30,33,34,35,37},
    iABx = {1,5,7,36},
    iAsBx = {22,31,32}
}

local function get_opcode_type(code)
    if code < 0 or code > 37 then return end

    for opcode_type,matches in pairs(opcode_mappings) do
        for i,opcode in pairs(matches) do
            if opcode == code then
                return opcode_type
            end
        end
    end
end

local config = {}

local function set(bc)
    bytecode = bc
end

local function get(amount, check_endian)
    if check_endian == nil then check_endian = true end

    local substring = bytecode:sub(pointer,pointer + (amount - 1))
    pointer = pointer + amount

    local char_array = {}

    for char in substring:gmatch(".") do
        table.insert(char_array,char)
    end

    if config["endian"] ~= nil and check_endian and (sys_is_little_endian == config["endian"]) then
        for i=1,math.floor(#char_array/2) do
            local j = #char_array - i + 1
            char_array[i], char_array[j] = char_array[j], char_array[i]
        end
    end

    return char_array
end

local function chars_to_int(char_array)
    local length = #char_array-1
    local int = 0
    local char = 1
    for i=length*8,0,-8 do
        int = int + bit.lshift(
            char_array[char]:byte(),
            i
        )
        char = char + 1
    end

    return int
end

local function get_size_t()
    return chars_to_int(get(config["size_t"]))
end

local function get_byte()
    return chars_to_int(get(1))
end

local function get_int_32()
    return chars_to_int(get(4))
end

local function get_double() -- i hate ieeeeeeeeeee 754
    local char_array = (get(defaults["lua_Number"]))
    local bits = ""
    for i,v in pairs(char_array) do
        local value = v:byte()
        local converted = ""

        for i=1,8 do
            local bit = math.fmod(value,2)
            value = math.floor((value - bit) / 2)
            converted = bit .. converted
        end

        bits = bits .. converted
    end

    local sign = bits:sub(1,1)
    local exponent = tonumber(bits:sub(2,12), 2) - 1023
    local mantissa = bits:sub(13,-1)

    local number = 1
    
    for i=1,52 do
        if mantissa:sub(i,i) == "1" then
            number = number + 2 ^ (-i)
        end
    end

    number = math.ldexp(number,exponent)

    if sign == "1" then
        number = -number
    end

    return number
end

local function get_string()
    local length = get_size_t()
    if length == 0 then return "" end

    local value = get(length, false)
    return table.concat(value):sub(1,-2)
end

local function get_instruction(chunk,index,setlist)
    local code = get_int_32()

    local opcode = bit.band(code, 63) -- 63 = 111111
    local opcode_type = get_opcode_type(opcode)

    if setlist then return code end

    local instruction = {
        opcode = opcode,
        type = opcode_type,
        a = bit.band(bit.rshift(code,6), 255)
    }

    if opcode_type ~= "iABC" then
        instruction[opcode_type:sub(3,-1):lower()] = bit.rshift(code,14)

        if opcode_type:sub(3,-1):lower() == "sbx" then
            instruction["sbx"] = instruction["sbx"] - 131072 + 1 -- although there is no constant folding i am doing this for clarity - lua 1 indexed tables
        end
    else
        instruction.b = bit.rshift(code,23)
        instruction.c = bit.band(bit.rshift(code,14),511) -- 8372224 = 11111111100000000000000
    end

    return instruction
end

local function get_instructions()
    local instruction_count = get_int_32()
    
    local instructions = {}

    local setlist = false

    for i=1, instruction_count do
        local instruction = get_instruction(chunk,i,setlist)
        if setlist then setlist = false end

        if instruction.code == 34 and instruction.c == 0 then
            setlist = true
        end
        table.insert(instructions, instruction)
    end

    return instructions
end

local function get_constant()
    local constant_type = get_byte()
    
    if constant_type == 0 then
        return newproxy()
    elseif constant_type == 1 then
        return get_byte() ~= 0
    elseif constant_type == 3 then
        return get_double()
    elseif constant_type == 4 then
        return get_string()
    end

    logging.error("What???")
end

local function get_constants()
    local constant_count = get_int_32()
    local constants = {}

    for i=1, constant_count do
        constants[i] = get_constant()
    end

    return constants
end

local get_chunk

local function get_chunks(get_chunk)
    local chunks = {}

    local chunk_count = get_int_32()
    for i=1,chunk_count do
        table.insert(chunks,get_chunk())
    end

    return chunks
end

local function get_chunk()
    local name = get_string()
    local line_defined = get_int_32()
    local last_line_defined = get_int_32()
    local upvalue_count = get_byte()
    local parameter_count = get_byte()
    local is_vararg = get_byte()
    local stack_size = get_byte()

    local chunk = {
        -- name = name,
        -- line_defined = line_defined,
        -- last_line_defined = last_line_defined,
        upvalue_count = upvalue_count,
        -- parameter_count = parameter_count,
        -- is_vararg = is_vararg,
        stack_size = stack_size
    }

    chunk.instructions = get_instructions()
    chunk.constants = get_constants()
    chunk.protos = get_chunks(get_chunk)

    for i=1,get_int_32() do
        get_int_32()
    end

    for i=1,get_int_32() do -- formatting doesn't work when -s flag for luac :interrobang:
        get_string()
        get_int_32()
        get_int_32()
    end

    local upvalue_count = get_int_32()
    local upvalues = {}

    for i=1, upvalue_count do
        table.insert(upvalues,get_string())
    end

    chunk.upvalues = upvalues

    return chunk
end

local function decode(path)
    set(fs.readFileSync(path))
    if bytecode == "" then return end

    local sig = get_int_32()
    if sig ~= 0x1b4c7561 then return end
    
    local version = get_byte()
    if version ~= 0x51 then return end
    
    local fmt = get_byte()
    if fmt ~= 0 then return end

    local endian = get_byte()
    config["endian"] = endian and true or false

    local int_size = get_byte()
    if int_size ~= defaults["int_size"] then return end

    local size_t = get_byte()
    config["size_t"] = size_t

    local instr_size = get_byte()
    if instr_size ~= defaults["instr_size"] then return end

    local lua_Number = get_byte()
    if lua_Number ~= defaults["lua_Number"] then return end

    local is_float = get_byte() and false or true
    if not is_float then return end

    return get_chunk()
end

return decode