local Class = require("lib.class")

local Colours = require("src.render.colours")
local Entity = require("src.entity.entity")
local Item = require("src.entity.item")
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

    self.entities = {}
    
    self.shop:reroll_bullets()
    self.shop:reroll_cards()

    self.animation_title = 0
    self.animation_stock = 0
    self.stock_type = self.shop.stock_types.BULLETS
    self.hovering = false

    self.shop_bullets_xy = {{91, 39}, {113, 39}, {135, 39}, {91, 71}, {113, 71}, {135, 71}}
    self.shop_cards_xy = {{89, 55}, {105, 55}, {121, 55}, {137, 55}}

    self:update_sprites()
    
    self.render_manager:set_shadow_colour(Colours.GREEN5)
    self.render_manager.draw_objects_background["background"]:animate({dx=-4, dscale=0.1})
end


function ShopScene:update(dt, mx, my, md, mp)
    for _, entity in pairs(self.entities) do
        entity:update(dt, mx, my, md, mp)
    end

    self:animate_menu()
    self:animate_stock()

    self:animate_hovering()
    self:animate_dragging()
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
            self.render_manager.draw_objects_foreground["title_shop_" .. v]:animate({dy=3})
        end
    end
    
    -- Animate player information
    if self.animation_title == 21 then
        self.render_manager:create_text_object("player_name", "PLAYER 1", Colours.GREY2, 17, 44, 0, 1, 64, "left")
        self.render_manager.text_objects["player_name"]:animate({dx=-3})
    elseif self.animation_title == 26 then
        self.render_manager:create_text_object("player_health", tostring(self.player.health) .. "/" .. tostring(self.player.max_health), Colours.RED1, 26, 55, 0, 1, 64, "left")
        self.render_manager:create_draw_object_foreground("hud_player_health", "icons", "heart", 19.5, 57.5, 0, 1, 128)
        self.render_manager.text_objects["player_health"]:animate({dx=-3})
        self.render_manager.draw_objects_foreground["hud_player_health"]:animate({dx=-3})
    elseif self.animation_title == 31 then
        self.render_manager:create_text_object("player_money", "$" .. tostring(self.player.money), Colours.YELLOW1, 26, 66, 0, 1, 64, "left")
        self.render_manager:create_draw_object_foreground("hud_player_money", "icons", "money", 19.5, 68.5, 0, 1, 128)
        self.render_manager.text_objects["player_money"]:animate({dx=-3})
        self.render_manager.draw_objects_foreground["hud_player_money"]:animate({dx=-3})
    elseif self.animation_title == 36 then
        self.render_manager:create_text_object("player_deck", tostring(#self.player.deck.cards), Colours.BROWN1, 26, 77, 0, 1, 64, "left")
        self.render_manager:create_draw_object_foreground("hud_player_deck", "icons", "cards", 19.5, 79.5, 0, 1, 128)
        self.render_manager.text_objects["player_deck"]:animate({dx=-3})
        self.render_manager.draw_objects_foreground["hud_player_deck"]:animate({dx=-3})

    -- Animate menu text
    elseif self.animation_title == 41 then
        self.render_manager:create_text_object("text_map", "MAP", Colours.GREY2, 17, 102, 0, 1, 64, "left")
        self.render_manager.text_objects["text_map"]:animate({dx=-3})
    elseif self.animation_title == 46 then
        self.render_manager:create_text_object("text_done", "DONE", Colours.GREY2, 17, 113, 0, 1, 64, "left")
        self.render_manager.text_objects["text_done"]:animate({dx=-3})
    end
end


function ShopScene:animate_stock()
    local cost_colour = Colours.YELLOW1
    self.animation_stock = self.animation_stock + 1
    
    if self.animation_stock == 1 then
        self.render_manager:create_text_object("text_category", self.stock_type:upper(), Colours.GREY2, 113, 17, 0, 1, 64, "centre")
        self.render_manager.text_objects["text_category"]:animate({dx = 4 * -self.stock_direction})

        if self.stock_direction == Directions.LEFT then
            self.render_manager.draw_objects_foreground["category_l"]:animate({dx=-4, dscale=-0.5})
        elseif self.stock_direction == Directions.RIGHT then
            self.render_manager.draw_objects_foreground["category_r"]:animate({dx=4, dscale=-0.5})
        end
        
    end

    -- Create shop stock
    for i, v in ipairs(self.shop.stock[self.stock_type]) do

        -- Check keyframe
        if self.stock_type == self.shop.stock_types.BULLETS then
            self.stock_frame = 1 + (4 * (i-1))
        elseif self.stock_type == self.shop.stock_types.CARDS then
            self.stock_frame = 1 + (6 * (i-1))
        end
        if self.animation_stock == self.stock_frame then

            -- Draw bullets
            if self.stock_type == self.shop.stock_types.BULLETS then
                self.entities["shop_item_" .. i] = Item(
                    "shop_item_" .. i, self.game_state, self.event_manager, self.input_manager, self.render_manager, {
                    x=self.shop_bullets_xy[i][1]-0.5, y=self.shop_bullets_xy[i][2]-0.5, w=19, h=19, s=1, r=0,
                    sprite_sheet="bullets", sprite_tag=v.item.tag, depth=128+i, item=v.item, draggable=true
                })
                self.entities["shop_item_" .. i]:animate({dy=4})
                if v.item.cost > self.player.money then
                    cost_colour = Colours.GREY3
                end
                self.render_manager:create_text_object("shop_item_cost_" .. i, "$" .. v.item.cost, cost_colour, self.shop_bullets_xy[i][1], self.shop_bullets_xy[i][2] + 12, 0, 1, 64, "centre")
                self.render_manager.text_objects["shop_item_cost_" .. i]:animate({dy=4})

            elseif self.stock_type == self.shop.stock_types.CARDS then
                self.entities["shop_item_" .. i] = Item(
                    "shop_item_" .. i, self.game_state, self.event_manager, self.input_manager, self.render_manager, {
                    x=self.shop_cards_xy[i][1]-0.5, y=self.shop_cards_xy[i][2]-0.5, w=19, h=19, s=1, r=0,
                    sprite_sheet="cards_" .. v.item.suit, sprite_tag=v.item.value, depth=128+i, item=v.item, draggable=true
                })
                self.entities["shop_item_" .. i]:animate({dy=4})
                if v.item.cost > self.player.money then
                    cost_colour = Colours.GREY3
                end
                self.render_manager:create_text_object("shop_item_cost_" .. i, "$" .. v.item.cost, cost_colour, self.shop_cards_xy[i][1], self.shop_cards_xy[i][2] + 12, 0, 1, 64, "centre")
                self.render_manager.text_objects["shop_item_cost_" .. i]:animate({dy=4})
            end
            
        end




        -- -- Draw gun barrel and player's bullets
        -- if self.stock_type == self.shop.stock_types.BULLETS then
        --     local barrel_xy = {190, 53}
        --     self.render_manager:create_draw_object_foreground("barrel_base", "barrel", "base", barrel_xy[1], barrel_xy[2], 0, 1, 128)
        --     self.render_manager:create_draw_object_foreground("barrel_chambers", "barrel", "chambers", barrel_xy[1], barrel_xy[2], 0, 1, 129)
        --     self.render_manager.draw_objects_foreground["barrel_base"].dx = 2 * self.stock_direction
        --     self.render_manager.draw_objects_foreground["barrel_chambers"].dx = 2 * self.stock_direction

        --     local chamber_xy = {{0, -23}, {20, -11}, {20, 11},{0, 23}, {-20, 11}, {-20, -11}}
        --     for i, v in ipairs(chamber_xy) do
        --         self.render_manager:create_draw_object_foreground("player_bullet_back" .. i, "bullet_backs", self.player.bullets[i].type, barrel_xy[1] + v[1], barrel_xy[2] + v[2], 0, 1, 130)
        --         self.render_manager:create_draw_object_foreground("player_bullet" .. i, "bullets", self.player.bullets[i].tag, barrel_xy[1] + v[1], barrel_xy[2] + v[2], 0, 1, 131)
        --         self.render_manager.draw_objects_foreground["player_bullet_back" .. i].dx = 2 * self.stock_direction
        --         self.render_manager.draw_objects_foreground["player_bullet" .. i].dx = 2 * self.stock_direction
        --     end

        -- end
    end
end


function ShopScene:animate_hovering(dt)
    -- Default to no hovering
    self.hovering = false

    -- Loop through any card in player's hand
    for key, entity in pairs(self.entities) do
        if entity.hovered then
            self.hovering = true

            -- If card isn't being dragged, then enlarge and move pointer
            if not entity.dragging then
                self.render_manager.draw_objects_foreground[entity.id]:animate({dscale=0.2})
            end

            -- Break so that no other items hover - only one at a time
            break
        end
    end
end


function ShopScene:animate_dragging(dt)
    local drag_entities = {}
    for _, entity in pairs(self.entities) do
        if entity.dragging then
            drag_entities[#drag_entities + 1] = entity
        end
    end

    if #drag_entities > 1 then
        local max_depth = -math.huge
        for _, entity in ipairs(drag_entities) do
            if entity.depth > max_depth then
                max_depth = entity.depth
            end
        end
        for _, entity in ipairs(drag_entities) do
            if entity.depth ~= max_depth then
                entity.dragging = (entity.depth == max_depth)
            end
        end
    end

    for _, entity in pairs(self.entities) do
        if entity.dragging then
            entity:drag()
            self.player.selected_card = entity.item
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
            if self.entities["shop_item_" .. i] then
                self.entities["shop_item_" .. i]:clear_sprite()
                self.entities["shop_item_" .. i] = nil
                self.render_manager.text_objects["shop_item_cost_" .. i] = nil
            end
        end

    elseif self.stock_type == self.shop.stock_types.CARDS then
        self.stock_type = self.shop.stock_types.BULLETS
        for i = 1, #self.shop.stock["cards"] do
            if self.entities["shop_item_" .. i] then
                self.entities["shop_item_" .. i]:clear_sprite()
                self.entities["shop_item_" .. i] = nil
                self.render_manager.text_objects["shop_item_cost_" .. i] = nil
            end
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