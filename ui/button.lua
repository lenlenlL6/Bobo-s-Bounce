local button = {}

function button:new(x, y, width, height, image)
    local obj = {
        x = x,
        y = y,
        width = width,
        height = height,
        image = image,
        isEnabled = true,
        isHovered = false,
        onClick = function() end
    }

    return setmetatable(obj, {__index = self})
end

function button:update()
    if not self.isEnabled then
        return
    end

    local mouseX, mouseY = love.mouse.getPosition()
    self.isHovered = mouseX >= self.x and mouseX <= self.x + self.width and
                     mouseY >= self.y and mouseY <= self.y + self.height
end

function button:draw()
    if not self.isEnabled then
        return
    end

    if self.isHovered then
        love.graphics.setColor(1, 1, 1, 0.7)
    end
    love.graphics.draw(self.image, self.x, self.y, 0, self.width/self.image:getWidth(), self.height/self.image:getHeight())
    love.graphics.setColor(1, 1, 1)
end

function button:mousepressed(x, y, button)
    if not self.isEnabled or button ~= 1 then
        return
    end

    if self.isHovered then
        self.onClick()
    end
end

function button:release()
    self.image:release()
end

return button