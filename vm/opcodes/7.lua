local function get_standard()
    local operation = [=[
        getfenv()[constants[:bx:]] = stack[:a:]
    ]=]

    return operation
end

local function get_decryption()
    local operation = [=[
        getfenv()[ascii_decrypt(constants[:bx:], :bxkey:)] = stack[:a:]
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
