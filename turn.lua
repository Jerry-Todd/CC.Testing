

local move = require('move')

local dir = tonumber(({...})[1])

move.CalibrateDir()

move.turn(dir)
