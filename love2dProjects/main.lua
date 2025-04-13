local imageFiles = {}
local imagePool = {}
local imageRow = {}
local scrollX = 0
local totalWidth = 0
local screenWidth = 0

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
    if key == "right" then
        scrollX = scrollX - 50
    elseif key == "left" then
        scrollX = scrollX + 50
    end
end

function love.update(dt)
    if -scrollX + screenWidth > totalWidth then
        local nextImage = getNextImageFilename()
        appendImage(nextImage)
    end
end

function love.draw()
    local x = scrollX
    for _, entry in ipairs(imageRow) do
        love.graphics.draw(entry.image, x, 100)
        x = x + entry.image:getWidth()
    end
end
