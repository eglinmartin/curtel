local Class = require("lib.class")

local Colours = require("src.render.colours")
local GameScene = require("src.scene.gamescene")
local ShopScene = require("src.scene.shopscene")

local SceneManager = Class{}


function SceneManager:init(GAME_STATE, RENDER_MANAGER, EVENT_MANAGER, INPUT_MANAGER)
    self.game_state = GAME_STATE
    self.render_manager = RENDER_MANAGER
    self.event_manager = EVENT_MANAGER
    self.input_manager = INPUT_MANAGER

    self.game_scene = GameScene(GAME_STATE, RENDER_MANAGER, EVENT_MANAGER, INPUT_MANAGER)
    self.shop_scene = ShopScene(GAME_STATE, RENDER_MANAGER, EVENT_MANAGER, INPUT_MANAGER)

    self.current_scene = nil
    self:switch_scene(self.game_scene)

    self:setup_events()
end


function SceneManager:setup_events()
    self.event_manager:on(
        self.event_manager.events.SWITCHSCREEN_GAME, self, function()
            self:switch_scene(self.game_scene)
        end
    )
    self.event_manager:on(
        self.event_manager.events.SWITCHSCREEN_SHOP, self, function()
            self:switch_scene(self.shop_scene)
        end
    )
end


function SceneManager:switch_scene(new_scene)
    if self.current_scene and self.current_scene.exit then
        self.current_scene:exit()
    end

    self.current_scene = new_scene

    if self.current_scene.enter then
        self.current_scene:enter()
    end
end


function SceneManager:update(dt)
    if self.current_scene and self.current_scene.update then
        self.current_scene:update(dt)
    end
end


function SceneManager:draw()
    if self.current_scene and self.current_scene.draw then
        self.current_scene:draw()
    end
end


return SceneManager
