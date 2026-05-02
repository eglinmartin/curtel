-- player.lua
local Class = require("lib.class")
local Cursor = require("src.entity.cursor")
local Entity = require("src.entity.entity")

local Cursor = Class{__includes = Entity}


function Cursor:init(id, GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, args)
    Entity.init(self, id, GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, args)
end


function Cursor:update(dt, mx, my, mouse_down, mouse_pressed)
    Entity.update(self, dt, mx, my, mouse_down, mouse_pressed)
end


function Cursor:draw()
    Entity.draw(self)
end


return Cursor
