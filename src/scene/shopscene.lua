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

local EMPTY = "empty"


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
    self.stock_type = self.shop.stock_types.CARDS
    self.hovering = false

    self.barrel_xy = {190, 53}
    self.barrel_bullets_xy = {
            {self.barrel_xy[1], self.barrel_xy[2]-23},
            {self.barrel_xy[1]+20, self.barrel_xy[2]-11},
            {self.barrel_xy[1]+20, self.barrel_xy[2]+11},
            {self.barrel_xy[1], self.barrel_xy[2]+23},
            {self.barrel_xy[1]-20, self.barrel_xy[2]+11},
            {self.barrel_xy[1]-20, self.barrel_xy[2]-11}
        }
    
    self.shop_bullets_xy = {{91, 39}, {113, 39}, {135, 39}, {91, 71}, {113, 71}, {135, 71}}
    self.shop_cards_xy = {{91, 39}, {113, 39}, {135, 39}, {91, 71}, {113, 71}, {135, 71}}

    self.render_manager:create_draw_object_background("background", "background", "green", 120, 67.5, 0, 1, 1)
    self.render_manager:create_draw_object_foreground("divider_vertical", "divider_vertical", "green", 72, 67.5, 0, 1, 1)

    self.entities["category_l"] = Entity(
        "category_l", self.game_state, self.event_manager, self.input_manager, self.render_manager, 
        {x=86.5, y=19.5, w=15, h=15, s=1, r=0,sprite_sheet="icons", sprite_tag="left", depth=128, draggable=false, hoverable=true}
    )
    self.entities["category_l"]:create_sprite()

    self.entities["category_r"] = Entity(
        "category_r", self.game_state, self.event_manager, self.input_manager, self.render_manager, 
        {x=138.5, y=19.5, w=15, h=15, s=1, r=0,sprite_sheet="icons", sprite_tag="right", depth=128, draggable=false, hoverable=true}
    )
    self.entities["category_l"]:create_sprite()

    self.bin_xy = {216, 103}
    self.entities["dustbin"] = Entity(
        "dustbin", self.game_state, self.event_manager, self.input_manager, self.render_manager, 
        {x=self.bin_xy[1], y=self.bin_xy[2], w=25, h=32, s=1, r=0,sprite_sheet="dustbin", sprite_tag="closed", depth=128, draggable=false}
    )
    self.entities["dustbin"]:create_sprite()

    self.event_manager:trigger(self.event_manager.events.SWITCHSTOCK_RIGHT)

    self.render_manager:set_shadow_colour(Colours.GREEN5)
    self.render_manager.draw_objects_background["background"]:animate({dx=-4, dscale=0.1})
end


function ShopScene:update(dt, mx, my, md, mp)
    for _, entity in pairs(self.entities) do
        if entity ~= EMPTY then
            entity:update(dt, mx, my, md, mp)
        end
    end

    if self.entities["category_l"].clicked then
        self.event_manager:trigger(self.event_manager.events.SWITCHSTOCK_LEFT)
    end

    if self.entities["category_r"].clicked then
        self.event_manager:trigger(self.event_manager.events.SWITCHSTOCK_RIGHT)
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
    self.animation_stock = self.animation_stock + 1
    
    if self.animation_stock == 1 then
        self.render_manager:create_text_object("text_category", self.stock_type:upper(), Colours.GREY2, 113, 17, 0, 1, 64, "centre")
        self.render_manager.text_objects["text_category"]:animate({dx = 2 * self.stock_direction})

        if self.stock_direction == Directions.LEFT then
            self.entities["category_l"]:animate({dx=-4, dscale=-0.5})
        elseif self.stock_direction == Directions.RIGHT then
            self.entities["category_r"]:animate({dx=4, dscale=-0.5})
        end

        -- Draw gun barrel and player's bullets
        if self.stock_type == self.shop.stock_types.BULLETS then
            self.render_manager:create_draw_object_foreground("barrel_base", "barrel", "base", self.barrel_xy[1], self.barrel_xy[2], 0, 1, 128)
            self.render_manager:create_draw_object_foreground("barrel_chambers", "barrel", "chambers", self.barrel_xy[1], self.barrel_xy[2], 0, 1, 129)
            self.render_manager.draw_objects_foreground["barrel_base"]:animate({dy=4})
            self.render_manager.draw_objects_foreground["barrel_chambers"]:animate({dy=4})
            for i, v in pairs(self.player.bullets) do
                if v then
                    self.entities["player_bullet_" .. i]:animate({dy=4})
                    self.entities["player_bullet_" .. i]:create_sprite()
                end
            end
        
        elseif self.stock_type == self.shop.stock_types.CARDS then
            self.render_manager:create_draw_object_foreground("deck", "deck", "deck", self.barrel_xy[1], self.barrel_xy[2], 0, 1, 128)
            self.render_manager.draw_objects_foreground["deck"]:animate({dy=4})
        end
        
    end

    -- Create shop stock
    for i = 1, #self.shop.stock[self.stock_type] do
        local v = self.shop.stock[self.stock_type][i]

        if v then

            -- Check keyframe
            if self.stock_type == self.shop.stock_types.BULLETS then
                self.stock_frame = 1 + (4 * (i-1))
            elseif self.stock_type == self.shop.stock_types.CARDS then
                self.stock_frame = 1 + (4 * (i-1))
            end
            if self.animation_stock == self.stock_frame then

                -- Draw bullets
                if self.stock_type == self.shop.stock_types.BULLETS then
                    self:redraw_cost(i, v)
                    self.render_manager.text_objects["shop_item_cost_" .. i]:animate({dy=4})

                    if v ~= EMPTY then
                        self.entities["shop_item_" .. i] = Item(
                            "shop_item_" .. i, self.game_state, self.event_manager, self.input_manager, self.render_manager, {
                            x=self.shop_bullets_xy[i][1]-0.5, y=self.shop_bullets_xy[i][2]-0.5, w=19, h=19, s=1, r=0,
                            sprite_sheet="bullets", sprite_tag=v.item.tag, depth=128+i, item=v.item, draggable=true, hoverable=true
                        })
                        self.entities["shop_item_" .. i]:animate({dy=4})
                    end

                -- Draw cards
                elseif self.stock_type == self.shop.stock_types.CARDS then
                    self:redraw_cost(i, v)
                    self.render_manager.text_objects["shop_item_cost_" .. i]:animate({dy=4})

                    if v ~= EMPTY then
                        self.entities["shop_item_" .. i] = Item(
                            "shop_item_" .. i, self.game_state, self.event_manager, self.input_manager, self.render_manager, {
                            x=self.shop_cards_xy[i][1]-0.5, y=self.shop_cards_xy[i][2]-0.5, w=19, h=19, s=1, r=0,
                            sprite_sheet="cards_" .. v.item.suit, sprite_tag=v.item.value, depth=128+i, item=v.item, draggable=true, hoverable=true
                        })
                        self.entities["shop_item_" .. i]:animate({dy=4})
                    end
                end
                
            end
        end

    end
end


function ShopScene:redraw_cost(i, entity)
    local cost_colour = Colours.YELLOW1

    local xy = {0, 0}
    if self.stock_type == self.shop.stock_types.BULLETS then
        xy = self.shop_bullets_xy[i]
    elseif self.stock_type == self.shop.stock_types.CARDS then
        xy = self.shop_cards_xy[i]
    end

    if entity ~= EMPTY then
        if entity.item.cost > self.player.money then
            cost_colour = Colours.GREY3
        end
        self.render_manager:create_text_object("shop_item_cost_" .. i, "$" .. entity.item.cost, cost_colour, xy[1], xy[2] + 12, 0, 1, 64, "centre")
        
    else
        self.render_manager:create_text_object("shop_item_cost_" .. i, "SOLD", Colours.RED2, xy[1], xy[2] + 12, 0, 1, 64, "centre")
    end
end


function ShopScene:animate_hovering(dt)
    -- Default to no hovering
    self.hovering = false

    -- Prevent items being hovered if any item is being dragged
    for key, entity in pairs(self.entities) do
        if entity.dragging then return end
    end

    -- Loop through any card in player's hand
    for key, entity in pairs(self.entities) do
        if entity.hovered and entity.hoverable then
            self.hovering = true

            -- If entity isn't being dragged, then enlarge and move pointer
            if not entity.dragging then
                if self.render_manager.draw_objects_foreground[entity.id] then
                    self.render_manager.draw_objects_foreground[entity.id]:animate({dscale=0.2})
                end
            end

            -- Break so that no other items hover - only one at a time
            break
        end
    end
end


function ShopScene:discard_bullet(key, entity)
    if math.abs(entity.release_x - self.bin_xy[1]) <= 15 and math.abs(entity.release_y - self.bin_xy[2]) <= 18 then
        entity:clear_sprite()
        self.entities[key] = EMPTY
        local i = tonumber(key:match("player_bullet_(%d+)"))
        if i then
            self.player.bullets[i] = nil
            self.entities["dustbin"]:animate({dscale=-0.2})
        end
    end
end


function ShopScene:move_bullet(key, entity)
    local buy_tolerance = 7
    for barrel_bullet_i, xy in ipairs(self.barrel_bullets_xy) do
        if math.abs(entity.release_x - xy[1]) <= buy_tolerance and math.abs(entity.release_y - xy[2]) <= buy_tolerance then
            local picked_up_bullet_i = tonumber(key:match("player_bullet_(%d+)"))
            if picked_up_bullet_i then

                -- Store the picked up bullet
                local picked_up_entity = self.entities["player_bullet_" .. picked_up_bullet_i].item

                -- If chamber is empty, simply destroy the picked-up bullet (nothing to replace it with)
                if self.entities["player_bullet_" .. barrel_bullet_i] == nil or self.entities["player_bullet_" .. barrel_bullet_i] == EMPTY then
                    -- Remove old bullet item
                    self.player.bullets[picked_up_bullet_i] = nil
                    self.entities["player_bullet_" .. picked_up_bullet_i]:clear_sprite()
                    self.entities["player_bullet_" .. picked_up_bullet_i] = nil

                -- If chamber isn't empty, then replace the picked-up bullet's item with the stored chamber's item
                else
                    -- Store the barrel bullet and replace the picked up bullet with the stored barrel bullet
                    local barrel_entity = self.entities["player_bullet_" .. barrel_bullet_i].item
                    self.entities["player_bullet_" .. picked_up_bullet_i].item = barrel_entity
                    self.player.bullets[picked_up_bullet_i] = barrel_entity

                    -- Update sprite tags for each bullet and redraw
                    self.entities["player_bullet_" .. picked_up_bullet_i].sprite_tag = barrel_entity.tag
                    self.entities["player_bullet_" .. picked_up_bullet_i]:create_sprite()
                    self.entities["player_bullet_" .. barrel_bullet_i].sprite_tag = picked_up_entity.tag
                    self.entities["player_bullet_" .. barrel_bullet_i]:create_sprite()
                end

                -- Create new player bullet item
                self.player.bullets[barrel_bullet_i] = picked_up_entity
                self.entities["player_bullet_" .. barrel_bullet_i] = Item(
                    "player_bullet_" .. barrel_bullet_i, self.game_state, self.event_manager, self.input_manager, self.render_manager, {
                    x=self.barrel_bullets_xy[barrel_bullet_i][1], y=self.barrel_bullets_xy[barrel_bullet_i][2], w=19, h=19, s=1, r=0,
                    sprite_sheet="bullets", sprite_tag=picked_up_entity.tag, depth=230, item=picked_up_entity, draggable=true, hoverable=true
                })
                self.entities["player_bullet_" .. barrel_bullet_i]:create_sprite()
                self.entities["player_bullet_" .. barrel_bullet_i]:animate({dscale=-0.25})
                self.render_manager.draw_objects_foreground["barrel_base"]:animate({dscale=-0.025})
            end
        end
    end
end


function ShopScene:buy_bullet(key, entity)
    local buy_tolerance = 7
    local entity_id = tonumber(entity.id:match("(%d+)$"))

    for i, xy in ipairs(self.barrel_bullets_xy) do
        if math.abs(entity.release_x - xy[1]) <= buy_tolerance and math.abs(entity.release_y - xy[2]) <= buy_tolerance then
            if self.player.bullets[i] == nil then
                
                -- If player can afford it:
                if self.player.money >= entity.item.cost then
                    self.player.money = self.player.money - entity.item.cost
                    self.render_manager:create_text_object("player_money", "$" .. tostring(self.player.money), Colours.YELLOW1, 26, 66, 0, 1, 64, "left")
                    self.render_manager.text_objects["player_money"]:animate({dx=-3})
                    self.render_manager.draw_objects_foreground["hud_player_money"]:animate({dscale=0.8})
                    
                    -- Buy item
                    self.player.bullets[i] = entity.item

                    -- Remove item from shop stock
                    entity:clear_sprite()
                    self.entities[key] = nil
                    self.shop.stock["bullets"][entity_id] = EMPTY
                    self.render_manager:remove_text_object("shop_item_cost_" .. entity_id)
                    
                    -- Update costs
                    for j = 1, #self.shop.stock[self.stock_type] do
                        local v = self.shop.stock[self.stock_type][j]
                        self:redraw_cost(j, v)
                    end
                    self.render_manager.text_objects["shop_item_cost_" .. entity_id]:animate({dscale=0.5, dy=-4})

                    -- Create new player bullet item and animate
                    self.entities["player_bullet_" .. i] = Item(
                        "player_bullet_" .. i, self.game_state, self.event_manager, self.input_manager, self.render_manager, {
                        x=self.barrel_bullets_xy[i][1], y=self.barrel_bullets_xy[i][2], w=19, h=19, s=1, r=0,
                        sprite_sheet="bullets", sprite_tag=entity.item.tag, depth=230, item=entity.item, draggable=true, hoverable=true
                    })
                    self.entities["player_bullet_" .. i]:create_sprite()
                    self.entities["player_bullet_" .. i]:animate({dscale=-0.25})
                    self.render_manager.draw_objects_foreground["barrel_base"]:animate({dscale=-0.025})
                    break

                -- If player can't afford it, emphasize cost
                else
                    if self.render_manager.text_objects["shop_item_cost_" .. entity_id] then
                        self.render_manager.text_objects["shop_item_cost_" .. entity_id]:animate({dscale=0.5, dy=-4})
                    end
                end
                
            end
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
        end
    end

    -- Release dragged entity
    for key, entity in pairs(self.entities) do
        if entity ~= EMPTY then

            -- Perform operations on player's bullets in barrel
            if string.find(key, "player_bullet_") and entity.released then

                -- Discard player bullet if above dustbin
                self:discard_bullet(key, entity)

                -- Move player bullet to empty slot in barrel
                self:move_bullet(key, entity)
            end

            -- Buy item from shop if moved to empty barrel chamber
            if string.find(key, "shop_item_") and entity.released then
                self:buy_bullet(key, entity)
            end
        end
    end
end


function ShopScene:switch_stock()
    if self.stock_type == self.shop.stock_types.BULLETS then
        self.stock_type = self.shop.stock_types.CARDS
    elseif self.stock_type == self.shop.stock_types.CARDS then
        self.stock_type = self.shop.stock_types.BULLETS
    end

    for _, text_obj in pairs(self.render_manager.text_objects) do
        if string.find(text_obj.name, "shop_item_cost_") then
            self.render_manager:remove_text_object(text_obj.name)
        end
    end

    if self.stock_type == self.shop.stock_types.BULLETS then
        for i, v in pairs(self.player.bullets) do
            if v then
                self.entities["player_bullet_" .. i] = Item(
                    "player_bullet_" .. i, self.game_state, self.event_manager, self.input_manager, self.render_manager, {
                    x=self.barrel_bullets_xy[i][1], y=self.barrel_bullets_xy[i][2], w=19, h=19, s=1, r=0,
                    sprite_sheet="bullets", sprite_tag=v.tag, depth=230, item=v, draggable=true, hoverable=true
                })
            end
        end

    else
        self.render_manager:remove_draw_object_foreground("barrel_base")
        self.render_manager:remove_draw_object_foreground("barrel_chambers")
        for i = 1, #self.shop.stock["bullets"] do
            if self.entities["shop_item_" .. i] then
                self.entities["shop_item_" .. i]:clear_sprite()
                self.entities["shop_item_" .. i] = nil
                self.render_manager.text_objects["shop_item_cost_" .. i] = nil
            end
        end

        for i, v in pairs(self.player.bullets) do
            if v then
                if self.entities["player_bullet_" .. i] then
                    self.entities["player_bullet_" .. i]:clear_sprite()
                    self.entities["player_bullet_" .. i] = nil
                end
            end
        end
    end

    if self.stock_type == self.shop.stock_types.CARDS then
    else
        self.render_manager:remove_draw_object_foreground("deck")
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