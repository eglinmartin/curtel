local Class = require("lib.class")

local InputManager = Class{}


function InputManager:init(EVENT_MANAGER)
    self.event_manager = EVENT_MANAGER
    self.keybinds = {
        ["1"] = EVENT_MANAGER.events.SWITCHSCREEN_GAME,
        ["2"] = EVENT_MANAGER.events.SWITCHSCREEN_SHOP,
        ["3"] = EVENT_MANAGER.events.DEALCARDS,
        ["4"] = EVENT_MANAGER.events.SWITCHSTOCK_LEFT,
        ["5"] = EVENT_MANAGER.events.SWITCHSTOCK_RIGHT,
    }
end


function InputManager:keypressed(key)
    local event = self.keybinds[key]
    if event then
        self.event_manager:trigger(event)
    end
end


function InputManager:mousepressed(x, y, button)
    if button == 1 then
        self.event_manager:trigger(self.event_manager.events.MOUSE_PRESSED, x, y)
    end
end


function InputManager:mousereleased(x, y, button)
    if button == 1 then
        self.event_manager:trigger(self.event_manager.events.MOUSE_RELEASED, x, y)
    end
end


return InputManager