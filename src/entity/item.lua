-- player.lua
local Class = require("lib.class")
local Entity = require("src.entity.entity")

local Item = Class{__includes = Entity}

States = {
    IDLE = 1,
}


function Item:init(item, x, y)
    self.x = x
    self.y = y
    self.item = item
    Entity.init(self, self.x, self.y, 19, 19)

    self.health = 10
    self.max_health = 10
    self.money = 10

    self.hand_size = 3
    self.hand = {}
    
    self.selected = false
end


function Item:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


function Item:draw()
    Entity.draw(self)
end


function Item:on_hover_changed()
    self.selected = true
end


return Item
