local mon = peripheral.find("monitor")

if not mon then
    error("No monitor found")
end

mon.setTextScale(0.5)

local old = term.redirect(mon)

local w, h = term.getSize()

local x, y = 2, 2
local dx, dy = 1, 1

local boxW = 6
local boxH = 3

local colours = {
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

local colourIndex = 1

term.setBackgroundColor(colors.black)
term.clear()

while true do
    term.setBackgroundColor(colors.black)
    term.clear()

    local col = colours[colourIndex]

    paintutils.drawFilledBox(
        x,
        y,
        x + boxW,
        y + boxH,
        col
    )

    x = x + dx
    y = y + dy

    if x <= 1 then
        x = 1
        dx = 1
        colourIndex = colourIndex % #colours + 1
    elseif x + boxW >= w then
        x = w - boxW
        dx = -1
        colourIndex = colourIndex % #colours + 1
    end

    if y <= 1 then
        y = 1
        dy = 1
        colourIndex = colourIndex % #colours + 1
    elseif y + boxH >= h then
        y = h - boxH
        dy = -1
        colourIndex = colourIndex % #colours + 1
    end

    sleep(0.05)
end

term.redirect(old)
