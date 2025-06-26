local anim8 = require("libs.anim8")
local baton = require("libs.baton")
local player = {}

local idleImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Idle (32x32).png")
local grid = anim8.newGrid(32, 32, idleImage:getWidth(), idleImage:getHeight())
local idleAnimation = anim8.newAnimation(grid("1-11", 1), 0.1)
local runImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Run (32x32).png")
grid = anim8.newGrid(32, 32, runImage:getWidth(), runImage:getHeight())
local runAnimation = anim8.newAnimation(grid("1-12", 1), 0.06)
local jumpImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Jump (32x32).png")
grid = anim8.newGrid(32, 32, jumpImage:getWidth(), jumpImage:getHeight())
local jumpAnimation = anim8.newAnimation(grid("1-1", 1), 1, "pauseAtEnd")
local fallImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Fall (32x32).png")
grid = anim8.newGrid(32, 32, fallImage:getWidth(), fallImage:getHeight())
local fallAnimation = anim8.newAnimation(grid("1-1", 1), 1, "pauseAtEnd")
local wallImage = love.graphics.newImage("assets/Main Characters/Ninja Frog/Wall Jump (32x32).png")
grid = anim8.newGrid(32, 32, wallImage:getWidth(), wallImage:getHeight())
local wallAnimation = anim8.newAnimation(grid("1-5", 1), 0.1)
local dustImage = love.graphics.newImage("assets/Other/Dust Particle.png")

function player:new(x, y, world)
    local obj = {
        animations = {
            idle = {
                image = idleImage,
                animation = idleAnimation
            },
            run = {
                image = runImage,
                animation = runAnimation
            },
            jump = {
                image = jumpImage,
                animation = jumpAnimation
            },
            fall = {
                image = fallImage,
                animation = fallAnimation
            },
            wall = {
                image = wallImage,
                animation = wallAnimation
            }
        },
        direction = 1,
        onGround = false,
        onWall = false,
        input = baton.new({
            controls = {
                right = {"key:d"},
                left = {"key:a"},
                jump = {"key:w"}
            }
        })
    }
    obj.currentAnimation = obj.animations.idle
    obj.collider = world:newRectangleCollider(x - 25, y + 20, 50, 44)
    obj.collider:setCollisionClass("player")
    obj.collider:setObject(obj)
    obj.collider:setFixedRotation(true)
    obj.collider:setPreSolve(function(col1, col2, contact)
        local nx, ny = contact:getNormal()
        if col1.collision_class == "player" and col2.collision_class == "platform" and ny < 0 then
            local object = col1:getObject()
            if not object.onGround and contact:isEnabled() then
                object.onGround = true
            end
            return
        end

        if col1.collision_class == "player" and col2.collision_class == "platform" and nx ~= 0 then
            local object = col1:getObject()
            if object.onGround or object.onWall then
                return
            end
            if col2:getObject() then
                if col2:getObject().fall ~= nil then
                    contact:setEnabled(false)
                    return
                end
            end

            object.onWall = (nx > 0) and -1 or 1
            object.currentAnimation = object.animations.wall
            return
        end
    end)
    obj.psystem = love.graphics.newParticleSystem(dustImage)
    obj.psystem:setParticleLifetime(0.5, 1.2)
    obj.psystem:setEmissionRate(3)
    obj.psystem:setColors(1, 1, 1, 1, 1, 1, 1, 0)

    return setmetatable(obj, {__index = self})
end

function player:update(dt)
    self.currentAnimation.animation:update(dt)
    self.psystem:update(dt)
    if self.collider:exit("platform") then
        self.onGround = false
    end

    self.input:update()
    local left, right = self.input:get("left"), self.input:get("right")
    local move = (right - left ~= 0)

    if self.onWall then
        self.collider:setGravityScale(0)
        self.collider:setLinearVelocity(0, 0)
        if move and right - left ~= self.onWall then
            self.collider:applyLinearImpulse(2500*-self.onWall, -2500)
            self.onWall = false
            self.collider:setGravityScale(1)
        end
        return
    end

    if self.input:get("jump") == 1 and self.onGround then
        self.onGround = false
        self.collider:applyLinearImpulse(0, -1200)
    end

    local vx, vy = self.collider:getLinearVelocity()
    if not self.onGround then
        self.currentAnimation = (vy < 0) and self.animations.jump or self.animations.fall
    end

    self.direction = move and (right - left) or self.direction

    if move then
        self.currentAnimation = self.onGround and self.animations.run or self.currentAnimation
        self.collider:setLinearVelocity(self.direction * 210, vy)

        if self.onGround then
            self.psystem:setLinearAcceleration(50*-self.direction, -400, 100*-self.direction, 0)
            self.psystem:start()
        else
            self.psystem:pause()
        end
    else
        self.currentAnimation = self.onGround and self.animations.idle or self.currentAnimation
        self.collider:setLinearVelocity(0, vy)
        
        self.psystem:pause()
    end

    local x, y = self.collider:getPosition()
    self.psystem:setPosition(x - 25*self.direction, y + 21)
end

function player:draw()
    local x, y = self.collider:getPosition()
    self.currentAnimation.animation:draw(self.currentAnimation.image, x, y - 42, 0, 2*self.direction, 2, 16)
    
    love.graphics.draw(self.psystem)
end

return player