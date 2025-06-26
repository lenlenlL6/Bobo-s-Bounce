local shader = love.graphics.newShader("shaders/destinationShader.glsl")

function love.draw()
    love.graphics.setColor(0.5, 1.0, 0.5, 0.8)
    love.graphics.setShader(shader)
    shader:send("position", {150, 600})
    shader:send("maxDistance", 200)
    love.graphics.rectangle("fill", 100, 400, 100, 200)
    love.graphics.setShader()
end