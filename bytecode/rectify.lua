local rk_instrs = {
    rkc = {6,11},
    rkbc = {9,12,13,14,15,16,17,23,24,25}
}

local kst_instrs = {1,5,7}
local upvalue_instrs = {4,8}

local function find(t,val)
    for i,v in pairs(t) do
        if v == val then
            return i
        end
    end
end

local function handle_kst(instr)
    if find(kst_instrs, instr["opcode"]) then
        instr["bx"] = instr["bx"] + 1
    end
end

local function handle_upvalue(instr)
    if find(upvalue_instrs, instr["opcode"]) then
        instr["b"] = instr["b"] + 1
    end
end

local function handle_rk(instr, only_rk)
    if find(rk_instrs.rkc, instr["opcode"]) then
        -- goofy ass control flow
    elseif find(rk_instrs.rkbc, instr["opcode"]) or only_rk then
        if instr.b > 255 then
            instr.kb = instr.b - 255 -- not -256, +1 from that to correct the lua 1-indexed tables
        end
    else
        return
    end

    if instr.c > 255 then
        instr.kc = instr.c - 255 -- same here
    end
end

local function handle_proto(instr)
    if instr.opcode == 36 then
        instr.bx = instr.bx + 1
    end
end

local function rectify_instructions(chunk, only_rk)
    local instrs = chunk.instructions

    for i,instr in pairs(instrs) do
        handle_rk(instr, only_rk) --all rk has been created, and then every k index is 
        if not only_rk then
            handle_kst(instr)
            handle_upvalue(instr)
            handle_proto(instr)
        end
    end
end

local function rectify(chunk, only_rk)
    only_rk = only_rk or false
    rectify_instructions(chunk, only_rk)

    for i,proto in pairs(chunk.protos) do
        rectify(proto, only_rk)
    end
end

return rectify