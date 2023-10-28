-- deserializer

local table_insert = table.insert
local unpack = unpack
local setmetatable = setmetatable
local tonumber = tonumber
local string_char = string.char
local string_byte = string.byte
local bit = bit or bit32
local band = "band"
local rshift = "rshift"
local bit_band = bit[band]
local bit_rshift = bit[rshift]
local pattern = "."

-- functions
local pairs = pairs

-- interpreter
local getfenv = getfenv
local string_gmatch = string.gmatch
local True = true
local _newindex = "__newindex"
local rawset = rawset
local False = false