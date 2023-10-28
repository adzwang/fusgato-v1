local function get_standard(instr)
    local operation = [[
        if (:kb: and constants[:kb:] or stack[:b:]) %s (:kc: and constants[:kc:] or stack[:c:]) then
            ip = ip + 1
        end
    ]]

    local equality_test = "=="

    if instr.a > 0 then equality_test = "~=" end

    return operation:format(equality_test)
end

local function get_decryption(instr)
    local operation;

    if instr.ckey and instr.bkey then
        operation = [[
            if (ascii_decrypt(constants[:kc:], :bkey:)) %s (ascii_decrypt(constants[:kc:], :ckey:)) then
                ip = ip + 1
            end
        ]]
    elseif instr.bkey then
        operation = [[
            if (ascii_decrypt(constants[:kc:], :bkey:)) %s (:kc: and constants[:kc:] or stack[:c:]) then
                ip = ip + 1
            end
        ]]
    elseif instr.ckey then
        operation = [[
            if (:kb: and constants[:kb:] or stack[:b:]) %s (ascii_decrypt(constants[:kc:], :ckey:)) then
                ip = ip + 1
            end
        ]]
    end

    local equality_test = "=="

    if instr.a > 0 then equality_test = "~=" end

    return operation:format(equality_test)
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
