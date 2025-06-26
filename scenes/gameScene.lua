local sti = require("libs.sti")
local wf = require("libs.windfield")
local json = require("libs.json")
local player__ = require("entities.player")
local fallingPlatform__ = require("entities.fallingPlatform")
local button__ = require("ui.button")
local scene = {}

local function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

local function levelIndex(path)
    local index = string.match(path, "level(%d+)%.lua")
    return tonumber(index)
end

function scene:enter(previous, manager, scenes, ...)
    self.manager = manager
    self.scenes = scenes
    self.screenWidth, self.screenHeight = love.graphics.getWidth(), love.graphics.getHeight()

    local args = {...}
    self.map = sti(args[1])
    self.path = args[1]
    self.background = love.graphics.newImage("assets/Background/" .. self.map.properties["background_color"] .. ".png")

    self.world = wf.newWorld(0, 1600, true)
    self.world:addCollisionClass("player")
    self.world:addCollisionClass("platform")
    for _, v in pairs(self.map.layers["Platform"].objects) do
        local collider = self.world:newRectangleCollider(v.x*2, v.y*2 - 32, v.width*2, v.height*2)
        collider:setType("static")
        collider:setCollisionClass("platform")
    end
    for _, v in pairs(self.map.layers["Border"].objects) do
        local collider = self.world:newRectangleCollider(v.x*2, v.y*2 - 32, v.width*2, v.height*2)
        collider:setType("static")
        collider:setCollisionClass("platform")
    end

    self.entities = {}
    for _, v in pairs(self.map.layers["Entities"].objects) do
        local fallingPlatform = fallingPlatform__:new(v.x*2, v.y*2 - 32, self.world)
        table.insert(self.entities, fallingPlatform)
    end

    self.destinationShader = love.graphics.newShader("shaders/destinationShader.glsl")
    local destinationInfo = self.map.layers["Destination"].objects[1]
    self.destinationRectangle = {
        x = destinationInfo.x*2,
        y = destinationInfo.y*2 - 32,
        width = destinationInfo.width*2,
        height = destinationInfo.height*2
    }
    self.destinationShader:send("position", {self.destinationRectangle.x, self.destinationRectangle.y})
    self.destinationShader:send("maxDistance", 100)

    local playerSpawnPoint = self.map.layers["Player"].objects[1]
    self.player = player__:new(playerSpawnPoint.x, playerSpawnPoint.y, self.world)

    self.buttons = {}
    self.buttons.quit = button__:new(10, self.screenHeight - 62, 51, 52, love.graphics.newImage("assets/Menu/Buttons/Restart.png"))
    self.buttons.quit.onClick = function()
        self.manager:push(self.scenes.menuScene, self.manager, self.scenes)
    end
    self.buttons.cQuit = button__:new(self.screenWidth/2 - 101 / 2, self.screenHeight/2 - 102/2, 101, 102, love.graphics.newImage("assets/Menu/Buttons/Restart.png"))
    self.buttons.cQuit.onClick = function()
        self.manager:push(self.scenes.menuScene, self.manager, self.scenes)
    end
    self.buttons.cQuit.isEnabled = false

    self.completed = false
    self.completedText = love.graphics.newText(love.graphics.getFont(), "LEVEL COMPLETED")
end

function scene:leave(next, ...)
    self.manager = nil
    self.scenes = nil
    self.map = nil
    self.path = nil
    self.background:release()
    self.background = nil
    self.world:destroy()
    self.world:release()
    self.world = nil
    self.destinationShader:release()
    self.destinationShader = nil
    self.destinationRectangle = nil
    self.player = nil
    for _, button in pairs(self.buttons) do
        button:release()
    end
    self.buttons = nil
    self.completed = nil
    self.completedText:release()
    self.completedText = nil
    self.entities = nil
end

function scene:update(dt)
    for _, button in pairs(self.buttons) do
        button:update()
    end

    if self.completed then
        return
    end

    self.map:update(dt)

    self.world:update(dt)
    self.player:update(dt)

    for i, entity in pairs(self.entities) do
        if entity.collider:isDestroyed() then
            table.remove(self.entities, i)
        else
            entity:update(dt)
        end
    end

    if distance(self.player.collider:getX(), self.player.collider:getY(), self.destinationRectangle.x + self.destinationRectangle.width/2, self.destinationRectangle.y) <= 30 then
        local playerData = json.decode(love.filesystem.read("playerData.json"))
        if #playerData.unlockedLevel == levelIndex(self.path) then
            table.insert(playerData.unlockedLevel, #playerData.unlockedLevel + 1)
            love.filesystem.write("playerData.json", json.encode(playerData))
        end
        
        self.buttons.quit.isEnabled = false
        self.buttons.cQuit.isEnabled = true
        self.completed = true
    end
end

function scene:draw()
    love.graphics.draw(self.background, 0, 0, 0, self.screenWidth/self.background:getWidth(), self.screenHeight/self.background:getHeight())
    self.map:draw(0, -16, 2, 2)
    self.player:draw()

    for _, entity in pairs(self.entities) do
        entity:draw()
    end

    -- self.world:draw()

    love.graphics.setColor(0.5, 1.0, 0.5, 0.6)
    love.graphics.setShader(self.destinationShader)
    love.graphics.rectangle("fill", self.destinationRectangle.x, self.destinationRectangle.y - 200, self.destinationRectangle.width, 200)
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1)

    for _, button in pairs(self.buttons) do
        button:draw()
    end

    if self.completed then
        love.graphics.setColor(0.5, 1.0, 0.5, 0.8)
        love.graphics.draw(self.completedText, self.screenWidth/2 - self.completedText:getWidth()/2, 100)
        love.graphics.setColor(1, 1, 1)
    end
end

function scene:mousepressed(x, y, button, istouch, presses)
    for _, btn in pairs(self.buttons) do
        btn:mousepressed(x, y, button)
    end
end

return scene