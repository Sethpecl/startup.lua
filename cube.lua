local mon = peripheral.find("monitor")

if not mon then
    error("No monitor found")
end

local oldTerm = term.current()
term.redirect(mon)

local function cleanup()
    pcall(function()
        term.setGraphicsMode(false)
    end)
    term.redirect(oldTerm)
end

local function rotateX(p, a)
    local c = math.cos(a)
    local s = math.sin(a)

    return {
        x = p.x,
        y = p.y * c - p.z * s,
        z = p.y * s + p.z * c
    }
end

local function rotateY(p, a)
    local c = math.cos(a)
    local s = math.sin(a)

    return {
        x = p.x * c + p.z * s,
        y = p.y,
        z = -p.x * s + p.z * c
    }
end

local function rotateZ(p, a)
    local c = math.cos(a)
    local s = math.sin(a)

    return {
        x = p.x * c - p.y * s,
        y = p.x * s + p.y * c,
        z = p.z
    }
end

local function drawLine(x0, y0, x1, y1, color)
    x0 = math.floor(x0)
    y0 = math.floor(y0)
    x1 = math.floor(x1)
    y1 = math.floor(y1)

    local dx = math.abs(x1 - x0)
    local sx = x0 < x1 and 1 or -1
    local dy = -math.abs(y1 - y0)
    local sy = y0 < y1 and 1 or -1
    local err = dx + dy

    while true do
        pcall(term.setPixel, x0, y0, color)

        if x0 == x1 and y0 == y1 then
            break
        end

        local e2 = 2 * err

        if e2 >= dy then
            err = err + dy
            x0 = x0 + sx
        end

        if e2 <= dx then
            err = err + dx
            y0 = y0 + sy
        end
    end
end

local vertices = {
    {x=-1, y=-1, z=-1},
    {x= 1, y=-1, z=-1},
    {x= 1, y= 1, z=-1},
    {x=-1, y= 1, z=-1},

    {x=-1, y=-1, z= 1},
    {x= 1, y=-1, z= 1},
    {x= 1, y= 1, z= 1},
    {x=-1, y= 1, z= 1}
}

local edges = {
    {1,2},{2,3},{3,4},{4,1},
    {5,6},{6,7},{7,8},{8,5},
    {1,5},{2,6},{3,7},{4,8}
}

local edgeColors = {
    colors.red,
    colors.orange,
    colors.yellow,
    colors.lime,
    colors.green,
    colors.cyan,
    colors.lightBlue,
    colors.blue,
    colors.purple,
    colors.magenta,
    colors.pink,
    colors.white
}

local function main()
    -- CC: Graphics 16-colour pixel mode
    term.setGraphicsMode(1)

    local w, h = term.getSize(1)

    local cx = math.floor(w / 2)
    local cy = math.floor(h / 2)

    local angleX = 0
    local angleY = 0
    local angleZ = 0

    while true do
        if term.setFrozen then
            term.setFrozen(true)
        end

        term.setBackgroundColor(colors.black)
        term.clear()

        local projected = {}

        for i, point in ipairs(vertices) do
            local p = rotateX(point, angleX)
            p = rotateY(p, angleY)
            p = rotateZ(p, angleZ)

            -- move cube away from camera
            local cameraZ = p.z + 4

            -- perspective projection
            local scale = math.min(w, h) * 0.55

            projected[i] = {
                x = cx + (p.x / cameraZ) * scale,
                y = cy + (p.y / cameraZ) * scale
            }
        end

        for i, edge in ipairs(edges) do
            local a = projected[edge[1]]
            local b = projected[edge[2]]

            drawLine(
                a.x,
                a.y,
                b.x,
                b.y,
                edgeColors[i]
            )
        end

        -- little center marker
        for dx = -1, 1 do
            for dy = -1, 1 do
                pcall(term.setPixel, cx + dx, cy + dy, colors.white)
            end
        end

        if term.setFrozen then
            term.setFrozen(false)
        end

        angleX = angleX + 0.025
        angleY = angleY + 0.04
        angleZ = angleZ + 0.012

        sleep(0.03)
    end
end

local ok, err = pcall(main)

cleanup()

if not ok and err ~= "Terminated" then
    printError(err)
end
