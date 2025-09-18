
local M = {}

local storage = require("storage")

local args = {...}

local x = storage.get('x') or 0
local y = storage.get('y') or 0
local z = storage.get('z') or 0
local facing = storage.get('facing') or 1
storage.set('x', x)
storage.set('y', y)
storage.set('z', z)
storage.set('facing', facing)

function M.move(dir)
    if dir > 4 then
        if dir == 5 then
            if turtle.up() then
                change_xy(dir)
                return true
            end
        elseif dir == 6 then
            if turtle.down() then
                change_xy(dir)
                return true
            end
        end
    elseif math.abs(dir - facing) == 2 then
        if turtle.back() then
            local backwards = ((facing + 1) % 4) + 1
            change_xy(backwards)
            return true
        end
    else
        M.turn(dir)
        if turtle.forward() then
            change_xy(dir)
            return true
        end
    end
    return false
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
    storage.set('facing', facing)
end

function change_xy(dir)
    if dir == 1 then
        z = z + 1
    end
    if dir == 3 then
        z = z - 1
    end
    if dir == 2 then
        x = x + 1
    end
    if dir == 4 then
        x = x - 1
    end
    if dir == 5 then
        y = y + 1
    end
    if dir == 6 then
        y = y - 1
    end
    storage.set('x', x)
    storage.set('y', y)
    storage.set('z', z)
    print(x..' '..y..' '..z)
end

function M.getpos()
    return { x=y, y=y, z=z }
end

return M

-- for _, value in ipairs(args) do
--     print('Move: ' .. value .. ' from ' .. x .. ' ' .. y .. ' ' .. z)
--     move(tonumber(value))
--     print('Moved to ' .. x .. ' ' .. y .. ' ' .. z)
-- end
