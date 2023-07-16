
function normalized_sine(x)
    return math.sin(20/math.pi * x)
end

Tail = GameObject:extend()
function Tail:new(area, x, y, opts)
    Tail.super.new(self, area, x, y, opts)
    
    self.initOffset = love.math.random()
    self.sampleSizePerPeriod = 64
    self.periods = love.math.random()
    self.length = self.length + 32 * love.math.random()
    self.periodLength = self.length / self.periods
    self.amplitude = self.body.width / 2
    self.amplitudeSpread = self.body.width / 8
    self.randomRotationSpread = love.math.random()
    self.maxRotationSpread = math.pi / 6
    self.distanceX = self.length / (self.sampleSizePerPeriod * self.periods)
    self.updateFrequency = 1 / 16
    if self.offsetX then
        self.offsetX = self.offsetX
    else
        self.offsetX = (self.initOffset - 0.5) * 2 * self.amplitude
    end
    
    -- Sample sine wave
    self.pointsX = {}
    self.pointsY = {}
    self.periodCount = 0
    self.amplitude_transformed = (love.math.random() - 0.5) * self.amplitudeSpread + self.amplitude
    for x = 0, self.length, self.distanceX do
        local y = self.amplitude_transformed * normalized_sine(x / self.periodLength + self.initOffset)
        table.insert(self.pointsX, x)
        table.insert(self.pointsY, y)

        self.periodCount = self.periodCount + 1
        if self.periodCount > self.sampleSizePerPeriod then
            self.periodCount = 0
            self.timer:tween(0.5, self, {amplitude_transformed = (love.math.random() - 0.5) * self.amplitudeSpread + self.amplitude}, 'in-out-cubic')
        end
    end

    -- Update points
    self.lastX = self.pointsX[#self.pointsX-1]
    self.timer:every(self.updateFrequency, function ()
        -- Get X
        table.remove(self.pointsY, 1)
        self.lastX = self.lastX + self.distanceX

        -- Add amplitude displacement
        self.periodCount = self.periodCount + 1
        if self.periodCount > self.sampleSizePerPeriod then
            self.periodCount = 0
            self.timer:tween(0.5, self, {amplitude_transformed = (love.math.random() - 0.5) * self.amplitudeSpread + self.amplitude}, 'in-out-cubic')
        end

        -- Calculate new Y
        local newY = self.amplitude_transformed * normalized_sine(self.lastX / self.periodLength + self.initOffset)
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
    
    -- if not self.rotationHandler and not self.cancelHandler then
    --     self.pointsY_transformed = self.pointsY
    -- end
    local ix = self.body.body:getLinearVelocity()
    
    -- TODO: Add jitter 
    self.pointsY_transformed = {}    
    
    -- Add directional change
    for i = 1, #self.pointsY do
        table.insert(
            self.pointsY_transformed, 
            self.pointsY[i] + (i / #self.pointsY) ^ 2 * ix
        )
    end
    
    -- Update x and y
    self.x = self.body.x + self.pointsY_transformed[1] + self.offsetX
    self.y = self.body.y
    self.angle = self.body.angle
end

function Tail:draw()
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.setLineWidth(self.lineWidth)

    love.graphics.push()
    love.graphics.translate(self.x - math.sin(self.angle) * self.body.height/2, self.y + math.cos(self.angle) * self.body.height/2)
    love.graphics.rotate(self.angle + math.pi / 2 + (self.randomRotationSpread - 0.5) * self.maxRotationSpread) -- i'm a dummy
    local points = M.interleave(self.pointsX, self.pointsY_transformed)
    love.graphics.line(points)
    love.graphics.pop()
end
