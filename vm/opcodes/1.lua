local function get_standard()
    local operation = [[
stack[:a:] = constants[:bx:]
]]

    return operation
end

local function get_decryption()
    local operation = [[
stack[:a:] = ascii_decrypt(constants[:bx:], :bxkey:)
    ]]

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
