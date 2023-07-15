
GameObject = Object:extend()

function GameObject:new(area, x, y, opts)
    local opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end

    self.area = area  
    self.x, self.y = x, y
    self.id = M.uniqueId()
    self.dead = false
    self.timer = Timer()
end

function GameObject:update(dt)
    -- TODO: figure out why nothing works in this update func (when called as super:update())
    -- Kill object
    if self.dead then self = nil end
end

function GameObject:draw()

end