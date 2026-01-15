-- astar.lua
local turt = require("turtleutil")
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

function ManhattanDistance(a, b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y) + math.abs(a.z - b.z)
end

function InsertSorted(queue, node, priority)
    for i = 1, #queue do
        if priority < queue[i].priority then
            table.insert(queue, i, {node = node, priority = priority})
            return
        end
    end
    table.insert(queue, {node = node, priority = priority})
end

function FindPath(blockGrid, start, goal, ignoreGoal)
    if ignoreGoal then
        print('Ignoring goal')
    end
    local startKey = TKey(start)
    local goalKey = TKey(goal)
    if blockGrid[startKey] or (blockGrid[goalKey] and not ignoreGoal) then
        return nil
    end

    local queue = {}
    InsertSorted(queue, start, ManhattanDistance(start, goal))
    local visited = { [startKey] = true }
    local parent = {}
    local current
    local goals = { [goalKey] = true }

    if ignoreGoal then
        local neighbors = TGetNeighbors(goal)
        for _, n in ipairs(neighbors) do
            if not blockGrid[TKey(n)] then
                goals[TKey(n)] = true
            end
        end
    end

    while #queue > 0 do
        -- Check if any adjacent blocks are in the queue and prioritize them
        local currentPos = turt.getpos()
        local adjacentNeighbors = TGetNeighbors(currentPos)
        local foundAdjacent = false
        
        for i = 1, #queue do
            for _, neighbor in ipairs(adjacentNeighbors) do
                if TKey(queue[i].node) == TKey(neighbor) then
                    -- Found an adjacent block in queue, process it first
                    local item = table.remove(queue, i)
                    current = item.node
                    foundAdjacent = true
                    break
                end
            end
            if foundAdjacent then
                break
            end
        end
        
        -- If no adjacent blocks found, use normal priority order
        if not foundAdjacent then
            local item = table.remove(queue, 1)
            current = item.node
        end
        
        if goals[TKey(current)] then
            break
        end
        local neighbors = TGetNeighbors(current)
        for _, n in ipairs(neighbors) do
            if not blockGrid[TKey(n)] and not visited[TKey(n)] then
                local priority = ManhattanDistance(n, goal)
                InsertSorted(queue, n, priority)
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

function PathToDirections(path)
    local directions = {}

    for i = 2, #path, 1 do
        local dx = path[i].x - path[i - 1].x
        local dy = path[i].y - path[i - 1].y
        local dz = path[i].z - path[i - 1].z

        if dx == 1 then
            table.insert(directions, 2) -- East
        elseif dx == -1 then
            table.insert(directions, 4) -- West
        elseif dz == -1 then
            table.insert(directions, 1) -- North
        elseif dz == 1 then
            table.insert(directions, 3) -- South
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
    local blockGrid = storage.get('grid') or {}
    ::path::
    local position = turt.getpos()
    local path = FindPath(blockGrid, position, goal, ignoreGoal)
    if not path then
        print('Path not found')
        print('Going back to start')
        path = FindPath(blockGrid, position, start, false)
        if not path then
            print('Cant get back to start :(')
            return
        end
    end
    local directions = PathToDirections(path)
    print('Moving...')
    for i, d in ipairs(directions) do
        if i == #directions and ignoreGoal then
            turt.turn(d)
            break
        end
        if not turt.move(d) then
            print('Path blocked at:', TKey(path[i + 1]))
            blockGrid[TKey(path[i + 1])] = true
            storage.set('grid', blockGrid)
            goto path
        end
    end
end

return M
