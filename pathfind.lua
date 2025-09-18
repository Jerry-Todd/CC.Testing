-- astar.lua
local turt = require("move")
local area = require("area")

local M = {}

function key(x, y, z)
    return x .. ',' .. y .. ',' .. z
end
function tKey(t)
    return key(t.x, t.y, t.z)
end

function getNeighbors(x, y, z)
    local neighbors = {}
    table.insert(neighbors, {
        x = x + 1,
        y = y,
        z = z
    })
    table.insert(neighbors, {
        x = x - 1,
        y = y,
        z = z
    })
    table.insert(neighbors, {
        x = x,
        y = y + 1,
        z = z
    })
    table.insert(neighbors, {
        x = x,
        y = y - 1,
        z = z
    })
    table.insert(neighbors, {
        x = x,
        y = y,
        z = z + 1
    })
    table.insert(neighbors, {
        x = x,
        y = y,
        z = z - 1
    })
    return neighbors
end

function tGetNeighbors(t)
    return getNeighbors(t.x, t.y, t.z)
end

function buildGrid()
    local grid = {}
    for _, room in ipairs(area.rooms) do
        for y = room.close.y, room.far.y, 1 do
            for x = room.close.x, room.far.x, 1 do
                for z = room.close.z, room.far.z, 1 do
                    grid[x .. ',' .. y .. ',' .. z] = true
                end
            end
        end
    end
    for _, block in ipairs(area.blocks) do
        grid[block.x .. ',' .. block.y .. ',' .. block.z] = false
    end
    return grid
end

function findPath(grid, start, goal, isTarget)
    isTarget = isTarget or false
    local startKey = tKey(start)
    local goalKey = tKey(goal)
    if not grid[startKey] or not grid[goalKey] then
        return nil
    end

    local queue = {start}
    local visited = {}
    visited[startKey] = true
    local parent = {}
    local current
    local found = false
    local targetKeys = {[goalKey] = true}

    -- If isTarget, add all walkable neighbors of goal as valid targets
    if isTarget then
        local neighbors = tGetNeighbors(goal)
        for _, n in ipairs(neighbors) do
            local nKey = tKey(n)
            if grid[nKey] then
                targetKeys[nKey] = true
            end
        end
    end

    while #queue > 0 do
        current = table.remove(queue, 1)
        if targetKeys[tKey(current)] then
            found = true
            break
        end
        local neighbors = tGetNeighbors(current)
        for _, n in ipairs(neighbors) do
            local nKey = tKey(n)
            if grid[nKey] and not visited[nKey] then
                table.insert(queue, n)
                visited[nKey] = true
                parent[nKey] = current
            end
        end
    end

    if not found then
        return nil -- No path found
    end
    local path = {}
    while tKey(current) ~= startKey do
        table.insert(path, 1, current)
        current = parent[tKey(current)]
    end
    table.insert(path, 1, current)

    return path
end

function pathToDirections(path)
    local directions = {}

    for i = 2, #path, 1 do
        local dx = path[i].x - path[i - 1].x
        local dy = path[i].y - path[i - 1].y
        local dz = path[i].z - path[i - 1].z

        if dx == 1 then
            table.insert(directions, 2)
        elseif dx == -1 then
            table.insert(directions, 4)
        elseif dz == 1 then
            table.insert(directions, 1)
        elseif dz == -1 then
            table.insert(directions, 3)
        elseif dy == 1 then
            table.insert(directions, 5)
        elseif dy == -1 then
            table.insert(directions, 6)
        end

    end

    return directions
end

function M.pathfind(goal, isTarget)
    isTarget = isTarget or false
    local start = turt.getpos()
    local grid = buildGrid()
    local path = findPath(grid, start, goal)
    if not path then
        print('path not found')
        return
    end
    local directions = pathToDirections(path)
    print('Moving...')
    for i, d in ipairs(directions) do
        if i ~= d then
            turt.move(d)
        else
            turt.turn(d)
        end
    end
end

return M
