local Bullets = require("src.entity.bullets")
local Class = require("lib.class")
local Deck = require("src.entity.deck")
local Entity = require("src.entity.entity")

local Enemy = Class{__includes = Entity}

States = {
    IDLE = 1,
}


function Enemy:init(id, GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, args)
    Entity.init(self, id, GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, args)

    self.state = States.IDLE

    self.health = 10
    self.max_health = 10

    self.hand_size = 3
    self.hand = {}
    self.selected_card = nil

    self.deck = Deck()
    self.bullets = {Bullets.DAMAGE_BOMB, Bullets.DAMAGE_BOMB, Bullets.DAMAGE_BOMB, Bullets.DAMAGE_BOMB, Bullets.DAMAGE_BOMB, Bullets.DAMAGE_BOMB}

end


function Enemy:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


function Enemy:draw()
    Entity.draw(self)
end


return Enemy
