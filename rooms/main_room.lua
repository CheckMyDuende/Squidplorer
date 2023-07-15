
GameRoom = Object:extend()
function GameRoom:new()
    -- Initialize area
    self.area = Area(self)

    -- Initialize player
    self.area:addGameObject('Player', 2, 300, 500)
end

function GameRoom:update(dt)
    self.area:update(dt)
end

function GameRoom:draw()
    self.area:draw()
end

-- function GameRoom:addArea(area)
--     self.area = area
--     -- table.insert(self.areas, area) -- use this if multiple area are required
-- end


Area = Object:extend()
function Area:new(room)
    -- Initialize room and GameObjects
    self.room = room
    self.game_objects = {}

    -- Add world
    self:addPhysicsWorld()
end

function Area:update(dt)
    -- Update world
    if self.world then self.world:update(dt) end

    -- Update objects
    for layer, layer_objects in pairs(self.game_objects) do
        for i = #layer_objects, 1, -1 do
            local game_object = layer_objects[i]
            game_object:update(dt)
            if game_object.dead then table.remove(layer_objects, i) end
        end    
    end
end

function Area:draw()
    for layer, layer_objects in pairs(self.game_objects) do
        for i = #layer_objects, 1, -1 do
            local game_object = layer_objects[i]
            game_object:draw()
        end    
    end
end

function Area:addGameObject(game_object_type, layer, x, y, opts)
    local opts = opts or {}
    local game_object = _G[game_object_type](self, x or 0, y or 0, opts)
    if not self.game_objects[layer] then self.game_objects[layer] = {} end
    table.insert(self.game_objects[layer], game_object)
    return game_object
end

function Area:addPhysicsWorld()
    self.world = love.physics.newWorld(0, 0, true)
end