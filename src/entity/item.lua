-- player.lua
local Class = require("lib.class")
local Entity = require("src.entity.entity")

local Item = Class{__includes = Entity}

States = {
    IDLE = 1,
}


function Item:init(id, GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, args)
    Entity.init(self, id, GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, args)
    self.item = args.item
end


function Item:update(dt, mx, my, mouse_down, mouse_pressed)
    if self.covered then
        self.sprite_sheet = "cards_general"
        self.sprite_tag = "back1"
    end
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
    
end


function Item:draw()
    Entity.draw(self)
end


function Item:on_hover_changed()
end


return Item
