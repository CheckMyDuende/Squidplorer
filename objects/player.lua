
Player = GameObject:extend()
function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)

    -- Initialize properties
    self.width = 32
    self.height = 128
    self.angle = 0 -- in radians

    -- Initialize shape
    self.wingOffsetX, self.wingOffsetY = 10, 5
    self.vertices = {
        -self.width/2, self.height/2, -- lower left
        self.width/2, self.height/2, -- lower right
        0, -self.height/2 -- upper center
    }
    self.outlineWidth = 10
    self.outlineVertices = {
        self.vertices[1] - self.outlineWidth, self.vertices[2] + self.outlineWidth, -- lower left
        self.vertices[3] + self.outlineWidth, self.vertices[4] + self.outlineWidth, -- lower right
        self.vertices[5], self.vertices[6] - self.outlineWidth -- upper center
    }

    -- Initialize wings
    local wingLeftAttachVertexX, wingLeftAttachVertexY = self.outlineVertices[5] + 0.7 * (self.outlineVertices[1] - self.outlineVertices[5]), self.outlineVertices[6] + 0.7 * (self.outlineVertices[2] - self.outlineVertices[6])
    self.wingLeftVertices = {
        wingLeftAttachVertexX, wingLeftAttachVertexY, 
        wingLeftAttachVertexX - self.wingOffsetX, wingLeftAttachVertexY - self.wingOffsetY,  
        self.outlineVertices[5], self.outlineVertices[6]
    }
    local wingRightAttachVertexX, wingRightAttachVertexY = self.outlineVertices[5] + 0.7 * (self.outlineVertices[3] - self.outlineVertices[5]), self.outlineVertices[6] + 0.7 * (self.outlineVertices[4] - self.outlineVertices[6])
    self.wingRightVertices = {
        wingRightAttachVertexX, wingRightAttachVertexY,
        wingRightAttachVertexX + self.wingOffsetX, wingRightAttachVertexY - self.wingOffsetY,  
        self.outlineVertices[5], self.outlineVertices[6]
    }

    -- Initialize eyes
    self.eyeLeftX = wingLeftAttachVertexX
    self.eyeLeftY = wingLeftAttachVertexY
    self.eyeRightX = wingRightAttachVertexX
    self.eyeRightY = wingRightAttachVertexY
    self.eyeRadius = 5

    -- Initialize physics
    self.body = love.physics.newBody(self.area.world, self.x, self.y, 'dynamic')
    self.body:setMass(10)
    self.shape = love.physics.newPolygonShape(self.vertices)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.outlineShape = love.physics.newPolygonShape(self.outlineVertices)
    self.wingLeftShape = love.physics.newPolygonShape(self.wingLeftVertices)
    self.wingRightShape = love.physics.newPolygonShape(self.wingRightVertices)
    
    -- self.eyeLeftBody = love.physics.newBody(self.area.world, self.eyeLeftX, self.eyeLeftY, 'dynamic')
    -- self.eyeLeftShape = love.physics.newCircleShape(self.eyeLeftX, self.eyeLeftY, self.eyeRadius)
    -- self.eyeLeftFixture = love.physics.newFixture(self.eyeLeftBody, self.eyeLeftShape)
    -- self.eyeLeftJoint = love.physics.newDistanceJoint(self.body, self.eyeLeftBody, 0, 0, 0, 0)
    -- self.eyeRightBody = love.physics.newBody(self.area.world, self.eyeRightX, self.eyeRightY, 'dynamic')
    -- self.eyeRightShape = love.physics.newCircleShape(self.eyeRightX, self.eyeRightY, self.eyeRadius)
    -- self.eyeRightFixture = love.physics.newFixture(self.eyeRightBody, self.eyeRightShape)
    -- self.eyeRightJoint = love.physics.newDistanceJoint(self.body, self.eyeRightBody, 0, 0, 0, 0)

    -- Initilize movement impulses
    self.jumpImpulseX = 300
    self.jumpImpulseY = 50
    self.angularImpulse = 200
    
    -- Set max rotation
    self.maxAngle = math.pi / 8

    -- Add Blob manager
    self.blobs = self.area:addGameObject('BlobParticleSystem', 0)

    -- Add tails
    self.tails = {}
    for i = 1, 8 do
        table.insert(self.tails, self.area:addGameObject('Tail', 1, self.x, self.y + self.height/2, {body = self, angle = self.angle}))
    end

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
    for i, tail in pairs(self.tails) do
        tail:rotate()
    end
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
    for i, tail in pairs(self.tails) do
        tail:rotate()
    end
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
        for i, tail in pairs(self.tails) do
            tail:rotateBack()
        end
    end

    if self.leftRotation and (input:released('rotateRight') or input:released('rotateLeft')) then
        self.timer:cancel(self.leftRotation)
        self.leftRotation = nil
        self.cancelRotation = self.timer:tween(0.2, self, {angle = 0}, 'out-cubic')
        if self.rightRotation then
            self.rightRotation = self.timer:tween(0.2, self, {angle = -self.maxAngle}, 'out-cubic')
        end
        for i, tail in pairs(self.tails) do
            tail:rotateBack()
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
    self.blobs:spawnBlobs(self.x - math.sin(self.angle) * self.height/2, self.y + math.cos(self.angle) * self.height/2)
end

function Player:update(dt)
    -- Update timer
    self.timer:update(dt)

    -- Get current vars
    self.x, self.y = self.body:getPosition()

    -- Stay near vertical center
    self:stayAtY(0.03)
    
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

    -- Draw wings
    love.graphics.polygon(
        'fill',
        self.body:getWorldPoints(self.wingLeftShape:getPoints())
    )
    love.graphics.polygon(
        'fill',
        self.body:getWorldPoints(self.wingRightShape:getPoints())
    )

    -- Draw eyes
    -- love.graphics.setColor({22/255, 38/255, 76/255})
    -- love.graphics.circle(
    --     'fill',
    --     self.eyeLeftBody:getX(), 
    --     self.eyeLeftBody:getY(),
    --     self.eyeRadius + 2
    -- )
    -- love.graphics.circle(
    --     'fill',
    --     self.eyeRightBody:getX(), 
    --     self.eyeRightBody:getY(),
    --     self.eyeRadius + 2
    -- )
    -- love.graphics.setColor(1, 1, 1)
    -- love.graphics.circle(
    --     'fill',
    --     self.eyeLeftBody:getX(), 
    --     self.eyeLeftBody:getY(),
    --     self.eyeRadius
    -- )
    -- love.graphics.circle(
    --     'fill',
    --     self.eyeRightBody:getX(), 
    --     self.eyeRightBody:getY(),
    --     self.eyeRadius
    -- )

    -- Draw main body
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon(
        'fill',
        self.body:getWorldPoints(self.shape:getPoints())
    )
end