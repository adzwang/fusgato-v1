local fs = require("fs")
local interpreter = require('./interpreter.lua')
local obfuscator = require("./obfuscator.lua")

local config = {
    folder = "input",
    script_name = "input.lua"
}

local enums = {
    platform_lock = {
        universal = 0,
        roblox = 1,
        luajit = 2
    }
}

local opts = {
    default = {
        compression = false,
        premium = false,
        loud = true,
        memes = "sigma",
        constant_encryption = true,
        platform_lock = enums.platform_lock.universal
    },
}

local function compile()
    local result = os.execute(
        string.format(
            'luac -o "%s" "%s"',
            string.format(
                "./%s/luac.out",
                config.folder
            ),
            string.format(
                './%s/%s',
                config.folder,
                config.script_name
            )
        )
    )

    if not result then
        error("Invalid syntax")
    end

    return true
end

local function interpret()
    if compile() then
        interpreter.run("./input/luac.out")
    end
end

local function obfuscate()
    if compile() then
        obfuscator("./input/luac.out", opts.default)
    end
end

obfuscate()