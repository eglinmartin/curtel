local Class = require("lib.class")
local GameScene = Class{}

local Colours = require("src.render.colours")
local Entity = require("src.entity.entity")
local Item = require("src.entity.item")


function GameScene:init(GAME_STATE, RENDER_MANAGER, EVENT_MANAGER, INPUT_MANAGER)
    self.game_state = GAME_STATE
    self.render_manager = RENDER_MANAGER
    self.event_manager = EVENT_MANAGER
    self.input_manager = INPUT_MANAGER
    self.entities = {}

    -- Create player
    self.player = self.game_state.player
    self.entities["player"] = self.player

    -- Create pointer
    self.pointer = Entity("pointer", GAME_STATE, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, {
        x=54, y=54, w=8, h=8, s=1, r=0,
        sprite_sheet="icons", sprite_tag="down", depth=254,
    })
    self.entities["pointer"] = self.pointer

    -- Set interaction states
    self.hovering = false

    -- Set animation timers
    self.animation_dealing = 0
end


function GameScene:enter()
    -- Clear out sprites from all entities, and clear screen
    for _, entity in pairs(self.entities) do
        entity:clear_sprite()
    end
    self.render_manager:clear_screen()

    -- Update player
    self.player:move(76,103)
    self.player:create_sprite()
    self.player.hand = {}

    -- Set up event handling
    self:setup_events()

    -- Shuffle and deal cards
    self.event_manager:trigger(self.event_manager.events.SHUFFLEDECK)
    self.event_manager:trigger(self.event_manager.events.DEALCARDS)

    self.pointer:create_sprite()

    self:create_sprites()

    self:animate_enter()

end


function GameScene:setup_events()
    -- Shuffle and reset the deck on shuffle command
    self.event_manager:on(
        self.event_manager.events.SHUFFLEDECK, self, function()
            self.player.deck:reset()
            self.player.deck:shuffle()
            if self.enemy then
                self.enemy.deck:reset()
                self.enemy.deck:shuffle()
            end
        end
    )

    -- Deal cards to the player on deal cards command
    self.event_manager:on(
        self.event_manager.events.DEALCARDS, self, function()
            self.animation_dealing = 0
        end
    )

    -- Select card from hand
    self.event_manager:on(
        self.event_manager.events.SELECTCARD, self, function()
            if self.player.selected_card then
                self.render_manager:create_draw_object_foreground(
                    "player_card_large", "cards_large_" .. self.player.selected_card.suit,
                    self.player.selected_card.value, 120.5, 52.5, math.random(-5, 5), 1, 125
                )
                self.render_manager.draw_objects_foreground["player_card_large"]:animate({dscale=0.3})
            end
        end
    )

    -- Select card from hand
    self.event_manager:on(
        self.event_manager.events.DESELECTCARD, self, function()
            self.player.selected_card = nil
            if self.render_manager.draw_objects_foreground["player_card_large"] then
                self.render_manager:remove_draw_object_foreground("player_card_large")
            end
        end
    )

    -- Mouse press event
    self.event_manager:on(
        self.event_manager.events.MOUSEPRESSED, self, function()
        end
    )
end


function GameScene:create_sprites()
    -- Draw background
    self.render_manager:set_shadow_colour(Colours.GREEN5)
    self.render_manager:create_draw_object_background(
        "background", "background", "green", 120, 67.5, 0, 1, 255
    )

    -- Draw furniture
    self.render_manager:create_draw_object_foreground(
        "table", "table", "1", 120, 114.5, 0, 1, 128
    )

    if self.player then
        self.render_manager:create_draw_object_foreground(
            "hud_player_head", "player", "head", 24, 23, 0, 1, 128
        )
        self.render_manager:create_text_object(
            "player_name", "PLAYER", Colours.YELLOW1, 38, 20, 0, 1, 64, "left"
        )

        self.render_manager:create_draw_object_foreground(
            "hud_player_health", "icons", "heart", 19.5, 38.5, 0, 1, 128
        )
        self.render_manager:create_text_object(
            "player_health", tostring(self.player.health),
            Colours.RED1, 26, 36, 0, 1, 64, "left"
        )

        self.render_manager:create_draw_object_foreground(
            "hud_player_money", "icons", "money", 19.5, 49.5, 0, 1, 128
        )
        self.render_manager:create_text_object(
            "player_money", "$" .. tostring(self.player.money), Colours.YELLOW1, 26, 47, 0, 1, 64, "left"
        )
        
        self.render_manager:create_draw_object_foreground(
            "hud_player_deck", "icons", "cards", 19.5, 60.5, 0, 1, 140
        )
        self.render_manager:create_text_object(
            "player_deck", tostring(#self.player.deck.cards), Colours.BROWN1, 26, 58, 0, 1, 64, "left"
        )

        local bullet_icons_xy = {
            {self.player.x, self.player.y - 39},
            {self.player.x + 7, self.player.y - 34},
            {self.player.x + 7, self.player.y - 27},
            {self.player.x, self.player.y - 22},
            {self.player.x - 7, self.player.y - 27},
            {self.player.x - 7, self.player.y - 34}
            
        }
        for i, bullet in pairs(self.player.bullets) do
            self.entities["player_bullet_icon_" .. i] = Entity(
                "player_bullet_icon" .. i, GAME_STATE, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, {
                    x=bullet_icons_xy[i][1], y=bullet_icons_xy[i][2], w=8, h=8, s=1, r=0,
                    sprite_sheet="icons", sprite_tag="bullet_" .. bullet.type, depth=200
                }
            )
            self.entities["player_bullet_icon_" .. i]:create_sprite()
        end
    end

end


function GameScene:animate_enter()
    -- Nod screen items
    self.render_manager.draw_objects_background["background"]:animate({dscale=0.1})
    self.render_manager.draw_objects_foreground["table"]:animate({dy=4})

    -- Nod player items
    if self.player then
        self.render_manager.draw_objects_foreground["player"]:animate({dy=4})
        self.render_manager.draw_objects_foreground["hud_player_head"]:animate({dy=4})
        self.render_manager.draw_objects_foreground["hud_player_health"]:animate({dy=4})
        self.render_manager.draw_objects_foreground["hud_player_money"]:animate({dy=4})
        self.render_manager.draw_objects_foreground["hud_player_deck"]:animate({dy=4})
        
        self.render_manager.text_objects["player_name"]:animate({dy=4})
        self.render_manager.text_objects["player_health"]:animate({dy=4})
        self.render_manager.text_objects["player_money"]:animate({dy=4})
        self.render_manager.text_objects["player_deck"]:animate({dy=4})

        for i, bullet in pairs(self.player.bullets) do
            self.render_manager.draw_objects_foreground["player_bullet_icon" .. i]:animate({dy=4})
        end
    end 
end


function GameScene:animate_dealing(dt)
    self.animation_dealing = self.animation_dealing + 1

    -- Animate player dealing
    if self.player then

        -- Iterate over player hand size
        for i = 1, self.player.hand_size do
            self.card_frame = 1 + (8 * (i-1))

            -- On first frame, reset player's hand
            if self.animation_dealing == 1 then
                self.player.hand = {}
                if self.entities["player_card_" .. i] then
                    self.entities["player_card_" .. i]:clear_sprite()
                    self.entities["player_card_" .. i] = nil
                end
            end

            -- For each card, animate its dealing
            if self.animation_dealing == self.card_frame then

                -- Deal a card
                self.player.hand[i] = self.player.deck:deal_card()

                -- If no more cards left after deal, reset and shuffle deck
                if #self.player.deck.cards == 0 then
                    self.player.deck:reset()
                    self.player.deck:shuffle()
                end
                
                -- Create card entity on screen and animate
                local player_card = self.player.hand[i]
                self.entities["player_card_" .. i] = Item(
                    "player_card_" .. i, self.game_state, self.event_manager, self.input_manager, self.render_manager, {
                    x=11.5+(11*i), y=101.5+(3*i), w=15, h=19, s=1, r=0,
                    sprite_sheet="cards_" .. player_card.suit, sprite_tag=player_card.value, depth=128+i, item=self.player.hand[i],
                    draggable=true, hoverable=true
                })
                self.entities["player_card_" .. i]:animate({dx=-3-(14.5*(i-1)), dy=-44-(3*(i-1)), dscale=-0.5})

                -- Animate deck icon and number
                self.render_manager.draw_objects_foreground["hud_player_deck"]:animate({dscale=0.3})
                self.render_manager:create_text_object(
                    "player_deck", tostring(#self.player.deck.cards), Colours.BROWN1, 26, 58, 0, 1, 64, "left"
                )
                self.render_manager.text_objects["player_deck"]:animate({dx=3})
            end
        end
    end
end


function GameScene:animate_hovering(dt)
    local was_hovering = self.hovering
    local prev_hovered_entity = self.hovered_entity  -- track previous entity
    self.hovering = false
    self.hovered_entity = nil

    for key, entity in pairs(self.entities) do
        if entity.dragging then return end
    end

    for key, entity in pairs(self.entities) do
        if entity.hovered and entity.hoverable then
            self.hovering = true
            self.hovered_entity = entity  -- store current hovered entity

            if not entity.dragging then
                if self.render_manager.draw_objects_foreground[entity.id] then
                    self.render_manager.draw_objects_foreground[entity.id]:animate({dscale=0.2})
                end

                -- Trigger if hover just started OR if we switched to a different entity
                if not was_hovering or prev_hovered_entity ~= entity then
                end
            end

            break
        end
    end

    if not self.hovering then
    end
end


function GameScene:show_bullet_preview(bullet)
    self.render_manager:create_draw_object_foreground(
        "player_bullet_preview", "bullets",
        bullet.item.tag, self.player.x-0.5, self.player.y-58, 0, 1, 125
    )
    self.render_manager.draw_objects_foreground["player_bullet_preview"]:animate({dy=4})
end


function GameScene:animate_dragging(dt)
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

        if entity.released and entity.id:find("player_card_") then
            if math.abs(self.input_manager.mx - 120) <= 16 and math.abs(self.input_manager.my - 52.5) <= 32 then
                self.event_manager:trigger(self.event_manager.events.SELECTCARD)
                entity:clear_sprite()
                self.entities[entity.id] = nil
                self.player.hand[tonumber(entity.id:match("%d+"))] = nil
            end
        end
    end
end


function GameScene:update(dt, mx, my, md, mp)
    for _, entity in pairs(self.entities) do
        entity:update(dt, mx, my, md, mp)
    end

    -- Move cursor back to neutral, off-screen position
    self.pointer:move(-50, -50)

    -- Perform animations
    self:animate_dragging()
    self:animate_dealing()
    self:animate_hovering()

    self.render_manager:create_text_object(
        "fps", "FPS: " .. love.timer.getFPS(), Colours.GREY1, 120, 6, 0, 1, 64, "centre"
    )
end


function GameScene:draw()
    love.graphics.setColor(1, 1, 1, 1)
end


function GameScene:exit()
    self.event_manager:remove_owner(self)
end


return GameScene
