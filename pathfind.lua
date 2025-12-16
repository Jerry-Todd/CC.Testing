-- astar.lua
local turt = require("move")
local area = require("area")
local storage = require("storage")

local M = {}

function Key(x, y, z)
    return x .. ',' .. y .. ',' .. z
end

function TKey(t)
    return Key(t.x, t.y, t.z)
end

function GetNeighbors(x, y, z)
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

function TGetNeighbors(t)
    return GetNeighbors(t.x, t.y, t.z)
end

function BuildGrid()
    local grid = {}
    for _, room in ipairs(area.rooms) do
        for y = room.close.y, room.far.y, 1 do
            for x = room.close.x, room.far.x, 1 do
                for z = room.close.z, room.far.z, 1 do
                    grid[Key(x, y, z)] = true
                end
            end
        end
    end
    for _, block in ipairs(area.blocks) do
        grid[TKey(block)] = false
    end
    return grid
end

function FindPath(grid, start, goal, ignoreGoal)
    if ignoreGoal then
        print('Ignoring goal')
    end
    local startKey = TKey(start)
    local goalKey = TKey(goal)
    if not grid[startKey] or (not grid[goalKey] and not ignoreGoal) then
        return nil
    end

    local queue = { start }
    local visited = { [startKey] = true }
    local parent = {}
    local current
    local goals = { [goalKey] = true }

    if ignoreGoal then
        local neighbors = TGetNeighbors(goal)
        for _, n in ipairs(neighbors) do
            if grid[TKey(n)] then
                goals[TKey(n)] = true
            end
        end
    end

    while #queue > 0 do
        current = table.remove(queue, 1)
        if goals[TKey(current)] then
            break
        end
        local neighbors = TGetNeighbors(current)
        for _, n in ipairs(neighbors) do
            if grid[TKey(n)] and not visited[TKey(n)] then
                table.insert(queue, n)
                visited[TKey(n)] = true
                parent[TKey(n)] = current
            end
        end
    end

    if not goals[TKey(current)] then
        return nil -- No path found
    end
    local path = {}
    while TKey(current) ~= startKey do
        table.insert(path, 1, current)
        current = parent[TKey(current)]
    end
    table.insert(path, 1, current)
    if ignoreGoal then
        table.insert(path, goal)
    end

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

function M.pathfind(goal, ignoreGoal)
    local start = turt.getpos()
    local position = start
    local grid = storage.get('grid') or BuildGrid()
    ::path::
    position = turt.getpos()
    local path = FindPath(grid, position, goal, ignoreGoal)
    if not path then
        print('Path not found')
        print('Going back to start')
        path = FindPath(grid, position, start, false)
        if not path then
            print('Cant get back to start :(')
            return
        end
    end
    local directions = pathToDirections(path)
    print('Moving...')
    for i, d in ipairs(directions) do
        if i == #directions and ignoreGoal then
            turt.turn(d)
            break
        end
        if not turt.move(d) then
            print('Path blocked at:', TKey(path[i + 1]))
            grid[TKey(path[i + 1])] = false
            storage.set('grid', grid)
            goto path
        end
    end
end

return M
