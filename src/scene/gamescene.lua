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

    self.player = self.game_state.player
    self.entities["player"] = self.player

    self.selection_cursor = Entity(10, 10)
    self.entities["selection_cursor"] = self.selection_cursor

    -- Set animation timers
    self.hovering_card = false
    self.animation_dealing = 0
end


function GameScene:enter()
    self.render_manager:clear_screen()
    
    self.render_manager:create_draw_object_foreground("selection_cursor", "icons", "down", self.selection_cursor.x, self.selection_cursor.y, 0, 1, 128)
    
    self:setup_events()
    self.event_manager:trigger(self.event_manager.events.SHUFFLEDECK)

    self:create_sprites()
    
    self.player.x = 82
    self.player.y = 103
    self.player.hand = {}

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
        self.render_manager:create_draw_object_foreground("player", "player", "idle", 82, 103, 0, 1, 128)
        
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

            if self.animation_dealing == 1 then
                self.player.hand = {}
                self.entities["player_card_" .. i] = nil
                self.render_manager.draw_objects_foreground["player_card_" .. i] = nil
            end

            if self.animation_dealing == self.card_frame then

                self.player.hand[i] = self.player.deck:deal_card()
                if #self.player.deck.cards == 0 then
                    self.player.deck:reset()
                    self.player.deck:shuffle()
                end
                
                self.entities["player_card_" .. i] = Item(self.player.hand[i], 11.5 + (11 * i), 101.5 + (3 * i))
                self.render_manager:create_draw_object_foreground("player_card_" .. i, "cards_" .. self.player.hand[i].suit, self.player.hand[i].value, self.entities["player_card_" .. i].x, self.entities["player_card_" .. i].y, 0, 1, 128+i)
                self.render_manager:create_text_object("player_deck", tostring(#self.player.deck.cards), Colours.BROWN1, 26, 58, 0, 1, 64, "left")

                self.render_manager.text_objects["player_deck"]:animate({dx=3})
                self.render_manager.draw_objects_foreground["hud_player_deck"]:animate({dscale=0.5})
                self.render_manager.draw_objects_foreground["player_card_" .. i]:animate({dx=-3-(11*(i-1)), dy=-44-(3*(i-1)), dscale=-0.3})
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
                self.render_manager.draw_objects_foreground["selection_cursor"]:animate({dy=-2})
                self.player.selected_card = card.item
            end
            hovering = true
            self.render_manager.draw_objects_foreground["player_card_".. i]:animate({dscale=0.2})
            self.selection_cursor:move(self.entities["player_card_".. i].x, self.entities["player_card_".. i].y-18)
            break
        end
    end
    self.hovering_card = hovering
end


function GameScene:update(dt, mx, my, md, mp)
    for _, entity in pairs(self.entities) do
        entity:update(dt, mx, my, md, mp)
    end

    -- Move cursor back to neutral, off-screen position
    self.selection_cursor:move(-10, -10)

    -- Perform animations
    self:animate_dealing()
    self:animate_card_hovering()

    -- Move the cursor's draw object to reflect cursor change
    self.render_manager.draw_objects_foreground["selection_cursor"]:move(self.selection_cursor.x, self.selection_cursor.y)
end


function GameScene:draw()
    love.graphics.setColor(1, 1, 1, 1)
end


function GameScene:exit()
    self.event_manager:remove_owner(self)
end


return GameScene
