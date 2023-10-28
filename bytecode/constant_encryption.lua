local function ascii_encrypt(text, num)
    local result = ""

    for c in text:gmatch(".") do
        local shifted = string.char((c:byte()+num)%256)

        result = result .. shifted
    end

    return result
end

local function find(t,val)
    for i,v in pairs(t) do
        if v == val then return i end
    end
end

local bx = {1,5,7}

local rk = {6,9,12,13,14,15,16,17,11,23,24,25}

local function encrypt_constants(chunk)
    local keys = {}

    for i,v in pairs(chunk.constants) do
        if type(v) == "string" then
            local key = math.random(1,1000)

            keys[i] = key

            chunk.constants[i] = ascii_encrypt(v, key)
        end
    end

    for i,v in pairs(chunk.instructions) do
        -- handle all instructions which might work with constants
        -- direct interface with kst: 1,5,7
        -- RK values: 6,9 (5 and 7 transform into these), 12-17 (arithmetic), 11 (should never be seen), 23,24,25

        if find(bx, v.opcode) then
            local constant = chunk.constants[v.bx]

            if type(constant) == "string" then v.bxkey = keys[v.bx] end
        end

        if find(rk, v.opcode) then
            if v.c > 255 then
                local constant = chunk.constants[v.c-255]
                
                if type(constant) == "string" then v.ckey = keys[v.c-255] end
            end

            if v.b > 255 then
                local constant = chunk.constants[v.b-255]
                
                if type(constant) == "string" then v.bkey = keys[v.b-255] end
            end
        end
    end

    for i,v in pairs(chunk.protos) do
        encrypt_constants(v)
    end
end

return encrypt_constants