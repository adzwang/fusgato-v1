local function get_standard()
    local operation = [=[
stack[:a:] = stack[:b:][:kc: and constants[:kc:] or stack[:c:]]
]=]

    return operation
end

local function get_decryption() -- if it needs to be decrypted, it is guaranteed to be a string constant
    local operation = [=[
stack[:a:] = stack[:b:][ascii_decrypt(constants[:kc:], :ckey:)]
    ]=]

    return operation
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
