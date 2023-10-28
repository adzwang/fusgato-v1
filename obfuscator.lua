local deserialize = require("./bytecode/deserialize.lua")
local rectify = require("./bytecode/rectify.lua")
local serializer = require("./bytecode/serializer.lua")
local offset = require("./bytecode/offset.lua")
local breakdown = require("./bytecode/breakdown.lua")
local encrypt = require("./bytecode/constant_encryption.lua")
local secondary_deserializer = require("./bytecode/secondary_deserializer.lua")

local vm_generator = require("./vm/main.lua")

local fs = require("fs")
local diet = require("./luasrcdiet")
local interpreter = require("./interpreter.lua")

local logging = require("./logging/logger.lua")

local debug = true

local watermark = [=[--[[
    IronBrew:tm: obfuscation; Version 2.7.0
]]

local FusGato = "discord.gg/cWQAy6Z697";

]=]

local function verify(old_chunk, new_chunk)
    -- instructions
    local instrs = old_chunk.instructions
    local new_instrs = new_chunk.instructions

    for i=1, #instrs do
        local instr = instrs[i]
        for k,v in pairs(instr) do
            if new_instrs[i-1+new_chunk.instr_offset][k] ~= v then
                if not (k == "type" or k == "opcode" or k:find("key")) then
                    return false,"instruction error"
                end
            end
        end
    end

    -- constants
    local consts = old_chunk.constants
    local new_consts = new_chunk.constants

    for i=1, #consts do
        if consts[i] ~= new_consts[i] then
            if tostring(consts[i]) ~= "1.1125369292536e-308" then -- this is messed up
                return false,"constant error"
            end
        end
    end

    -- upvalues
    local upvalue_count = old_chunk.upvalue_count
    if upvalue_count ~= new_chunk.upvalue_count then
        return false,"upvalue count error"
    end

    local upvalues, new_upvalues = old_chunk.upvalues, new_chunk.upvalues
    if upvalue_count > 0 then
        for i=1,upvalue_count do
            if upvalues[i] ~= new_upvalues[i] then
                return false,"upvalue error"
            end
        end
    end

    -- protos
    local protos, new_protos = old_chunk.protos, new_chunk.protos
    for i=1, #protos do
        local result, errormessage = verify(protos[i], new_protos[i])
        
        if not result then return false, "proto error & " .. errormessage end
    end

    return true
end

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

local function get_max_stacksize(chunk)
    local max = 0
    if chunk.stack_size > max then
        max = chunk.stack_size
    end

    for i,v in pairs(chunk.protos) do
        local b = get_max_stacksize(v)
        if b > max then
            max = b
        end
    end

    return max
end

local function main(bytecode, opts)
    math.randomseed(os.time())

    local output = deserialize(bytecode)
    rectify(output)
    local m = get_max_stacksize(output)
    breakdown(output, m)
    local order = offset(output)

    if constant_encryption then
        encrypt(output)
    end

    if opts.loud then
        logging.info("Bytecode parsed")
    end
    
    local chunk_copy = cp(output)
    local order_copy = cp(order)

    local sorted_chunk = serializer.spread_chunk(output)
    local custom_bytecode = serializer.chunk(sorted_chunk)

    if opts.loud then
        logging.info("Custom bytecode compiled")
    end
    
    local new_chunk = secondary_deserializer.decode(custom_bytecode)
    rectify(new_chunk,true)
    
    if not verify(chunk_copy,new_chunk) then
        logging.error("non-symmetrical output and input!")
    end

    if opts.loud then
        logging.info("Verified symmetrical output and input")
    end

    if opts.compression then
        logging.error("nyi")
    end
    -- let the vm handler take it from here
    local script = vm_generator.generate(order_copy, custom_bytecode, opts, m)

    if opts.loud then
        logging.info("Script obfuscated")
    end

    local result = diet.optimize(diet.MAXIMUM_OPTS, script)

    if result:find("stack") then
        print(result)
        logging.error("fail")
    end

    -- add a watermark

    result = watermark .. result

    if debug then
        fs.writeFileSync("nomin.lua", script)
        fs.writeFileSync("output.lua", result)
    end

    return result
end

return main
