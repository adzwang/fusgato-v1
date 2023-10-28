local fs = require('fs')
local treebuilder = require("./tree/main.lua")

local function read_script(name)
    return fs.readFileSync("./vm/scripts/" .. name .. ".lua")
end

local function generate(order, bytecode, opts, max_stack_size)
    local opts = opts or {}

    -- begin to build a script

    local script = ""

    script = script .. read_script("constants") .. "\n"
    script = script .. read_script("functions") .. "\n"
    script = script .. [[local bytecode = "]] .. bytecode .. '"' 
    script = script .. read_script("lightweight_secondary_deserializer") .. "\n"

    script = script .. read_script("interpreter"):gsub(":size:", max_stack_size+1)

    -- tree management

    script = script .. treebuilder.build(order, opts.memes)

    script = script .. [[

            ip = ip + 1
        end
    end
    
    return runner
end

]]

    script = script .. "return compile(decode(bytecode))()"
    return script
end

return {
    generate = generate
}