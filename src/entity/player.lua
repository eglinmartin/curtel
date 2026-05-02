-- player.lua
local Class = require("lib.class")
local Entity = require("src.entity.entity")

local Player = Class{__includes = Entity}

States = {
    IDLE = 1,
}


function Player:init(id, GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, args)
    Entity.init(self, id, GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, args)

    self.state = States.IDLE

    self.health = 10
    self.max_health = 10
    self.money = 10

    self.hand_size = 3
    self.hand = {}
    self.selected_card = nil
end


function Player:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


function Player:draw()
    Entity.draw(self)
end


return Player
