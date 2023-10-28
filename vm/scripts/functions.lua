local function find(t,val)
    for i,v in pairs(t) do
        if v == val then return i end
    end
end

local function ascii_decrypt(text, num)
    local result = ""

    for c in string_gmatch(text,pattern) do
        local shifted = string_char((string_byte(c)-num)%256)

        result = result .. shifted
    end

    return result
end