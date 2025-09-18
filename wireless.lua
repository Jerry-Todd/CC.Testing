

local args = {...}

local modem = peripheral.find("modem")
if not modem then
    warn('no modem found')
    return
end
rednet.open(peripheral.getName(modem))

-- function addSpaces(str)
--     return str:gsub(".", "%1 "):sub(1, -2)
-- end

if args[1] == 'client' then
    while true do
        term.clear()
        term.setCursorPos(1, 1)
        rednet.broadcast(read(), 'move')
    end
else
    while true do
        local id, message = rednet.receive('move')
        term.clear()
        term.setCursorPos(1, 1)
        shell.run('test ' .. message)
    end
end

