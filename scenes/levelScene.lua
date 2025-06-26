local json = require("libs.json")
local button__ = require("ui.button")
local scene = {}

function scene:enter(previous, manager, scenes, ...)
    self.manager = manager
    self.scenes = scenes
    self.screenWidth, self.screenHeight = love.graphics.getWidth(), love.graphics.getHeight()

    love.graphics.setBackgroundColor(0.18, 0.18, 0.18)

    self.text = love.graphics.newText(love.graphics.getFont(), "LEVELS")

    if not love.filesystem.getInfo("playerData.json") then
        love.filesystem.write("playerData.json", json.encode({
            unlockedLevel = {1}
        }))
        self.unlockedLevel = {1}
    else
        self.unlockedLevel = json.decode(love.filesystem.read("playerData.json")).unlockedLevel
    end
    self.maxLevel = 2

    self.levelButtons = {}
    self.levelWidth = 81
    self.levelHeight = 82
    self.levelsPerRow = 4
    self.levelSpacing = 16
    self.levelStartY = 200

    local totalLevels = self.maxLevel
    local rows = math.ceil(totalLevels/self.levelsPerRow)
    local totalRowWidth = self.levelsPerRow*self.levelWidth + (self.levelsPerRow - 1)*self.levelSpacing
    local startX = (self.screenWidth - totalRowWidth)/2

    for i = 1, totalLevels do
        local row = math.floor((i - 1)/self.levelsPerRow)
        local col = (i - 1)%self.levelsPerRow

        local x = startX + col*(self.levelWidth + self.levelSpacing)
        local y = self.levelStartY + row*(self.levelHeight + self.levelSpacing)
    
        local imagePath = string.format("assets/Menu/Levels/%02d.png", i)
        local image = love.graphics.newImage(imagePath)
        local btn = button__:new(x, y, self.levelWidth, self.levelHeight, image)
        btn.locked = not table.contains(self.unlockedLevel, i)
        btn.onClick = function()
            self.manager:pop()
            self.manager:push(self.scenes.gameScene, self.manager, self.scenes, "levels/level" .. i .. ".lua")
        end
        table.insert(self.levelButtons, btn)
    end
end

function scene:leave(next, ...)
    self.text:release()
    self.text = nil
    for _, button in pairs(self.levelButtons) do
        button:release() 
    end
    self.levelButtons = nil
    self.levelWidth = nil
    self.levelHeight = nil
    self.levelsPerRow = nil
    self.levelSpacing = nil
    self.levelStartY = nil
end

function scene:update(dt)
    for _, button in pairs(self.levelButtons) do
        button:update()
    end
end

function scene:draw()
    love.graphics.draw(self.text, self.screenWidth/2 - self.text:getWidth()/2, 120)

    for _, btn in ipairs(self.levelButtons) do
        if btn.locked then
            love.graphics.setColor(0.3, 0.3, 0.3, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        btn:draw()
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function scene:mousepressed(x, y, button, istouch, presses)
    for i, btn in pairs(self.levelButtons) do
        if i > #self.unlockedLevel then
            return
        end

        btn:mousepressed(x, y, button)
    end
end

function table.contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

return scene