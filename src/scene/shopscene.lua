local Class = require("lib.class")

local ShopScene = Class{}


function ShopScene:init(GAME_STATE, RENDER_MANAGER, EVENT_MANAGER)
    self.game_state = GAME_STATE
    self.render_manager = RENDER_MANAGER
    self.event_manager = EVENT_MANAGER

    self.player = self.game_state.player
end


function ShopScene:update(dt)
end


function ShopScene:draw()
    love.graphics.setColor(1, 1, 1, 1)
end


function ShopScene:enter()
    self:update_sprites()
    self.render_manager:set_shadow_colour(self.render_manager.colours.GREEN4)
    self.render_manager.draw_objects_background["background"].dscale = 0.1
    self.render_manager.draw_objects_foreground["barrel_base"].dy = 4
    self.render_manager.draw_objects_foreground["barrel_chambers"].dy = 4

    self.render_manager.draw_objects_foreground["player_token1"].dy = 4
    self.render_manager.draw_objects_foreground["player_token2"].dy = 4
    self.render_manager.draw_objects_foreground["player_token3"].dy = 4
    self.render_manager.draw_objects_foreground["player_token4"].dy = 4
    self.render_manager.draw_objects_foreground["player_token5"].dy = 4
    self.render_manager.draw_objects_foreground["player_token6"].dy = 4

end


function ShopScene:update_sprites()
    self.render_manager:clear_screen()
    self.render_manager:create_draw_object_background("background", "background", "red", 120, 67.5, 0, 1, 255)
    self.render_manager:create_draw_object_foreground("barrel_base", "barrel", "base", 138, 54, 0, 1, 128)
    self.render_manager:create_draw_object_foreground("barrel_chambers", "barrel", "chambers", 138, 54, 0, 1, 129)

    self.render_manager:create_draw_object_foreground("player_token1", "tokens", self.player.tokens[1].tag, 138.5, 31.5, 0, 1, 130)
    self.render_manager:create_draw_object_foreground("player_token2", "tokens", self.player.tokens[2].tag, 157.5, 42.5, 0, 1, 130)
    self.render_manager:create_draw_object_foreground("player_token3", "tokens", self.player.tokens[3].tag, 157.5, 64.5, 0, 1, 130)
    self.render_manager:create_draw_object_foreground("player_token4", "tokens", self.player.tokens[4].tag, 137.5, 76.5, 0, 1, 130)
    self.render_manager:create_draw_object_foreground("player_token5", "tokens", self.player.tokens[5].tag, 118.5, 64.5, 0, 1, 130)
    self.render_manager:create_draw_object_foreground("player_token6", "tokens", self.player.tokens[6].tag, 118.5, 42.5, 0, 1, 130)

end


function ShopScene:setup_events()
end


function ShopScene:exit()
end


return ShopScene
