local Class = require("lib.class")
local Shop = require("src.entity.shop")

local ShopScene = Class{}


function ShopScene:init(GAME_STATE, RENDER_MANAGER, EVENT_MANAGER)
    self.game_state = GAME_STATE
    self.render_manager = RENDER_MANAGER
    self.event_manager = EVENT_MANAGER

    self.shop = Shop()

    self.player = self.game_state.player
    self.animation_title = 0
end


function ShopScene:update(dt)
    self:animate_title()
end


function ShopScene:draw()
    love.graphics.setColor(1, 1, 1, 1)
end


function ShopScene:animate_title()
    self.animation_title = self.animation_title + 1
    local letters = {"S", "H", "O", "P"}
    local x_coords = {0, 11, 24, 35}

    for i, v in ipairs(letters) do
        self.title_frame = 1 + (5 * (i-1))

        if self.animation_title == self.title_frame then
            self.render_manager:create_draw_object_foreground("title_shop_" .. v, "title_shop", v, 22 + x_coords[i], 25, 0, 1, 255)
            self.render_manager.draw_objects_foreground["title_shop_" .. v].dy = 3
        end

    end
    
    -- Draw player's hud (text)
    if self.animation_title == 21 then
        self.render_manager:create_text_object("player_name", "PLAYER 1", self.render_manager.colours.GREY2, 16, 44, 0, 1, 64, "left")
        self.render_manager.text_objects["player_name"].dx = -3
        
    elseif self.animation_title == 26 then
        self.render_manager:create_text_object("player_health", tostring(self.player.health) .. "/" .. tostring(self.player.max_health), self.render_manager.colours.RED1, 25, 55, 0, 1, 64, "left")
        self.render_manager:create_draw_object_foreground("hud_player_health", "icons", "heart", 18.5, 57.5, 0, 1, 128)
        self.render_manager.text_objects["player_health"].dx = -3
        self.render_manager.draw_objects_foreground["hud_player_health"].dx = -3

    elseif self.animation_title == 31 then
        self.render_manager:create_text_object("player_money", "$" .. tostring(self.player.money), self.render_manager.colours.YELLOW1, 25, 66, 0, 1, 64, "left")
        self.render_manager:create_draw_object_foreground("hud_player_money", "icons", "money", 18.5, 68.5, 0, 1, 128)
        self.render_manager.text_objects["player_money"].dx = -3
        self.render_manager.draw_objects_foreground["hud_player_money"].dx = -3

    elseif self.animation_title == 36 then
        self.render_manager:create_text_object("player_deck", tostring(#self.player.deck.cards), self.render_manager.colours.BROWN1, 25, 77, 0, 1, 64, "left")
        self.render_manager:create_draw_object_foreground("hud_player_deck", "icons", "cards", 18.5, 79.5, 0, 1, 128)
        self.render_manager.text_objects["player_deck"].dx = -3
        self.render_manager.draw_objects_foreground["hud_player_deck"].dx = -3
    end
end


function ShopScene:enter()
    self.animation_title = 0

    self:update_sprites()
    self.render_manager:set_shadow_colour(self.render_manager.colours.GREEN5)
    self.render_manager.draw_objects_background["background"].dscale = 0.1
    self.render_manager.draw_objects_foreground["barrel_base"].dy = 4
    self.render_manager.draw_objects_foreground["barrel_chambers"].dy = 4

end


function ShopScene:update_sprites()
    self.render_manager:clear_screen()

    local barrel_xy = {189.5, 59.5}
    self.render_manager:create_draw_object_background("background", "background", "green", 120, 67.5, 0, 1, 255)
    self.render_manager:create_draw_object_foreground("barrel_base", "barrel", "base", barrel_xy[1], barrel_xy[2], 0, 1, 128)
    self.render_manager:create_draw_object_foreground("barrel_chambers", "barrel", "chambers", barrel_xy[1], barrel_xy[2], 0, 1, 129)

    local chamber_xy = {{0.5, -22.5}, {19.5, -11.5}, {19.5, 10.5},{-0.5, 22.5}, {-19.5, 10.5}, {-19.5, -11.5}}
    for i, v in ipairs(chamber_xy) do
        self.render_manager:create_draw_object_foreground("player_token" .. i, "tokens", self.player.tokens[i].tag, barrel_xy[1] + v[1], barrel_xy[2] + v[2], 0, 1, 130)
    end

    local shop_tokens_xy = {{90, 38}, {112, 38}, {134, 38}, {90, 71}, {112, 71}, {134, 71}}
    for i, v in ipairs(self.shop.stock["tokens"]) do
        self.render_manager:create_draw_object_foreground("shop_token" .. i, "tokens", v.tag, shop_tokens_xy[i][1] - 0.5, shop_tokens_xy[i][2] - 0.5, 0, 1, 130)
        self.render_manager:create_text_object("shop_token_cost" .. i, "$" .. v.cost, self.render_manager.colours.YELLOW1, shop_tokens_xy[i][1], shop_tokens_xy[i][2] + 11, 0, 1, 64, "centre")
    end
end


function ShopScene:setup_events()
end


function ShopScene:exit()
end


return ShopScene
