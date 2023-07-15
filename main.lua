
_G.love = require("love")
_G.M = require "lib.moses.moses"
_G.Object = require "lib.classic.classic"
_G.Input = require "lib.boipushy.Input"
_G.Timer = require "lib.hump.timer"
_G.Camera = require "lib.hump.camera" -- TODO: Artem: do we need camera for scrolling?

require("objects.game_object")
require("objects.player")
require("objects.ink")
require("rooms.main_room")

function love.load()
    -- Initialize input
    -- TODO: make this room-specific?
    _G.input = Input()
    
    -- Initialize room
    _G.current_room = GameRoom()
end

function love.update(dt)
    -- Update room
    if current_room then current_room:update(dt) end
end

function love.draw()
    if current_room then current_room:draw() end
end

function gotoRoom(room_type, ...)
    current_room = _G[room_type](...)
end