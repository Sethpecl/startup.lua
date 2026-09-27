local mon = peripheral.find("monitor")

if not mon then
    error("No monitor found")
end

mon.setTextScale(0.5)

local old = term.redirect(mon)
local w, h = term.getSize()

local x, y = math.floor(w/2), math.floor(h/2)
local dx, dy = 1, 1

local colorsList = {
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
    colors.pink
}

local ci = 1

local trail = {}

local function drawBall(x, y, c)
    paintutils.drawPixel(x, y - 1, c)
    paintutils.drawFilledBox(x - 1, y, x + 1, y, c)
    paintutils.drawPixel(x, y + 1, c)
end

while true do
    term.setBackgroundColor(colors.black)
    term.clear()

    -- title
    term.setTextColor(colors.white)
    term.setCursorPos(2, 1)
    term.write("SETH GRAPHICS DEMO")

    -- save trail
    table.insert(trail, 1, {x=x, y=y, c=colorsList[ci]})

    if #trail > 8 then
        table.remove(trail)
    end

    -- draw trail
    for i = #trail, 1, -1 do
        local p = trail[i]

        paintutils.drawPixel(
            p.x,
            p.y,
            p.c
        )
    end

    -- main ball
    drawBall(x, y, colorsList[ci])

    x = x + dx
    y = y + dy

    if x <= 2 or x >= w - 1 then
        dx = -dx
        ci = ci % #colorsList + 1
    end

    if y <= 3 or y >= h - 1 then
        dy = -dy
        ci = ci % #colorsList + 1
    end

    sleep(0.05)
end

term.redirect(old)
