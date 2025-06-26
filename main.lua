love.graphics.setDefaultFilter("nearest", "nearest")
local manager = require("libs.roomy").new()
local scenes = {
    menuScene = require("scenes.menuScene"),
    levelScene = require("scenes.levelScene"),
    gameScene = require("scenes.gameScene")
}

local font = love.graphics.newFont("assets/MinecraftRegular-Bmg3.otf", 28)
local icon = love.image.newImageData("assets/icon.png")
love.graphics.setFont(font)
function love.load()
    love.window.setTitle("Bobo’s Bounce")
    love.window.setIcon(icon)
    -- love._openConsole()
    -- (scene, manager, scenes, ...)
    manager:push(scenes.menuScene, manager, scenes)
end

function love.update(dt)
    manager:emit("update", dt)
end

function love.draw()
    manager:emit("draw")

    love.graphics.print("FPS: " .. love.timer.getFPS())
end

function love.mousepressed(x, y, button, istouch, presses)
    manager:emit("mousepressed", x, y, button, istouch, presses)
end