local moonshine = require("libs.moonshine")
local button__ = require("ui.button")
local scene = {}

function scene:enter(previous, manager, scenes, ...)
    self.manager = manager
    self.scenes = scenes
    self.screenWidth, self.screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    
    love.graphics.setBackgroundColor(0.18, 0.18, 0.18)

    self.text = love.graphics.newText(love.graphics.getFont(), "BOBOS BOUNCE")
    
    self.glowEffect = moonshine(moonshine.effects.glow)

    local padding = 10
    local x = self.screenWidth / 2 - self.text:getWidth() / 2
    local y = 120
    local w = self.text:getWidth()
    local h = self.text:getHeight()

    self.edges = {
        {x - padding, y - padding},
        {x + w + padding, y - padding},
        {x + w + padding, y + h + padding},
        {x - padding, y + h + padding},
    }
    self.timer = 0
    self.drawEdges = {}

    self.buttons = {}
    self.buttons.quit = button__:new(10, self.screenHeight - 62, 51, 52, love.graphics.newImage("assets/Menu/Buttons/Restart.png"))
    self.buttons.quit.onClick = function()
        love.event.quit()
    end
    self.buttons.play = button__:new(self.screenWidth/2 - 121/2, self.screenHeight/2 - 122/2, 121, 122, love.graphics.newImage("assets/Menu/Buttons/Play.png"))
    self.buttons.play.onClick = function()
        self.manager:pop()
        self.manager:push(self.scenes.levelScene, self.manager, self.scenes)
    end
end

function scene:leave(next, ...)
    self.text:release()
    self.text = nil
    self.glowEffect = nil
    self.edges = nil
    self.timer = nil
    self.drawEdges = nil
    for _, button in pairs(self.buttons) do
        button:release()
    end
    self.buttons = nil
end

function scene:update(dt)
    self.timer = self.timer + dt
    if self.timer >= 0.5 then
        self.timer = self.timer - 0.5

        local edgeCount = love.math.random(1, 4)
        local indices = {1, 2, 3, 4}
        for i = #indices, 2, -1 do
            local j = love.math.random(1, i)
            indices[i], indices[j] = indices[j], indices[i]
        end
        self.drawEdges = {}
        for i = 1, edgeCount do
            table.insert(self.drawEdges, indices[i])
        end
    end

    for _, button in pairs(self.buttons) do
        button:update()
    end
end

function scene:draw()
    love.graphics.draw(self.text, self.screenWidth/2 - self.text:getWidth()/2, 120)

    love.graphics.setLineWidth(2)
    self.glowEffect(function()
        for _, i in ipairs(self.drawEdges) do
            local p1 = self.edges[i]
            local p2 = self.edges[i%4 + 1]
            love.graphics.line(p1[1], p1[2], p2[1], p2[2])
        end
    end)
    love.graphics.setLineWidth(1)

    for _, button in pairs(self.buttons) do
        button:draw()
    end
end

function scene:mousepressed(x, y, button, istouch, presses)
    for _, btn in pairs(self.buttons) do
        btn:mousepressed(x, y, button)
    end
end

return scene