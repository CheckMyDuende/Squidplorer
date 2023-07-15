
Player = GameObject:extend()
function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)

    -- Initialize properties
    self.width = 32
    self.height = 64
    self.angle = 0 -- in radians
    self.vertices = {
        -self.width/2, self.height/2, -- lower left
        self.width/2, self.height/2, -- lower right
        0, -self.height/2 -- upper center
    }
    self.outlineWidth = 10
    self.outlineVertices = {
        self.vertices[1] - self.outlineWidth, self.vertices[2] + self.outlineWidth,
        self.vertices[3] + self.outlineWidth, self.vertices[4] + self.outlineWidth,
        self.vertices[5], self.vertices[6] - self.outlineWidth,
    }

    -- Initialize physics
    self.body = love.physics.newBody(self.area.world, self.x, self.y, 'dynamic')
    self.body:setMass(10)
    self.shape = love.physics.newPolygonShape(self.vertices)
    self.outlineShape = love.physics.newPolygonShape(self.outlineVertices)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    
    -- Initilize movement impulses
    self.jumpImpulseX = 300
    self.jumpImpulseY = 50
    self.angularImpulse = 200
    
    -- Set max rotation
    self.maxAngle = math.pi / 8

    -- Add Blob manager
    self.blobs = self.area:addGameObject('BlobParticleSystem', 0)

    -- Bind inputs for the player
    input:bind('right', 'rotateRight')
    input:bind('left', 'rotateLeft')
    input:bind('space', 'jump')
end

function Player:stayAtY(offsetRatio)
    -- Calculate distance to vertical center
    local worldWidth, worldHeight = love.window.getMode()
    local centerY = worldHeight / 2
    local distanceY = centerY - self.y

    -- Offset velocity
    local currentVelocityX, currentVelocityY = self.body:getLinearVelocity()
    self.body:setLinearVelocity(
        currentVelocityX, 
        (1 - offsetRatio) * currentVelocityY + offsetRatio * distanceY)

end

-- TODO: fix rotations
function Player:rotateRight()
    self.rightRotation = self.timer:tween(0.2, self, {angle = self.maxAngle}, 'out-cubic')
    -- if self.leftRotation then
    --     self.timer:cancel(self.leftRotation)
    --     self.leftRotation = nil
    -- end
    if self.cancelRotation then
        self.timer:cancel(self.cancelRotation)
        self.cancelRotation = nil
    end
end

function Player:rotateLeft()
    self.leftRotation = self.timer:tween(0.2, self, {angle = -self.maxAngle}, 'out-cubic')
    -- if self.rightRotation then
    --     self.timer:cancel(self.rightRotation)
    --     self.rightRotation = nil
    -- end
    if self.cancelRotation then
        self.timer:cancel(self.cancelRotation)
        self.cancelRotation = nil
    end
end

function Player:rotateBack()
    if self.rightRotation and (input:released('rotateRight') or input:released('rotateLeft')) then
        self.timer:cancel(self.rightRotation)
        self.rightRotation = nil
        self.timer:tween(0.2, self, {angle = 0}, 'out-cubic')
        if self.leftRotation then
            self.leftRotation = self.timer:tween(0.2, self, {angle = -self.maxAngle}, 'out-cubic')
        end
    end

    if self.leftRotation and (input:released('rotateRight') or input:released('rotateLeft')) then
        self.timer:cancel(self.leftRotation)
        self.leftRotation = nil
        self.cancelRotation = self.timer:tween(0.2, self, {angle = 0}, 'out-cubic')
        if self.rightRotation then
            self.rightRotation = self.timer:tween(0.2, self, {angle = -self.maxAngle}, 'out-cubic')
        end
    end
end

function Player:jump()
    -- Cancel horizontal velocity
    local velX, velY = self.body:getLinearVelocity()
    self.body:setLinearVelocity(0, velY)

    -- Apply jump impulse
    local ix, iy = math.sin(self.angle), -math.cos(self.angle)
    self.body:applyLinearImpulse(
        self.jumpImpulseX * ix, 
        self.jumpImpulseY * iy, 
        self.x, 
        self.y
    )

    -- Spawn particles
    self.blobs:spawnBlobs(self.x, self.y)
    -- local numBlobs = love.math.random(7, 10)
    -- for i = 1, numBlobs do
    --     local speedX = 4 * (love.math.random() - 0.5)
    --     local speedY = 0.5 * love.math.random() + 3
    --     self.area:addGameObject(
    --         'Blob',
    --         1,
    --         self.x, 
    --         self.y,
    --         {
    --             speedX = speedX,
    --             speedY = speedY,
    --             innerColor = self.inkInnerColor,
    --             outerColor = self.inkOuterColor
    --         }
    --     )
    -- end
end

function Player:update(dt)
    -- Update timer
    self.timer:update(dt)

    -- Get current vars
    self.x, self.y = self.body:getPosition()

    -- Stay near vertical center
    self:stayAtY(0.05)
    
    -- Handle jump input
    if input:pressed('jump') then
        self:jump()
    end

    -- Handle rotations
    if input:pressed('rotateRight') then
        self:rotateRight()
    elseif input:pressed('rotateLeft') then
        self:rotateLeft()
    end
    self:rotateBack()

    -- Set current variables
    self.body:setAngle(self.angle)
end

function Player:draw()
    -- Draw outline
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.polygon(
        'fill',
        self.body:getWorldPoints(self.outlineShape:getPoints())
    )

    -- Draw main body
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon(
        'fill',
        self.body:getWorldPoints(self.shape:getPoints())
    )
end