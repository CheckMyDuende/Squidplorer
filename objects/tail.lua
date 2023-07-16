
function normalized_sine(x)
    return math.sin(20/math.pi * x)
end

Tail = GameObject:extend()
function Tail:new(area, x, y, opts)
    Tail.super.new(self, area, x, y, opts)
    
    self.lineWidth = 2
    self.sampleSizePerPeriod = 64
    self.periods = 0.5 + love.math.random()
    self.length = 128 + 32 * love.math.random()
    self.periodLength = self.length / self.periods
    self.amplitude = self.body.width / 2
    self.distanceX = self.length / (self.sampleSizePerPeriod * self.periods)
    self.updateFrequency = 1 / 16
    
    self.initOffset = love.math.random()

    -- Sample sine wave
    self.pointsX = {}
    self.pointsY = {}
    for x = 0, self.length, self.distanceX do
        local y = self.amplitude * normalized_sine(x / self.periodLength + self.initOffset)
        table.insert(self.pointsX, x)
        table.insert(self.pointsY, y)
    end

    -- Update points
    self.lastX = self.pointsX[#self.pointsX-1]
    self.timer:every(self.updateFrequency, function ()
        table.remove(self.pointsY, 1)
        self.lastX = self.lastX + self.distanceX
        local newY = self.amplitude * normalized_sine(self.lastX / self.periodLength + self.initOffset)
        table.insert(self.pointsY, newY)
    end)
end

function Tail:rotate()
    -- local ix = self.body.body:getLinearVelocity()

    -- local pointsY_rotated = {}
    -- for i = 1, #self.pointsY do
    --     table.insert(
    --         pointsY_rotated, 
    --         self.pointsY[i] + (i / #self.pointsY) ^ 2 * ix
    --     )
    -- end

    -- if self.cancelHandler then
    --     self.timer:cancel(self.cancelHandler)
    --     self.cancelHandler = nil
    -- end
    -- self.rotationHandler = self.timer:tween(3, self.pointsY_transformed, pointsY_rotated, 'in-out-cubic', function ()
    --     self.rotationHandler = nil
    -- end)
end

function Tail:rotateBack()
    -- if self.rotationHandler then
    --    self.timer:cancel(self.rotationHandler)
    --    self.rotationHandler = nil
    -- end
    -- self.cancelHandler = self.timer:tween(2, self.pointsY_transformed, self.pointsY, 'in-out-cubic', function ()
    --     self.cancelHandler = nil
    -- end)
end

function Tail:update(dt)
    -- Update timer
    self.timer:update(dt)

    self.x = self.body.x
    self.y = self.body.y
    self.angle = self.body.angle
    
    -- if not self.rotationHandler and not self.cancelHandler then
    --     self.pointsY_transformed = self.pointsY
    -- end
    local ix = self.body.body:getLinearVelocity()

    self.pointsY_transformed = {}
    for i = 1, #self.pointsY do
        table.insert(
            self.pointsY_transformed, 
            self.pointsY[i] + (i / #self.pointsY) ^ 2 * ix
        )
    end
end

function Tail:draw()
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.setLineWidth(self.lineWidth)

    love.graphics.push()
    love.graphics.translate(self.x - math.sin(self.angle) * self.body.height/2, self.y + math.cos(self.angle) * self.body.height/2)
    love.graphics.rotate(self.angle + math.pi / 2) -- i'm a dummy
    local points = M.interleave(self.pointsX, self.pointsY_transformed)
    love.graphics.line(points)
    love.graphics.pop()
end
