local function get_standard()
    local operation = [[
        if not ((:kb: and constants[:kb:] or stack[:b:]) <= (:kc: and constants[:kc:] or stack[:c:])) then
            ip = ip + 1
        end
    ]]

    return operation
end

local function get_decryption(instr)
    if instr.ckey and instr.bkey then
        return [[
            if not (ascii_decrypt(constants[:kc:], :bkey:)) <= (ascii_decrypt(constants[:kc:], :ckey:)) then
                ip = ip + 1
            end
        ]]
    elseif instr.bkey then
        return [[
            if not (ascii_decrypt(constants[:kc:], :bkey:)) <= (:kc: and constants[:kc:] or stack[:c:]) then
                ip = ip + 1
            end
        ]]
    elseif instr.ckey then
        return [[
            if not (:kb: and constants[:kb:] or stack[:b:]) <= (ascii_decrypt(constants[:kc:], :ckey:)) then
                ip = ip + 1
            end
        ]]
    end
end

local function get_custom()
end

local function get_premium()
end

return {
    standard = get_standard,
    decryption = get_decryption,
    premium = get_premium,
    custom = get_custom
}
