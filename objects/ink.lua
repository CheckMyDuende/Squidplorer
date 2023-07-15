
function GetSpeedDecrease(x)
    return 0.1 / math.sqrt(x)
end

Blob = GameObject:extend()
function Blob:new(area, x, y, opts)
    Blob.super.new(self, area, x, y, opts)

    -- Redundant
    self.lifeTimer = 0

    -- Set death timer
    self.timer:after(
        2 * self.lifetime / 3,
        function ()
            self.timer:tween(self.lifetime / 3, self, {innerRadius = 0}, 'in-out-cubic')
            self.timer:tween(self.lifetime / 3, self, {outerRadius = 0}, 'in-out-cubic', function ()
                self.dead = true
            end)
        end
    )
end

function Blob:update(dt)
    -- Update timer
    self.timer:update(dt)

    -- Move blob 
    -- TODO: base this on physics engine
    self.x = self.x + self.speedX
    self.y = self.y + self.speedY
    self.lifeTimer = self.lifeTimer + 1
    if self.speedX >= 0 then
        self.speedX = math.max(0.01, self.speedX - GetSpeedDecrease(self.lifeTimer))
    elseif self.speedX <= 0 then
        self.speedX = math.min(0.01, self.speedX + GetSpeedDecrease(self.lifeTimer))
    end
    self.speedY = math.max(0.1, self.speedY - GetSpeedDecrease(self.lifeTimer))
end

function Blob:drawOuter()
    love.graphics.setColor(self.outerColor)
    love.graphics.circle(
        "fill", self.x, self.y, self.outerRadius
    )
end

function Blob:drawInner()
    love.graphics.setColor(self.innerColor)
    love.graphics.circle(
        "fill", self.x, self.y, self.innerRadius
    )
end



BlobParticleSystem = GameObject:extend()
function BlobParticleSystem:new(area, x, y, opts)
    BlobParticleSystem.super.new(self, area, x, y, opts)
    self.blobs = {}

    -- Set individual base blob properties
    self.baseLifetime = 15
    self.baseInnerRadius = 20
    self.baseOuterRadius = 25
    self.baseSpeedX = 0
    self.baseSpreadX = 3
    self.baseSpeedY = 3
    self.baseSpreadY = 0.2
    self.baseAmount = 15

    -- Set blob system properties
    self.inkInnerColor = {35/255, 60/255, 119/255}
    self.inkOuterColor = {22/255, 38/255, 76/255}
end

function BlobParticleSystem:addBlob(x, y, speedX, speedY)
    table.insert(
        self.blobs, 
        self.area:addGameObject(
            'Blob',
            0,
            x, 
            y,
            {
                speedX = speedX,
                speedY = speedY,
                innerColor = self.inkInnerColor,
                outerColor = self.inkOuterColor,
                innerRadius = self.baseInnerRadius,
                outerRadius = self.baseOuterRadius,
                lifetime = self.baseLifetime
            }
            ) 
        )
end

function BlobParticleSystem:spawnBlobs(x, y)
    for i = 1, self.baseAmount do
        local speedX = self.baseSpeedX + self.baseSpreadX * (love.math.random() - 0.5)
        local speedY = self.baseSpeedY + self.baseSpreadY * (love.math.random() - 0.5)
        self:addBlob(x, y, speedX, speedY)
    end
end

function BlobParticleSystem:update(dt)
    for i, blob in pairs(self.blobs) do
        blob:update(dt)
    end
end

function BlobParticleSystem:draw()
    for i, blob in pairs(self.blobs) do
        blob:drawOuter(self.outerColor)
    end
    for i, blob in pairs(self.blobs) do
        blob:drawInner(self.innerColor)
    end
end