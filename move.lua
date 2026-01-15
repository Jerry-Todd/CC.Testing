

local path = require('pathfind')
local args = {...}

local ignoreGoal = (args[4] == "true")
path.pathfind({
    x=tonumber(args[1]),
    y=tonumber(args[2]),
    z=tonumber(args[3])
}, ignoreGoal)