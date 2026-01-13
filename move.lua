local M = {}

local storage = require("storage")

local args = { ... }

local x, y, z = gps.locate()

local facing = nil

local function refresh_pos()
    local _x, _y, _z = gps.locate()
    if _x then
        x, y, z = _x, _y, _z
        print(x .. " " .. y .. " " .. z)
    else
        print("GPS unavailable")
    end
end

function M.CalibrateDir()
    local dir = function()
        -- refresh our current position from GPS for accurate deltas
        local _ox, _oy, _oz = gps.locate()
        if not _ox then return nil end

        for i = 1, 4 do
            if turtle.forward() then
                local _x, _y, _z = gps.locate()
                turtle.back()
                -- forward step delta (new - old): -z = north, +z = south, +x = east, -x = west
                _x, _y, _z = _x - _ox, _y - _oy, _z - _oz
                if _z == -1 then
                    return 1
                elseif _z == 1 then
                    return 3
                elseif _x == 1 then
                    return 2
                elseif _x == -1 then
                    return 4
                end
                return
            else
                turtle.turnRight() -- try next direction
            end
        end
        return nil
    end
    facing = dir()
end

M.CalibrateDir()

function M.move(dir)
    local move = function()
        if dir > 4 then
            if dir == 5 then
                if turtle.up() then
                    refresh_pos()
                    return true
                end
            elseif dir == 6 then
                if turtle.down() then
                    refresh_pos()
                    return true
                end
            end
        elseif math.abs(dir - facing) == 2 then
            if turtle.back() then
                local backwards = ((facing + 1) % 4) + 1
                refresh_pos()
                return true
            end
        else
            M.turn(dir)
            if turtle.forward() then
                refresh_pos()
                return true
            end
        end
    end
    local res = move()
    if res then refresh_pos() end
    return res
end

function M.turn(dir)
    if dir == facing then
        return
    end
    local dif = (dir - facing) % 4
    if dif == 1 then
        turtle.turnRight()
    elseif dif == 2 then
        turtle.turnRight()
        turtle.turnRight()
    elseif dif == 3 then
        turtle.turnLeft()
    end
    facing = dir
end

function M.getpos()
    return {
        x = x,
        y = y,
        z = z
    }
end

return M

-- for _, value in ipairs(args) do
--     print('Move: ' .. value .. ' from ' .. x .. ' ' .. y .. ' ' .. z)
--     move(tonumber(value))
--     print('Moved to ' .. x .. ' ' .. y .. ' ' .. z)
-- end
