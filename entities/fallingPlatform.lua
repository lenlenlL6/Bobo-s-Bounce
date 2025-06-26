local anim8 = require("libs.anim8")
local fallingPlatform = {}

local onImage = love.graphics.newImage("assets/Traps/Falling Platforms/On (32x10).png")
local grid = anim8.newGrid(32, 10, onImage:getWidth(), onImage:getHeight())
local onAnimation = anim8.newAnimation(grid("1-4", 1), 0.1)
local offImage = love.graphics.newImage("assets/Traps/Falling Platforms/Off.png")
grid = anim8.newGrid(32, 10, offImage:getWidth(), offImage:getHeight())
local offAnimation = anim8.newAnimation(grid("1-1", 1), 0.1, "pauseAtEnd")

function fallingPlatform:new(x, y, world)
    local obj = {
        x = x,
        y = y,
        animations = {
            on = {
                image = onImage,
                animation = onAnimation
            },
            off = {
                image = offImage,
                animation = offAnimation
            }
        },
        fall = false,
        fallTimer = false
    }
    obj.currentAnimation = obj.animations.on

    obj.collider = world:newRectangleCollider(x - 32, y - 10, 32*2, 10*2)
    obj.collider:setObject(obj)
    obj.collider:setType("static")
    obj.collider:setFixedRotation(true)
    obj.collider:setCollisionClass("platform")
    obj.collider:setPreSolve(function(col1, col2, contact)
        local _, ny = contact:getNormal()
        if col2.collision_class == "player" and col1.collision_class == "platform" and ny < 0 then
            local object = col1:getObject()
            if object.fall then
                col2:getObject().onGround = false
                contact:setEnabled(false)
                return
            end
            object.fallTimer = true
            -- col1:setType("dynamic")
        end
    end)
    obj.timer = 0.5

    return setmetatable(obj, {__index = self})
end

function fallingPlatform:update(dt)
    self.currentAnimation.animation:update(dt)

    if self.fallTimer then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self.fall = true
            self.currentAnimation = self.animations.off
        end
    end

    if self.fall then
        self.collider:setPosition(self.collider:getX(), self.collider:getY() + 500 * dt)
    end
    if self.collider:getY() > love.graphics.getHeight() then
        self.collider:destroy()
    end
end

function fallingPlatform:draw()
    if self.collider:isDestroyed() then
        return
    end

    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x - 32, y - 10, 0, 2, 2)
end

return fallingPlatform