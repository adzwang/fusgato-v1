local function get_standard()
    local operation = [=[
        stack[:a:+1] = stack[:b:]
        stack[:a:] = stack[:b:][:kc: and constants[:kc:] or stack[:c:]]
    ]=]

    return operation
end

local function get_decryption()
    local operation = [=[
        stack[:a:+1] = stack[:b:]
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
    premium = get_premium,
    custom = get_custom
}
