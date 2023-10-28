-- very proud of this

local flags = { -- pretty sure this can be optimised
    [1] = "000",
    [2] = "001",
    [3] = "010",
    [4] = "011",
    [6] = "100",
    [7] = "101",
    [8] = "110",
    [9] = "111"
}

local a,b,c,bx,sbx,kb,kc = 1,2,3,4,5,6,7

local function decode(bytecode, top_level)
    if top_level == nil then top_level = true end
    local pointer = 1

    local function eat(count)
        local result = bytecode:sub(pointer, pointer+count-1)

        pointer = pointer + count
        return result
    end

    local chunk = {{},{[262144]=nil},{},{},0,{},0}

    if top_level then eat(3) end
    eat(3)

    chunk[5] = tonumber(eat(32),2) -- num upvals
    eat(3)

    chunk[7] = tonumber(eat(32),2)
    local instr_offset = chunk[7]

    if chunk[5] > 0 then
        for i=1, chunk[5] do
            eat(9)

            local len = tonumber(eat(32),2)

            local s = ""
            for i=1,len do
                s = s .. string_char(tonumber(eat(8),2))
            end

            table_insert(chunk[2], s)
        end
    end

    local kst_ptr = 1

    while pointer < #bytecode do
        local flag = find(flags,eat(3))
        
        if flag == 1 then
            chunk[3][kst_ptr] = eat(1) == "1"
            kst_ptr = kst_ptr + 1
        elseif flag == 2 then
            chunk[3][kst_ptr] = tonumber(eat(32),2)
            kst_ptr = kst_ptr + 1
        elseif flag == 3 then
            eat(3)
            local len = tonumber(eat(32),2)
            
            local s = ""
            for i=1,len do
                s = s .. string_char(tonumber(eat(8),2))
            end

            chunk[3][kst_ptr] = s
            kst_ptr = kst_ptr + 1
        elseif flag == 4 then
            local instr = {}
            local inst = tonumber(eat(26),2)

            instr[a] = bit_rshift(inst,18)
            instr[b] = bit_band(bit_rshift(inst,9),511)
            if instr[b] > 255 then instr[kb] = instr[b]-255 end
            instr[c] = bit_band(inst,511)
            if instr[c] > 255 then instr[kc] = instr[c]-255 end

            local x = bit_band(inst,262143)
            instr[bx] = x

            if x > 131072 then
                x = 131072 - x
            end
            instr[sbx] = x
            chunk[1][instr_offset] = instr
            instr_offset = instr_offset + 1
        elseif flag == 6 then
            table_insert(chunk[6], flag) -- bait
        elseif flag == 7 then
            eat(3)
            local length = tonumber(eat(32),2)
            local proto = decode(eat(length), false)

            table_insert(chunk[4], proto)
        elseif flag == 8 then
            kst_ptr = kst_ptr + 1
        elseif flag == 9 then
            eat(3)
            local int = tostring(tonumber(eat(32),2))

            eat(3)
            local dec = tostring(tonumber(eat(32),2))
            chunk[3][kst_ptr] = tonumber(int .. "." .. dec)
            kst_ptr = kst_ptr + 1
        end
    end

    return chunk
end
