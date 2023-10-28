local function compile(chunk)
    local function runner(...)
        local constants = chunk[3]
        local upvalues = chunk[2]
        local protos = chunk[4]
        local instructions = chunk[1]

        local top = 1
        local ip = top

        local stack = setmetatable({[:size:] = getfenv()},{
            [_newindex] = function(t,k,v)
                if k > top then top = k end

                rawset(t,k,v)
            end
        })

        ip = chunk[7] -- lol

        local args = {...}
        if #args > 0 then
            for i=0, #args-1 do
                stack[i] = args[i+1]
            end
        end

        while true do -- eventually i'll find a better condition for this
            