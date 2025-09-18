

local path = require('pathfind')
local args = {...}

path.pathfind({
    x=tonumber(args[1]),
    y=tonumber(args[2]),
    z=tonumber(args[3])
})

