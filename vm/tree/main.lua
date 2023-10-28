local fs = require("fs")
local json = require("json")

local function get_opcode(op)
    return require("../opcodes/" .. op .. ".lua")
end
local category = "khaled"

local function collect_memes()
    local file = json.decode(fs.readFileSync("./resources/strings.json"))
    local strings = file[category]

    return strings

    -- local lengths = {}

    -- for i,v in pairs(strings) do
    --     local len = #v
        
    --     if type(lengths[len]) ~= "table" then
    --         lengths[len] = {v}
    --     else
    --         table.insert(lengths[len], v)
    --     end 
    -- end

    -- return lengths
end

local function pick_random(t)
    local selection = math.random(1,#t)
    return table.remove(t,selection)
end

local function build_simple(protos, memes)
    local tree = ""

    local ip_idx = 1
    local strings = collect_memes()

    local total_instructions = 0
    for i,chunk in pairs(protos) do
        total_instructions = total_instructions + #chunk.instructions
    end

    local chance = #strings / total_instructions

    for i,chunk in pairs(protos) do
        for i2,instr in pairs(chunk.instructions) do
            local num = ip_idx

            if memes then
                local m = math.random()

                if m < chance then
                    if #strings > 0 then
                        local s = pick_random(strings)
                        local operation = ip_idx - #s

                        if operation > 0 then
                            operation = "+" .. operation
                        else
                            operation = tostring(operation)
                        end

                        num = string.format([[#("%s")%s]], s, operation)
                    end
                end
            end

            tree = tree .. [[if ip == ]] .. num .. [[ then
                    ]]

            local opcode = get_opcode(instr.opcode)

            local requires_decryption = false

            for i,v in pairs(instr) do
                if i:find("key") then
                    requires_decryption = true
                end
            end

            if requires_decryption then
                opcode = opcode.decryption(instr)
            else
                opcode = opcode.standard(instr)
            end

            opcode = opcode:gsub(":a:", "instructions[ip][1]")
            opcode = opcode:gsub(":b:", "instructions[ip][2]")
            opcode = opcode:gsub(":c:", "instructions[ip][3]")
            opcode = opcode:gsub(":bx:", "instructions[ip][4]")
            opcode = opcode:gsub(":sbx:", "instructions[ip][5]")
            opcode = opcode:gsub(":kb:", "instructions[ip][6]")
            opcode = opcode:gsub(":kc:", "instructions[ip][7]")
            opcode = opcode:gsub(":A:", "1")
            opcode = opcode:gsub(":B:", "2")

            if requires_decryption then
                for i,v in pairs(instr) do
                    if i:find("key") then
                        opcode = opcode:gsub(":"..i..":",tostring(v))
                    end
                end
            end

            opcode = opcode:gsub(":inst:", "instructions[ip]")
            tree = tree .. opcode

            if i == #protos and i2 == #chunk.instructions then
                tree = tree .. [[
                end]]
            else
                tree = tree .. [[
                else]]
            end

            ip_idx = ip_idx + 1
        end
    end
    
    return tree
end

return {
    build = build_simple
}