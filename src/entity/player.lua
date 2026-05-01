-- player.lua
local Class = require("lib.class")
local Entity = require("src.entity.entity")

local Player = Class{__includes = Entity}

States = {
    IDLE = 1,
}


function Player:init(x, y, render_manager)
    self.x = x
    self.y = y
    Entity.init(self, self.x, self.y, 20, 32)

    self.state = States.IDLE

    self.health = 10
    self.max_health = 10
    self.money = 10

    self.hand_size = 3
    self.hand = {}
    self.selected_card = nil
    
    render_manager:create_draw_object_foreground("player", "player", "idle", self.x, self.y, 0, 1, 128)
end


function Player:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


function Player:draw()
    Entity.draw(self)
end


return Player
