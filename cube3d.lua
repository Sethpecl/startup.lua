-- Seth's Tom's Peripherals 3D Cube
-- Auto-detects the tm_gpu and uses your monitor's current resolution.

local gpu = peripheral.find("tm_gpu")

if not gpu then
    error("Tom's GPU not found!")
end

-- Make sure monitor dimensions are updated
gpu.refreshSize()
sleep(0.1)

local w, h = gpu.getSize()

if w == 0 or h == 0 then
    error("GPU cannot see the monitor wall!")
end

print("GPU display: " .. w .. "x" .. h)

-- Create 3D window across the whole display
local gl = gpu.createWindow3D(0, 0, w, h)

-- Camera
gl.glFrustum(70, 0.1, 100)
gl.glDirLight(0, 0, -1)

-- Cube made from 12 triangles.
-- Coordinates are centred around 0 so it rotates around its centre.
local faces = {
    -- FRONT - red
    {
        color = {255, 50, 50},
        tris = {
            {-1,-1,-1,  1,-1,-1,  1, 1,-1},
            {-1,-1,-1,  1, 1,-1, -1, 1,-1},
        }
    },

    -- BACK - green
    {
        color = {50, 255, 50},
        tris = {
            {-1,-1, 1, -1, 1, 1,  1, 1, 1},
            {-1,-1, 1,  1, 1, 1,  1,-1, 1},
        }
    },

    -- LEFT - blue
    {
        color = {50, 100, 255},
        tris = {
            {-1,-1,-1, -1, 1,-1, -1, 1, 1},
            {-1,-1,-1, -1, 1, 1, -1,-1, 1},
        }
    },

    -- RIGHT - yellow
    {
        color = {255, 220, 40},
        tris = {
            {1,-1,-1, 1,-1, 1, 1, 1, 1},
            {1,-1,-1, 1, 1, 1, 1, 1,-1},
        }
    },

    -- TOP - cyan
    {
        color = {50, 255, 255},
        tris = {
            {-1,1,-1, 1,1,-1, 1,1,1},
            {-1,1,-1, 1,1,1, -1,1,1},
        }
    },

    -- BOTTOM - magenta
    {
        color = {255, 50, 255},
        tris = {
            {-1,-1,-1, -1,-1,1, 1,-1,1},
            {-1,-1,-1, 1,-1,1, 1,-1,-1},
        }
    },
}

local rotX = 0
local rotY = 0
local rotZ = 0

while true do
    gl.clear()

    -- Disable texturing
    gl.glDisable(0x0DE1)

    -- Move cube away from camera
    gl.glTranslate(0, 0, 5)

    -- Rotate it
    gl.glRotate(rotX, 1, 0, 0)
    gl.glRotate(rotY, 0, 1, 0)
    gl.glRotate(rotZ, 0, 0, 1)

    -- Tom's default glBegin() mode is triangles
    gl.glBegin()

    for _, face in ipairs(faces) do
        local c = face.color

        gl.glColor(c[1], c[2], c[3])

        for _, t in ipairs(face.tris) do
            gl.glVertex(t[1], t[2], t[3])
            gl.glVertex(t[4], t[5], t[6])
            gl.glVertex(t[7], t[8], t[9])
        end
    end

    gl.glEnd()

    -- Render 3D -> window -> physical monitor
    gl.render()
    gl.sync()
    gpu.sync()

    rotX = (rotX + 1.3) % 360
    rotY = (rotY + 2.0) % 360
    rotZ = (rotZ + 0.7) % 360

    sleep(0.05)
end
