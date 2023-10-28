--the core feature of the paper!!

local function cp(t)
    local t2 = {}

    for i,v in pairs(t) do
        if type(v) == "table" then
            t2[i] = cp(v)
        else
            t2[i] = v
        end
    end

    return t2
end

local iAsBx = {22,31,32}

local function find(t,val)
    for i,v in pairs(t) do
        if v == val then
            return i
        end
    end
end

local function breakdown(chunk, max_stack_size)
    local inst_map = {}

    for i,v in pairs(chunk.instructions) do
        -- pre-pass to link all jumps with their constituent instructions
        
        if find(iAsBx, v.opcode) then
            local referenced_inst = chunk.instructions[v.sbx + 1 + i]

            if inst_map[tostring(referenced_inst)] ~= nil then
                table.insert(inst_map[tostring(referenced_inst)],v)
            else
                inst_map[tostring(referenced_inst)] = {v}
            end
        end
    end
    
    local new_instructions = {}

    for i,v in pairs(chunk.instructions) do
        -- link before modifications: for example if 1 becomes many, the pointer still points to the first of many instead of the last

        local t = tostring(v)
        local instrs = inst_map[t]
        if instrs ~= nil then
            for i,v in pairs(instrs) do
                v.point_to = #new_instructions + 1-- afterwards, final pass will correct the displacements between the two
            end
        end

        if v.opcode == 3 then --LOADNIL -> LOADK
            local new_instr = {opcode = 1, bx = #chunk.constants+1} -- as we insert to list, this will end up as nil
            local initial, limit = v.a, v.b

            if initial == limit then
                new_instr.a = initial
                table.insert(new_instructions, new_instr)
            else
                for i=initial, limit do
                    local copy = cp(new_instr)
                    copy.a = i
                    table.insert(new_instructions, copy)
                end
            end 
        elseif v.opcode == 2 then --LOADBOOL -> load boolean, JMP
            local new_instr = {opcode = 2, a = v.a, b = v.b, c = 0}

            table.insert(new_instructions, new_instr)
            if v.c ~= 0 then
                local jmp = {opcode = 22, a = 0, sbx = 1, correct = true}

                table.insert(new_instructions, jmp)
            end
        elseif v.opcode == 5 then -- GETGLOBAL -> GETTABLE
            if v.bx < 255 and max_stack_size < 510 then
                local new_instr = {opcode = 6, a = v.a, b = max_stack_size + 1, c = v.bx + 255}
                table.insert(new_instructions, new_instr)
            else
                table.insert(new_instructions, v)
            end
        elseif v.opcode == 7 then -- SETGLOBAL -> SETTABLE
            if v.bx < 255 and max_stack_size < 510 then
                local new_instr = {opcode = 9, a = max_stack_size + 1, b = v.bx + 255, c = v.a}

                table.insert(new_instructions, new_instr)
            else
                table.insert(new_instructions, v)
            end
        elseif v.opcode == 11 then -- SELF -> GETTABLE, MOVE
            local move_instr = {opcode = 0, a = v.a+1, b = v.b, c = 256}
            local gettable_instr = {opcode = 6, a = v.a, b = v.b, c = v.c}

            table.insert(new_instructions, move_instr)
            table.insert(new_instructions, gettable_instr)
        elseif v.opcode == 29 then -- TAILCALL -> CALL,RETURN
            -- the call instruction

            local call_instr = {opcode = 28, a = v.a, b = v.b, c = 0}
            
            -- the ret instruction
            local ret_instr = {opcode = 30, a = v.a, b = 0, c = 0}

            -- currently i have no idea how this works, but i know that b and c cannot be any number other than zero as there are return values but we have no idea how many.
            -- if b = c = 0 does not work, then this idea should be scrapped.

            table.insert(new_instructions, call_instr)
            table.insert(new_instructions, ret_instr)
        else
            table.insert(new_instructions, v)
        end
    end

    for i,v in pairs(new_instructions) do
        -- final pass through

        if find(iAsBx, v.opcode) then
            if not v.correct then
                local pcpp = i+1 -- program counter automatically +1, emulates this behaviour before calculating the jump (for an easier time on my brain)
                local jmp = v.point_to - pcpp

                v.point_to = nil
                v.sbx = jmp
            else
                v.correct = nil
            end
        end
    end

    for i,v in pairs(chunk.protos) do
        breakdown(v, max_stack_size)
    end

    chunk.instructions = new_instructions
end

return breakdown
