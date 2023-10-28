local function get_standard()
    local operation = [[
        stack[:a:] = (:kb: and constants[:kb:] or stack[:b:]) % (:kc: and constants[:kc:] or stack[:c:])
    ]]

    return operation
end

local function get_decryption(instr)
    if instr.ckey and instr.bkey then
        return [=[
            stack[:a:] = (ascii_decrypt(constants[:kb:], :bkey:)) % (ascii_decrypt(constants[:kc:], :ckey:))
        ]=]
    elseif instr.bkey then
        return [=[
            stack[:a:] = (ascii_decrypt(constants[:kb:], :bkey:)) % (:kc: and constants[:kc:] or stack[:c:])
        ]=]
    elseif instr.ckey then
        return [=[
            stack[:a:] = (:kb: and constants[:kb:] or stack[:b:]) % (ascii_decrypt(constants[:kc:], :ckey:))
        ]=]
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
