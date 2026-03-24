local Class = require("lib.class")

local Colours = require("src.render.colours")
local Shop = require("src.entity.shop")

local ShopScene = Class{}


local Directions = {
    LEFT = -1,
    RIGHT = 1
}


function ShopScene:init(GAME_STATE, RENDER_MANAGER, EVENT_MANAGER, INPUT_MANAGER)
    self.game_state = GAME_STATE
    self.render_manager = RENDER_MANAGER
    self.event_manager = EVENT_MANAGER
    self.input_manager = INPUT_MANAGER

    self.shop = Shop()

    self.stock_type = self.shop.stock_types.BULLETS
    self.stock_direction = Directions.RIGHT

    self.player = self.game_state.player
    self.animation_title = 0
    self.animation_stock = 0
end


function ShopScene:enter()
    self.render_manager:clear_screen()
    self.event_manager:remove_owner(self)
    self:setup_events()
    
    self.shop:reroll_bullets()
    self.shop:reroll_cards()

    self.animation_title = 0
    self.animation_stock = 0
    self.stock_type = self.shop.stock_types.BULLETS
    self.hovering = false

    self:update_sprites()
    
    self.render_manager:set_shadow_colour(Colours.GREEN5)
    self.render_manager.draw_objects_background["background"].dscale = 0.1
    self.render_manager.draw_objects_foreground["divider_vertical"].dx = -4
end


function ShopScene:update(dt)
    self.shop_stock_xy = {{91, 39}, {113, 39}, {135, 39}, {91, 71}, {113, 71}, {135, 71}}

    self:animate_menu()
    self:animate_stock()

    local found_hover = false
    for i, v in ipairs(self.shop.stock[self.stock_type]) do
        local x = self.shop_stock_xy[i][1]
        local y = self.shop_stock_xy[i][2]
        if self.input_manager.mx > x - 9 and self.input_manager.mx < x + 8 and self.input_manager.my > y - 9 and self.input_manager.my < y + 8 then

            if not self.hovering then
                self.render_manager:create_text_object("text_item_heading", v.item.name, v.colour, 155, 102, 0, 1, 64, "centre")
                self.render_manager:create_text_object("text_item_description", v.item.description, Colours.BROWN2, 155, 115, 0, 0.75, 64, "centre")
                self.render_manager.text_objects["text_item_heading"].dy = 2
                self.render_manager.text_objects["text_item_description"].dy = 2
                self.hovering = true
            end

            self.render_manager.draw_objects_foreground["shop_item" .. i].dscale = 0.1
            self.render_manager.text_objects["shop_item_cost" .. i].dy = 1

            if self.stock_type ==self.shop.stock_types.BULLETS then
                self.render_manager.draw_objects_foreground["shop_item_back" .. i].dscale = 0.1
            end

            found_hover = true
            break
        end
    end
    if not found_hover then
        if self.hovering then
            self.render_manager:remove_text_object("text_item_heading")
            self.render_manager:remove_text_object("text_item_description")
        end
        self.hovering = false
    end
end


function ShopScene:draw()
    love.graphics.setColor(1, 1, 1, 1)
end


function ShopScene:animate_menu()
    self.animation_title = self.animation_title + 1
    local letters = {"S", "H", "O", "P"}
    local x_coords = {0, 10, 22, 32}

    -- Animate shop title
    for i, v in ipairs(letters) do
        self.title_frame = 1 + (5 * (i-1))
        if self.animation_title == self.title_frame then
            self.render_manager:create_draw_object_foreground("title_shop_" .. v, "title_shop", v, 23 + x_coords[i], 25, 0, 1, 255)
            self.render_manager.draw_objects_foreground["title_shop_" .. v].dy = 3
        end
    end
    
    -- Animate player information
    if self.animation_title == 21 then
        self.render_manager:create_text_object("player_name", "PLAYER 1", Colours.GREY2, 17, 44, 0, 1, 64, "left")
        self.render_manager.text_objects["player_name"].dx = -3
    elseif self.animation_title == 26 then
        self.render_manager:create_text_object("player_health", tostring(self.player.health) .. "/" .. tostring(self.player.max_health), Colours.RED1, 26, 55, 0, 1, 64, "left")
        self.render_manager:create_draw_object_foreground("hud_player_health", "icons", "heart", 19.5, 57.5, 0, 1, 128)
        self.render_manager.text_objects["player_health"].dx = -3
        self.render_manager.draw_objects_foreground["hud_player_health"].dx = -3
    elseif self.animation_title == 31 then
        self.render_manager:create_text_object("player_money", "$" .. tostring(self.player.money), Colours.YELLOW1, 26, 66, 0, 1, 64, "left")
        self.render_manager:create_draw_object_foreground("hud_player_money", "icons", "money", 19.5, 68.5, 0, 1, 128)
        self.render_manager.text_objects["player_money"].dx = -3
        self.render_manager.draw_objects_foreground["hud_player_money"].dx = -3
    elseif self.animation_title == 36 then
        self.render_manager:create_text_object("player_deck", tostring(#self.player.deck.cards), Colours.BROWN1, 26, 77, 0, 1, 64, "left")
        self.render_manager:create_draw_object_foreground("hud_player_deck", "icons", "cards", 19.5, 79.5, 0, 1, 128)
        self.render_manager.text_objects["player_deck"].dx = -3
        self.render_manager.draw_objects_foreground["hud_player_deck"].dx = -3

    -- Animate menu text
    elseif self.animation_title == 41 then
        self.render_manager:create_text_object("text_map", "MAP", Colours.GREY2, 17, 102, 0, 1, 64, "left")
        self.render_manager.text_objects["text_map"].dx = -3
    elseif self.animation_title == 46 then
        self.render_manager:create_text_object("text_done", "DONE", Colours.GREY2, 17, 113, 0, 1, 64, "left")
        self.render_manager.text_objects["text_done"].dx = -3
    end
end


function ShopScene:animate_stock()
    self.animation_stock = self.animation_stock + 1
    
    if self.animation_stock == 1 then
        self.render_manager:create_text_object("text_category", self.stock_type:upper(), Colours.GREY2, 113, 17, 0, 1, 64, "centre")
        self.render_manager.text_objects["text_category"].dx = 2 * self.stock_direction

        if self.stock_direction == Directions.LEFT then
            self.render_manager.draw_objects_foreground["category_l"].dscale = -0.5
        elseif self.stock_direction == Directions.RIGHT then
            self.render_manager.draw_objects_foreground["category_r"].dscale = -0.5
        end

        -- Create shop stock
        for i, v in ipairs(self.shop.stock[self.stock_type]) do

            -- Check keyframe
            self.stock_frame = 1 + (0 * (i-1))
            if self.animation_stock == self.stock_frame then

                -- Draw bullets
                if self.stock_type == self.shop.stock_types.BULLETS then
                    self.render_manager:create_draw_object_foreground("shop_item_back" .. i, "bullet_backs", v.item.type, self.shop_stock_xy[i][1] - 0.5, self.shop_stock_xy[i][2] - 0.5, 0, 1, 130)
                    self.render_manager:create_draw_object_foreground("shop_item" .. i, "bullets", v.item.tag, self.shop_stock_xy[i][1] - 0.5, self.shop_stock_xy[i][2] - 0.5, 0, 1, 131)
                    self.render_manager.draw_objects_foreground["shop_item_back" .. i].dx = 2 * self.stock_direction
                    self.render_manager.draw_objects_foreground["shop_item" .. i].dx = 2 * self.stock_direction
                    self.render_manager.draw_objects_foreground["shop_item" .. i].dscale = -0.25
                
                -- Draw cards
                elseif self.stock_type == self.shop.stock_types.CARDS then
                    self.render_manager:create_draw_object_foreground("shop_item" .. i, "cards_" .. v.item.suit, v.item.value, self.shop_stock_xy[i][1] - 0.5, self.shop_stock_xy[i][2] - 0.5, 0, 1, 131)
                    self.render_manager.draw_objects_foreground["shop_item" .. i].dx = 2 * self.stock_direction
                end
            end

            -- Draw cost
            local cost_colour = Colours.YELLOW1
            if v.item.cost > self.player.money then
                cost_colour = Colours.GREY3
            end
            self.render_manager:create_text_object("shop_item_cost" .. i, "$" .. v.item.cost, cost_colour, self.shop_stock_xy[i][1], self.shop_stock_xy[i][2] + 12, 0, 1, 64, "centre")
            self.render_manager.text_objects["shop_item_cost" .. i].dx = 2 * self.stock_direction
        end

        -- Draw gun barrel and player's bullets
        if self.stock_type == self.shop.stock_types.BULLETS then
            local barrel_xy = {190, 53}
            self.render_manager:create_draw_object_foreground("barrel_base", "barrel", "base", barrel_xy[1], barrel_xy[2], 0, 1, 128)
            self.render_manager:create_draw_object_foreground("barrel_chambers", "barrel", "chambers", barrel_xy[1], barrel_xy[2], 0, 1, 129)
            self.render_manager.draw_objects_foreground["barrel_base"].dx = 2 * self.stock_direction
            self.render_manager.draw_objects_foreground["barrel_chambers"].dx = 2 * self.stock_direction

            local chamber_xy = {{0, -23}, {20, -11}, {20, 11},{0, 23}, {-20, 11}, {-20, -11}}
            for i, v in ipairs(chamber_xy) do
                self.render_manager:create_draw_object_foreground("player_bullet_back" .. i, "bullet_backs", self.player.bullets[i].type, barrel_xy[1] + v[1], barrel_xy[2] + v[2], 0, 1, 130)
                self.render_manager:create_draw_object_foreground("player_bullet" .. i, "bullets", self.player.bullets[i].tag, barrel_xy[1] + v[1], barrel_xy[2] + v[2], 0, 1, 131)
                self.render_manager.draw_objects_foreground["player_bullet_back" .. i].dx = 2 * self.stock_direction
                self.render_manager.draw_objects_foreground["player_bullet" .. i].dx = 2 * self.stock_direction
            end

        end
    end
end


function ShopScene:update_sprites()
    self.render_manager:clear_screen()

    self.render_manager:create_draw_object_background("background", "background", "green", 120, 67.5, 0, 1, 255)
    self.render_manager:create_draw_object_foreground("divider_vertical", "divider_vertical", "green", 72, 67.5, 0, 1, 255)

    self.render_manager:create_draw_object_foreground("category_l", "icons", "left", 86.5, 19.5, 0, 1, 129)
    self.render_manager:create_draw_object_foreground("category_r", "icons", "right", 138.5, 19.5, 0, 1, 129)
end


function ShopScene:switch_stock()
    if self.stock_type == self.shop.stock_types.BULLETS then
        self.stock_type = self.shop.stock_types.CARDS
        self.render_manager:remove_draw_object_foreground("barrel_base")
        self.render_manager:remove_draw_object_foreground("barrel_chambers")
        for i = 1, #self.shop.stock["bullets"] do
            self.render_manager:remove_draw_object_foreground("player_bullet" .. i)
            self.render_manager:remove_draw_object_foreground("player_bullet_back" .. i)
            self.render_manager:remove_draw_object_foreground("shop_item" .. i)
            self.render_manager:remove_draw_object_foreground("shop_item_back" .. i)
            self.render_manager:remove_text_object("shop_item_cost" .. i)
        end

    elseif self.stock_type == self.shop.stock_types.CARDS then
        self.stock_type = self.shop.stock_types.BULLETS
        for i = 1, #self.shop.stock["cards"] do
            self.render_manager:remove_draw_object_foreground("shop_item" .. i)
            self.render_manager:remove_draw_object_foreground("shop_item_cost" .. i)
        end
    end

    self.animation_stock = 0
end


function ShopScene:setup_events()
    -- Switch stock
    self.event_manager:on(
        self.event_manager.events.SWITCHSTOCK_LEFT, self, function()
            self.stock_direction = Directions.LEFT
            self:switch_stock()
        end
    )

    self.event_manager:on(
        self.event_manager.events.SWITCHSTOCK_RIGHT, self, function()
            self.stock_direction = Directions.RIGHT
            self:switch_stock()
        end
    )
end


function ShopScene:exit()
end


return ShopScene
