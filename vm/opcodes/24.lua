local function get_standard()
    local operation = [[
        if ((:kb: and constants[:kb:] or stack[:b:]) > (:kc: and constants[:kc:] or stack[:c:])) then
            ip = ip + 1
        end
    ]]

    return operation
end