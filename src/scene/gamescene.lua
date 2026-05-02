local Class = require("lib.class")

local GameScene = Class{}

local Colours = require("src.render.colours")
local Deck = require("src.entity.deck")
local Enemy = require("src.entity.enemy")
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

    -- Create selection cursor
    self.selection_cursor = Entity("selection_cursor", GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, {
        x=54, y=54, w=8, h=8, s=1, r=0,
        sprite_sheet="icons", sprite_tag="down", depth=254,
    })
    self.entities["selection_cursor"] = self.selection_cursor

    -- Set animation timers
    self.hovering_card = false
    self.animation_dealing = 0
end


function GameScene:enter()
    for _, entity in pairs(self.entities) do
        entity:clear_sprite()
    end
    self.render_manager:clear_screen()

    -- Update player
    self.player:move(82,103)
    self.player:create_sprite()
    self.player.hand = {}

    self:setup_events()
    self.event_manager:trigger(self.event_manager.events.SHUFFLEDECK)
    self.event_manager:trigger(self.event_manager.events.DEALCARDS)

    self.selection_cursor:create_sprite()

    self:create_sprites()

    self.render_manager:set_shadow_colour(Colours.GREEN5)

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
                self.render_manager:create_draw_object_foreground("player_card_large", "cards_large_" .. self.player.selected_card.suit, self.player.selected_card.value, 88.5, 52.5, math.random(-5, 5), 1, 128)
                self.render_manager.draw_objects_foreground["player_card_large"]:animate({dscale=0.15})
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
            if self.hovering_card then
                self.event_manager:trigger(self.event_manager.events.SELECTCARD)
            end
        end
    )
end


function GameScene:create_sprites()
    self.render_manager:create_draw_object_background("background", "background", "green", 120, 67.5, 0, 1, 255)
    self.render_manager:create_draw_object_foreground("table", "table", "1", 120, 114.5, 0, 1, 128)

    if self.player then        
        self.render_manager:create_draw_object_foreground("hud_player_head", "player", "head", 24, 23, 0, 1, 128)
        self.render_manager:create_text_object("player_name", "PLAYER", Colours.YELLOW1, 38, 20, 0, 1, 64, "left")

        self.render_manager:create_draw_object_foreground("hud_player_health", "icons", "heart", 19.5, 38.5, 0, 1, 128)
        self.render_manager:create_text_object("player_health", tostring(self.player.health) .. "/" .. tostring(self.player.max_health), Colours.RED1, 26, 36, 0, 1, 64, "left")

        self.render_manager:create_draw_object_foreground("hud_player_money", "icons", "money", 19.5, 49.5, 0, 1, 128)
        self.render_manager:create_text_object("player_money", "$" .. tostring(self.player.money), Colours.YELLOW1, 26, 47, 0, 1, 64, "left")
        
        self.render_manager:create_draw_object_foreground("hud_player_deck", "icons", "cards", 19.5, 60.5, 0, 1, 140)
        self.render_manager:create_text_object("player_deck", tostring(#self.player.deck.cards), Colours.BROWN1, 26, 58, 0, 1, 64, "left")
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
    end

    if self.enemy then
        self.render_manager.draw_objects_foreground["enemy"]:animate({dy=4})
        self.render_manager.draw_objects_foreground["hud_enemy_head"]:animate({dy=4})
        self.render_manager.draw_objects_foreground["hud_enemy_health"]:animate({dy=4})
        self.render_manager.draw_objects_foreground["hud_enemy_money"]:animate({dy=4})
        self.render_manager.draw_objects_foreground["hud_enemy_deck"]:animate({dy=4})

        self.render_manager.text_objects["enemy_name"]:animate({dy=4})
        self.render_manager.text_objects["enemy_health"]:animate({dy=4})
        self.render_manager.text_objects["enemy_money"]:animate({dy=4})
        self.render_manager.text_objects["enemy_deck"]:animate({dy=4})
    end 
end


function GameScene:animate_dealing(dt)
    self.animation_dealing = self.animation_dealing + 1

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

            if self.animation_dealing == self.card_frame then

                self.player.hand[i] = self.player.deck:deal_card()
                if #self.player.deck.cards == 0 then
                    self.player.deck:reset()
                    self.player.deck:shuffle()
                end
                
                local card = self.player.hand[i]
                self.entities["player_card_" .. i] = Item(
                    "player_card_" .. i, self.game_state, self.event_manager, self.input_manager, self.render_manager, {
                    x=11.5+(11*i), y=101.5+(3*i), w=15, h=19, s=1, r=0,
                    sprite_sheet="cards_" .. card.suit, sprite_tag=card.value, depth=128+i, item=self.player.hand[i]
                })
                self.entities["player_card_" .. i]:animate({dx=-3-(14.5*(i-1)), dy=-44-(3*(i-1)), dscale=-0.5})
                self.render_manager.draw_objects_foreground["hud_player_deck"]:animate({dscale=0.3})

                self.render_manager:create_text_object("player_deck", tostring(#self.player.deck.cards), Colours.BROWN1, 26, 58, 0, 1, 64, "left")
                self.render_manager.text_objects["player_deck"]:animate({dx=3})
            end
        end
    end
end


function GameScene:animate_card_hovering(dt)
    local hovering = false
    for i = #self.player.hand, 1, -1 do
        if self.entities["player_card_".. i].hovered then
            local card = self.entities["player_card_".. i]
            if self.player.selected_card ~= card.item then
                self.player.selected_card = card.item
                self.selection_cursor:animate({dy=-2})
            end
            hovering = true
            self.selection_cursor:move(self.entities["player_card_".. i].x, self.entities["player_card_".. i].y - 18)
            self.render_manager.draw_objects_foreground["player_card_".. i]:animate({dscale=0.2})
            break
        end
    end
    
    self.hovering_card = hovering
    if not hovering then
        self.player.selected_card = nil
    end
end


function GameScene:update(dt, mx, my, md, mp)
    for _, entity in pairs(self.entities) do
        entity:update(dt, mx, my, md, mp)
    end

    -- Move cursor back to neutral, off-screen position
    self.selection_cursor:move(-50, -50)

    -- Perform animations
    self:animate_dealing()
    self:animate_card_hovering()

    self.render_manager:create_text_object("fps", "FPS: " .. love.timer.getFPS(), Colours.GREY1, 120, 6, 0, 1, 64, "centre")

    -- Move the cursor's draw object to reflect cursor change
    self.selection_cursor:move(self.selection_cursor.x, self.selection_cursor.y)
end


function GameScene:draw()
    love.graphics.setColor(1, 1, 1, 1)
end


function GameScene:exit()
    self.event_manager:remove_owner(self)
end


return GameScene
