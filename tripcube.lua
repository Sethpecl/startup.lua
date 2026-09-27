-- SETH'S TRIPPY 3D INFINITY CUBE
-- Tom's Peripherals GPU
-- Auto scales to the monitor wall

local gpu = peripheral.find("tm_gpu")

if not gpu then
    error("Tom's GPU not found!")
end

gpu.refreshSize()
sleep(0.1)

local w, h = gpu.getSize()

if w == 0 or h == 0 then
    error("GPU cannot see monitor wall!")
end

print("Display: " .. w .. "x" .. h)

local gl = gpu.createWindow3D(0, 0, w, h)

gl.glFrustum(70, 0.1, 100)
gl.glDirLight(0, 0, -1)

local palette = {
    {255, 40, 40},
    {255, 120, 20},
    {255, 230, 30},
    {80, 255, 40},
    {30, 255, 180},
    {30, 220, 255},
    {60, 100, 255},
    {170, 60, 255},
    {255, 50, 220},
    {255, 80, 150},
}

--------------------------------------------------
-- 3D ROTATION
--------------------------------------------------

local function rotate(x, y, z, ax, ay, az)

    -- X
    local cx = math.cos(ax)
    local sx = math.sin(ax)

    local y1 = y * cx - z * sx
    local z1 = y * sx + z * cx

    y = y1
    z = z1

    -- Y
    local cy = math.cos(ay)
    local sy = math.sin(ay)

    local x1 = x * cy + z * sy
    local z2 = -x * sy + z * cy

    x = x1
    z = z2

    -- Z
    local cz = math.cos(az)
    local sz = math.sin(az)

    local x2 = x * cz - y * sz
    local y2 = x * sz + y * cz

    return x2, y2, z
end

--------------------------------------------------
-- DRAW RECTANGULAR PRISM
--------------------------------------------------

local function box(
    cx, cy, cz,
    sx, sy, sz,
    ax, ay, az,
    tx, ty, tz,
    r, g, b
)

    local hx = sx / 2
    local hy = sy / 2
    local hz = sz / 2

    local verts = {
        {-hx,-hy,-hz},
        { hx,-hy,-hz},
        { hx, hy,-hz},
        {-hx, hy,-hz},

        {-hx,-hy, hz},
        { hx,-hy, hz},
        { hx, hy, hz},
        {-hx, hy, hz},
    }

    local faces = {
        {1,2,3}, {1,3,4},
        {5,7,6}, {5,8,7},

        {1,4,8}, {1,8,5},
        {2,6,7}, {2,7,3},

        {1,5,6}, {1,6,2},
        {4,3,7}, {4,7,8},
    }

    local transformed = {}

    for i, v in ipairs(verts) do

        local x = v[1] + cx
        local y = v[2] + cy
        local z = v[3] + cz

        x, y, z = rotate(
            x, y, z,
            ax, ay, az
        )

        transformed[i] = {
            x + tx,
            y + ty,
            z + tz
        }
    end

    gl.glColor(r, g, b)

    for _, f in ipairs(faces) do

        local a = transformed[f[1]]
        local b = transformed[f[2]]
        local c = transformed[f[3]]

        gl.glVertex(a[1], a[2], a[3])
        gl.glVertex(b[1], b[2], b[3])
        gl.glVertex(c[1], c[2], c[3])
    end
end

--------------------------------------------------
-- HOLLOW CUBE FRAME
--------------------------------------------------

local function cubeFrame(
    half,
    thickness,
    ax, ay, az,
    tx, ty, tz,
    r, g, b
)

    local full = half * 2

    -- X edges
    for _, y in ipairs({-half, half}) do
        for _, z in ipairs({-half, half}) do

            box(
                0, y, z,
                full, thickness, thickness,
                ax, ay, az,
                tx, ty, tz,
                r, g, b
            )

        end
    end

    -- Y edges
    for _, x in ipairs({-half, half}) do
        for _, z in ipairs({-half, half}) do

            box(
                x, 0, z,
                thickness, full, thickness,
                ax, ay, az,
                tx, ty, tz,
                r, g, b
            )

        end
    end

    -- Z edges
    for _, x in ipairs({-half, half}) do
        for _, y in ipairs({-half, half}) do

            box(
                x, y, 0,
                thickness, thickness, full,
                ax, ay, az,
                tx, ty, tz,
                r, g, b
            )

        end
    end
end

--------------------------------------------------
-- ANIMATION
--------------------------------------------------

local layers = 9

while true do

    local t = os.clock()

    gl.clear()

    -- disable textures
    gl.glDisable(0x0DE1)

    gl.glBegin()

    for i = 1, layers do

        ------------------------------------------------
        -- MOVING DEPTH
        ------------------------------------------------

        local slot =
            ((i - 1) + t * 0.55)
            % layers

        local depth =
            4 + slot * 1.55

        ------------------------------------------------
        -- PERSPECTIVE SIZE
        --
        -- farther cubes are physically larger,
        -- which makes the tunnel feel endless
        ------------------------------------------------

        local half =
            depth * 0.28

        ------------------------------------------------
        -- BREATHING / PULSING
        ------------------------------------------------

        half =
            half *
            (1 + math.sin(t * 2.4 + i) * 0.07)

        ------------------------------------------------
        -- ROTATION
        ------------------------------------------------

        local ax =
            t * 0.45 +
            i * 0.20

        local ay =
            t * 0.65 +
            i * 0.35

        local az =
            t * 0.30 -
            i * 0.15

        ------------------------------------------------
        -- LITTLE SIDEWAYS WOBBLE
        ------------------------------------------------

        local x =
            math.sin(t * 1.2 + i * 0.7)
            * 0.18

        local y =
            math.cos(t * 1.0 + i * 0.9)
            * 0.18

        ------------------------------------------------
        -- RAINBOW SHIFT
        ------------------------------------------------

        local ci =
            ((i + math.floor(t * 4))
            % #palette) + 1

        local col =
            palette[ci]

        ------------------------------------------------
        -- EDGE THICKNESS
        ------------------------------------------------

        local thickness =
            math.max(
                0.045,
                half * 0.045
            )

        cubeFrame(
            half,
            thickness,

            ax,
            ay,
            az,

            x,
            y,
            depth,

            col[1],
            col[2],
            col[3]
        )
    end

    gl.glEnd()

    gl.render()
    gl.sync()
    gpu.sync()

    sleep(0.04)
end
