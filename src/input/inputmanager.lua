local Class = require("lib.class")
local Entity = require("src.entity.entity")

local InputManager = Class{}


function InputManager:init(EVENT_MANAGER, rs)
    self.event_manager = EVENT_MANAGER
    self.keybinds = {
        ["f1"] = self.event_manager.events.SWITCHSCREEN_GAME,
        ["f2"] = self.event_manager.events.SWITCHSCREEN_SHOP,
        ["1"] = self.event_manager.events.DEALCARDS,
        ["2"] = self.event_manager.events.CREATEENEMY,
        ["f11"] = self.event_manager.events.TOGGLE_FULLSCREEN
    }
    self.rs = rs

    self.mx = 0
    self.my = 0

    self.mouse_down = false
    self.mouse_pressed = false
    self.mouse_released = false

    self.keys_down = {}
    self.keys_pressed = {}
    self.keys_released = {}
end


function InputManager:update()
    local raw_mx, raw_my = love.mouse.getPosition()
    self.mx, self.my = self.rs.to_game(raw_mx, raw_my)
    self.mouse_down = love.mouse.isDown(1)

    self.mouse_pressed = false
    self.mouse_released = false
    self.keys_pressed = {}
    self.keys_released = {}
end


function InputManager:keypressed(key)
    local event = self.keybinds[key]
    if event then
        self.event_manager:trigger(event)
    end
end


function InputManager:mousepressed(x, y, button)
    if button == 1 then
        self.mouse_pressed = true
        self.event_manager:trigger(self.event_manager.events.MOUSEPRESSED, x, y)
    end
end


function InputManager:mousereleased(x, y, button)
    if button == 1 then
        self.event_manager:trigger(self.event_manager.events.MOUSERELEASED, x, y)
    end
end


return InputManager
