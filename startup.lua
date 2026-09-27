local mon = peripheral.find("monitor")

if not mon then
    error("No monitor found!")
end

mon.setTextScale(0.5)

local W, H = mon.getSize()

local bg = colors.black
local fg = colors.white
local accent = colors.lime
local button = colors.gray
local inputColor = colors.lightGray

local function clear()
    mon.setBackgroundColor(bg)
    mon.setTextColor(fg)
    mon.clear()
end

local function center(y, text)
    local x = math.max(1, math.floor((W - #text) / 2) + 1)
    mon.setCursorPos(x, y)
    mon.write(text)
end

local function drawButton(x1, y1, x2, y2, text, color)
    color = color or button

    mon.setBackgroundColor(color)
    mon.setTextColor(colors.white)

    for y = y1, y2 do
        mon.setCursorPos(x1, y)
        mon.write(string.rep(" ", x2 - x1 + 1))
    end

    local tx = x1 + math.floor(((x2 - x1 + 1) - #text) / 2)
    local ty = y1 + math.floor((y2 - y1) / 2)

    mon.setCursorPos(tx, ty)
    mon.write(text)

    mon.setBackgroundColor(bg)
end

local function inside(x, y, x1, y1, x2, y2)
    return x >= x1 and x <= x2 and y >= y1 and y <= y2
end

-------------------------------------------------
-- ON SCREEN KEYBOARD
-------------------------------------------------

local function keyboard(title)
    local text = ""

    local rows = {
        "1234567890",
        "QWERTYUIOP",
        "ASDFGHJKL",
        "ZXCVBNM"
    }

    while true do
        clear()

        mon.setTextColor(accent)
        center(2, title)

        mon.setTextColor(colors.black)
        mon.setBackgroundColor(inputColor)

        mon.setCursorPos(3, 4)
        mon.write(string.rep(" ", W - 4))

        mon.setCursorPos(4, 4)

        local display = text

        if #display > W - 7 then
            display = display:sub(-(W - 7))
        end

        mon.write(display)

        mon.setBackgroundColor(bg)

        local keyboardStart = 7

        for rowIndex, row in ipairs(rows) do
            local y = keyboardStart + ((rowIndex - 1) * 3)

            local totalWidth = #row * 4
            local startX = math.floor((W - totalWidth) / 2) + 1

            for i = 1, #row do
                local char = row:sub(i, i)

                local x = startX + ((i - 1) * 4)

                drawButton(x, y, x + 2, y + 1, char)
            end
        end

        local bottom = keyboardStart + (#rows * 3)

        drawButton(3, bottom, 12, bottom + 1, "SPACE")
        drawButton(14, bottom, 22, bottom + 1, "BACK")
        drawButton(24, bottom, 34, bottom + 1, "CLEAR")
        drawButton(W - 13, bottom, W - 2, bottom + 1, "SEARCH", accent)

        local _, side, x, y = os.pullEvent("monitor_touch")

        for rowIndex, row in ipairs(rows) do
            local ky = keyboardStart + ((rowIndex - 1) * 3)

            local totalWidth = #row * 4
            local startX = math.floor((W - totalWidth) / 2) + 1

            for i = 1, #row do
                local kx = startX + ((i - 1) * 4)

                if inside(x, y, kx, ky, kx + 2, ky + 1) then
                    text = text .. row:sub(i, i):lower()
                end
            end
        end

        if inside(x, y, 3, bottom, 12, bottom + 1) then
            text = text .. " "

        elseif inside(x, y, 14, bottom, 22, bottom + 1) then
            text = text:sub(1, -2)

        elseif inside(x, y, 24, bottom, 34, bottom + 1) then
            text = ""

        elseif inside(x, y, W - 13, bottom, W - 2, bottom + 1) then
            if text ~= "" then
                return text
            end
        end
    end
end

-------------------------------------------------
-- MODRINTH SEARCH
-------------------------------------------------

local function modSearch()
    local query = keyboard("MODRINTH SEARCH")

    clear()

    mon.setTextColor(accent)
    center(2, "Searching for: " .. query)

    local url =
        "https://api.modrinth.com/v2/search?limit=8&query="
        .. textutils.urlEncode(query)

    local response, err = http.get(url)

    if not response then
        mon.setTextColor(colors.red)

        center(5, "HTTP REQUEST FAILED")

        mon.setTextColor(colors.white)

        mon.setCursorPos(2, 7)
        mon.write(tostring(err))

        drawButton(3, H - 2, 12, H - 1, "BACK")

        while true do
            local _, _, x, y = os.pullEvent("monitor_touch")

            if inside(x, y, 3, H - 2, 12, H - 1) then
                return
            end
        end
    end

    local raw = response.readAll()
    response.close()

    local data = textutils.unserializeJSON(raw)

    clear()

    mon.setTextColor(accent)
    center(1, "RESULTS: " .. query)

    mon.setTextColor(colors.white)

    local y = 3

    if not data or not data.hits then
        center(5, "No results.")
    else
        for i, result in ipairs(data.hits) do
            if y > H - 4 then
                break
            end

            mon.setTextColor(colors.yellow)

            mon.setCursorPos(2, y)
            mon.write(i .. ". " .. result.title)

            y = y + 1

            mon.setTextColor(colors.lightGray)

            local desc = result.description or ""

            if #desc > W - 4 then
                desc = desc:sub(1, W - 7) .. "..."
            end

            mon.setCursorPos(4, y)
            mon.write(desc)

            y = y + 2
        end
    end

    drawButton(3, H - 2, 12, H - 1, "BACK")

    while true do
        local _, _, x, ty = os.pullEvent("monitor_touch")

        if inside(x, ty, 3, H - 2, 12, H - 1) then
            return
        end
    end
end

-------------------------------------------------
-- SIMPLE INFORMATION PAGE
-------------------------------------------------

local function infoPage(title, message)
    clear()

    mon.setTextColor(accent)
    center(2, title)

    mon.setTextColor(colors.white)
    center(5, message)

    drawButton(3, H - 2, 12, H - 1, "BACK")

    while true do
        local _, _, x, y = os.pullEvent("monitor_touch")

        if inside(x, y, 3, H - 2, 12, H - 1) then
            return
        end
    end
end

-------------------------------------------------
-- HOME SCREEN
-------------------------------------------------

local function home()
    while true do
        clear()

        mon.setTextColor(accent)

        center(2, "=== SETH OS ===")

        mon.setTextColor(colors.lightGray)

        center(4, "Industrial Control System")

        local half = math.floor(W / 2)

        drawButton(3, 7, half - 2, 10, "MOD SEARCH", colors.blue)
        drawButton(half + 2, 7, W - 3, 10, "AE2 STORAGE", colors.purple)

        drawButton(3, 12, half - 2, 15, "FACTORY", colors.orange)
        drawButton(half + 2, 12, W - 3, 15, "JET CONTROL", colors.red)

        drawButton(3, 17, half - 2, 20, "POWER", colors.green)
        drawButton(half + 2, 17, W - 3, 20, "PERIPHERALS", colors.gray)

        mon.setTextColor(colors.gray)
        center(H, "Touch a button")

        local _, _, x, y = os.pullEvent("monitor_touch")

        if inside(x, y, 3, 7, half - 2, 10) then

            modSearch()

        elseif inside(x, y, half + 2, 7, W - 3, 10) then

            infoPage(
                "AE2 STORAGE",
                "ME Bridge integration comes next."
            )

        elseif inside(x, y, 3, 12, half - 2, 15) then

            infoPage(
                "FACTORY",
                "Create control system coming soon."
            )

        elseif inside(x, y, half + 2, 12, W - 3, 15) then

            infoPage(
                "JET CONTROL",
                "Avionics integration coming soon."
            )

        elseif inside(x, y, 3, 17, half - 2, 20) then

            infoPage(
                "POWER",
                "Powah / Mekanism monitoring coming soon."
            )

        elseif inside(x, y, half + 2, 17, W - 3, 20) then

            clear()

            mon.setTextColor(accent)
            center(2, "CONNECTED PERIPHERALS")

            mon.setTextColor(colors.white)

            local names = peripheral.getNames()

            local py = 4

            for _, name in ipairs(names) do
                if py >= H - 2 then
                    break
                end

                mon.setCursorPos(3, py)

                local ptype = peripheral.getType(name)

                mon.write(name .. " : " .. tostring(ptype))

                py = py + 1
            end

            drawButton(3, H - 2, 12, H - 1, "BACK")

            while true do
                local _, _, bx, by = os.pullEvent("monitor_touch")

                if inside(bx, by, 3, H - 2, 12, H - 1) then
                    break
                end
            end
        end
    end
end

home()
