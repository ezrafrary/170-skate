local imageFiles = {}
local imagePool = {}
local imageRow = {}
local scrollX = 0
local totalWidth = 0
local screenWidth = 0
local backwardScrollCount = 0 
local forceReset = false 
local illiterateTitle = false 
local rainbowHue = 0 

-- Your follow rules here
local followRules = {
    ["prototype1_high_high.png"] = {"prototype1_high_high.png", "prototype1_high_low.png", "prototype1_high_med.png"},
    ["prototype1_high_med.png"] = {"prototype1_med_high.png", "prototype1_med_med.png", "prototype1_med_low.png"},
    ["prototype1_high_low.png"] = {"prototype1_low_high.png", "prototype1_low_med.png", "prototype1_low_low.png"},
    ["prototype1_med_high.png"] = {"prototype1_high_high.png", "prototype1_high_low.png", "prototype1_high_med.png"},
    ["prototype1_med_med.png"] = {"prototype1_med_high.png", "prototype1_med_med.png", "prototype1_med_low.png"},
    ["prototype1_med_low.png"] = {"prototype1_low_high.png", "prototype1_low_med.png", "prototype1_low_low.png"},
    ["prototype1_low_high.png"] = {"prototype1_high_high.png", "prototype1_high_low.png", "prototype1_high_med.png"},
    ["prototype1_low_med.png"] = {"prototype1_med_high.png", "prototype1_med_med.png", "prototype1_med_low.png"},
    ["prototype1_low_low.png"] = {"prototype1_low_high.png", "prototype1_low_med.png", "prototype1_low_low.png"},
}

function love.load()
    love.math.setRandomSeed(os.time())
    screenWidth = love.graphics.getWidth()

    -- Load all image filenames from /images
    local files = love.filesystem.getDirectoryItems("images")
    for _, file in ipairs(files) do
        if file:match("%.png$") or file:match("%.jpg$") or file:match("%.jpeg$") then
            table.insert(imageFiles, file)
        end
    end

    -- Start with a random image
    local first = imageFiles[love.math.random(#imageFiles)]
    appendImage(first)
end

function appendImage(filename)
    local img = love.graphics.newImage("images/" .. filename)
    table.insert(imageRow, { name = filename, image = img })
    totalWidth = totalWidth + img:getWidth()
end

function getNextImageFilename()
    if #imageRow == 0 then
        return imageFiles[love.math.random(#imageFiles)]
    end

    local last = imageRow[#imageRow].name
    local options = followRules[last]

    if options and #options > 0 then
        return options[love.math.random(#options)]
    else
        -- fallback to any image if no rule exists
        return imageFiles[love.math.random(#imageFiles)]
    end
end

function love.keypressed(key)
    if forceReset then
        backwardScrollCount = 0
        if key == "left" and backwardScrollCount >= 0 then
            return -- Prevent scrolling left beyond the start
        end
    end
    if key == "right" then
        if scrollX == 0 then
            backwardScrollCount = 0
        elseif scrollX < 0 then
            backwardScrollCount = 0
        elseif scrollX > 0 then
            backwardScrollCount = backwardScrollCount - 1
        end
        scrollX = scrollX - 50
        
    elseif key == "left" then
        if scrollX == 0 then
            backwardScrollCount = 0
        elseif scrollX < 0 then
            backwardScrollCount = 0
        elseif scrollX > 0 then
            backwardScrollCount = backwardScrollCount + 1
        end
        scrollX = scrollX + 50
    
    end
end

function love.update(dt)
    if -scrollX + screenWidth > totalWidth then
        local nextImage = getNextImageFilename()
        appendImage(nextImage)
    end

    -- Force reset if backward scroll count exceeds a threshold
    if backwardScrollCount > 20 then
        scrollX = 0
        forceReset = true
        illiterateTitle = true
    end

    rainbowHue = (rainbowHue + dt * 50) % 360
end

function love.draw()
    local x = scrollX
    for _, entry in ipairs(imageRow) do
        love.graphics.draw(entry.image, x, 100)
        x = x + entry.image:getWidth()
    end

    -- Display messages based on backward scroll count
    if scrollX > 0 then
        love.graphics.setColor(1, 1, 1) 
        if backwardScrollCount < 5 then
            love.graphics.print("Why are you scrolling backward?", 10, 10)
        elseif backwardScrollCount < 10 then
            love.graphics.print("Seriously, there's nothing here.", 10, 50)
        elseif backwardScrollCount < 15 then
            love.graphics.print("Look, it's just the void, there's -nothing- totally rad past this point.", 10, 100)
        elseif backwardScrollCount < 20 then
            love.graphics.print("Fine, you know what, keep going then.", 10, 150)
        else
            love.graphics.print("How about an award? Title of ILLITERATE.", 10, 200)
        end
        love.graphics.setColor(1, 1, 1, 1) 
    end

    -- Permanently display "ILLITERATE" if forced reset
    if illiterateTitle then
        local r, g, b = hslToRgb(rainbowHue / 360, 1, 0.5) 
        love.graphics.setColor(r, g, b) 
        love.graphics.print("ILLITERATE", screenWidth / 2 - 50, 10) 
        love.graphics.setColor(1, 1, 1, 1) 
    end
end

-- Helper function to convert HSL to RGB
function hslToRgb(h, s, l)
    if s == 0 then return l, l, l end
    local function hueToRgb(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < 1 / 6 then return p + (q - p) * 6 * t end
        if t < 1 / 2 then return q end
        if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
        return p
    end
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    return hueToRgb(p, q, h + 1 / 3), hueToRgb(p, q, h), hueToRgb(p, q, h - 1 / 3)
end
