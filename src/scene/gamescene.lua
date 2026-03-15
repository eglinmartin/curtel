local Class = require("lib.class")

local GameScene = Class{}

local Deck = require("src.entity.deck")
local Enemy = require("src.entity.enemy")


function GameScene:init(GAME_STATE, RENDER_MANAGER, EVENT_MANAGER)
    self.game_state = GAME_STATE
    self.render_manager = RENDER_MANAGER
    self.event_manager = EVENT_MANAGER

    self.player = self.game_state.player

    -- Set animation timers
    self.animation_dealing = 0
end


function GameScene:enter()
    self:setup_events()
    
    self.enemy = Enemy()
    self.enemy.deck = Deck(self.enemy)
    self.enemy.hand = {}

    self.player.hand = {}

    self.event_manager:trigger(self.event_manager.events.SHUFFLEDECK)

    self:update_sprites()
    self.render_manager:set_shadow_colour(self.render_manager.colours.GREEN5)

    -- Nod screen items
    self.render_manager.draw_objects_background["background"].dscale = 0.1
    self.render_manager.draw_objects_foreground["table"].dy = 4

    -- Nod player items
    if self.player then
        self.render_manager.draw_objects_foreground["player"].dy = 4
        self.render_manager.draw_objects_foreground["hud_player_head"].dy = 4
        self.render_manager.draw_objects_foreground["hud_player_health"].dy = 4
        self.render_manager.draw_objects_foreground["hud_player_money"].dy = 4
        self.render_manager.draw_objects_foreground["hud_player_deck"].dy = 4
        self.render_manager.text_objects["player_name"].dy = 4
        self.render_manager.text_objects["player_health"].dy = 4
        self.render_manager.text_objects["player_money"].dy = 4
        self.render_manager.text_objects["player_deck"].dy = 4

        if #self.player.tokens > 0 then
            self.render_manager.draw_objects_foreground["player_token_icon_1"].dy = 4
            self.render_manager.draw_objects_foreground["player_token_icon_2"].dy = 4
            self.render_manager.draw_objects_foreground["player_token_icon_3"].dy = 4
            self.render_manager.draw_objects_foreground["player_token_icon_4"].dy = 4
            self.render_manager.draw_objects_foreground["player_token_icon_5"].dy = 4
            self.render_manager.draw_objects_foreground["player_token_icon_6"].dy = 4
        end
    end

    if self.enemy then
        self.render_manager.draw_objects_foreground["enemy"].dy = 4
        self.render_manager.draw_objects_foreground["hud_enemy_head"].dy = 4
        self.render_manager.draw_objects_foreground["hud_enemy_health"].dy = 4
        self.render_manager.draw_objects_foreground["hud_enemy_money"].dy = 4
        self.render_manager.draw_objects_foreground["hud_enemy_deck"].dy = 4
        self.render_manager.text_objects["enemy_name"].dy = 4
        self.render_manager.text_objects["enemy_health"].dy = 4
        self.render_manager.text_objects["enemy_money"].dy = 4
        self.render_manager.text_objects["enemy_deck"].dy = 4
    end

end


function GameScene:update(dt)
    -- Run card dealing animation
    self:animate_dealing()
end


function GameScene:animate_dealing(dt)
    self.animation_dealing = self.animation_dealing + 1

    if self.player then
        self.player:update(dt)

        if #self.player.hand > 0 and #self.player.deck.cards > 0 then
            if self.animation_dealing == 1 then
                self.render_manager.draw_objects_foreground["hud_player_deck"].dscale = 0.5
                self.render_manager.text_objects["player_deck"].dx = 3
                self.render_manager.draw_objects_foreground["player_card_1"].dx = -3
                self.render_manager.draw_objects_foreground["player_card_1"].dy = -44
                self.render_manager.draw_objects_foreground["player_card_1"].dscale = -0.3
            end
            
            if self.animation_dealing < 9 then
                self.render_manager.draw_objects_foreground["player_card_2"].dx = -90
            elseif self.animation_dealing == 9 then
                self.render_manager.draw_objects_foreground["hud_player_deck"].dscale = 0.5
                self.render_manager.text_objects["player_deck"].dx = 3
                self.render_manager.draw_objects_foreground["player_card_2"].dx = -14
                self.render_manager.draw_objects_foreground["player_card_2"].dy = -47
                self.render_manager.draw_objects_foreground["player_card_2"].dscale = -0.3
            end

            if self.animation_dealing < 17 then
                self.render_manager.draw_objects_foreground["player_card_3"].dx = -180
            elseif self.animation_dealing == 17 then
                self.render_manager.draw_objects_foreground["hud_player_deck"].dscale = 0.5
                self.render_manager.text_objects["player_deck"].dx = 3
                self.render_manager.draw_objects_foreground["player_card_3"].dx = -25
                self.render_manager.draw_objects_foreground["player_card_3"].dy = -50
                self.render_manager.draw_objects_foreground["player_card_3"].dscale = -0.3
            end
        end
    end

    if self.enemy then
        self.enemy:update(dt)

        if #self.enemy.hand > 0 and #self.enemy.deck.cards > 0 then
            if self.animation_dealing < 1 then
                self.render_manager.draw_objects_foreground["enemy_card_1"].dx = 180
            elseif self.animation_dealing == 1 then
                self.render_manager.draw_objects_foreground["hud_enemy_deck"].dscale = 0.5
                self.render_manager.text_objects["enemy_deck"].dx = -3
                self.render_manager.draw_objects_foreground["enemy_card_1"].dx = 3
                self.render_manager.draw_objects_foreground["enemy_card_1"].dy = -44
                self.render_manager.draw_objects_foreground["enemy_card_1"].dscale = -0.3
            end
            
            if self.animation_dealing < 9 then
                self.render_manager.draw_objects_foreground["enemy_card_2"].dx = 180
            elseif self.animation_dealing == 9 then
                self.render_manager.draw_objects_foreground["hud_enemy_deck"].dscale = 0.5
                self.render_manager.text_objects["enemy_deck"].dx = -3
                self.render_manager.draw_objects_foreground["enemy_card_2"].dx = 14
                self.render_manager.draw_objects_foreground["enemy_card_2"].dy = -47
                self.render_manager.draw_objects_foreground["enemy_card_2"].dscale = -0.3
            end

            if self.animation_dealing < 17 then
                self.render_manager.draw_objects_foreground["enemy_card_3"].dx = 180
            elseif self.animation_dealing == 17 then
                self.render_manager.draw_objects_foreground["hud_enemy_deck"].dscale = 0.5
                self.render_manager.text_objects["enemy_deck"].dx = -3
                self.render_manager.draw_objects_foreground["enemy_card_3"].dx = 25
                self.render_manager.draw_objects_foreground["enemy_card_3"].dy = -50
                self.render_manager.draw_objects_foreground["enemy_card_3"].dscale = -0.3
            end
        end
    end
end


function GameScene:update_sprites()
    self.render_manager:clear_screen()
    self.render_manager:create_draw_object_background("background", "background", "green", 120, 67.5, 0, 1, 255)
    self.render_manager:create_draw_object_foreground("table", "table", "1", 120, 114.5, 0, 1, 128)

    if self.player then
        -- Draw player
        self.render_manager:create_draw_object_foreground("player", "player", "idle", 82, 103, 0, 1, 128)

        -- Draw player's hud (icons)
        self.render_manager:create_draw_object_foreground("hud_player_head", "player", "head", 24, 23, 0, 1, 128)
        self.render_manager:create_draw_object_foreground("hud_player_health", "icons", "heart", 19.5, 38.5, 0, 1, 128)
        self.render_manager:create_draw_object_foreground("hud_player_money", "icons", "money", 19.5, 49.5, 0, 1, 128)
        
        self.render_manager:create_draw_object_foreground("hud_player_deck", "icons", "cards", 19.5, 60.5, 0, 1, 140)

        -- Draw player's hud (text)
        self.render_manager:create_text_object("player_name", "PLAYER 1", self.render_manager.colours.YELLOW1, 38, 20, 0, 1, 64, "left")
        self.render_manager:create_text_object("player_health", tostring(self.player.health) .. "/" .. tostring(self.player.max_health), self.render_manager.colours.RED1, 26, 36, 0, 1, 64, "left")
        self.render_manager:create_text_object("player_money", "$" .. tostring(self.player.money), self.render_manager.colours.YELLOW1, 26, 47, 0, 1, 64, "left")
        self.render_manager:create_text_object("player_deck", tostring(#self.player.deck.cards), self.render_manager.colours.BROWN1, 26, 58, 0, 1, 64, "left")
        
        -- Draw player's hand
        if #self.player.hand > 0 then
            for i, card in ipairs(self.player.hand) do
                self.render_manager:create_draw_object_foreground("player_card_" .. i, "cards_" .. card.suit, card.value, 11.5 + (11 * i), 101.5 + (3 * i), 0, 1, 128+i)
            end
        end

        if #self.player.tokens > 0 then
            self.render_manager:create_draw_object_foreground("player_token_icon_1", "icons", "token_" .. self.player.tokens[1].type, 81.5, 65.5, 0, 1, 129)
            self.render_manager:create_draw_object_foreground("player_token_icon_2", "icons", "token_" .. self.player.tokens[2].type, 88.5, 70.5, 0, 1, 129)
            self.render_manager:create_draw_object_foreground("player_token_icon_3", "icons", "token_" .. self.player.tokens[3].type, 88.5, 77.5, 0, 1, 129)
            self.render_manager:create_draw_object_foreground("player_token_icon_4", "icons", "token_" .. self.player.tokens[4].type, 81.5, 82.5, 0, 1, 129)
            self.render_manager:create_draw_object_foreground("player_token_icon_5", "icons", "token_" .. self.player.tokens[5].type, 74.5, 77.5, 0, 1, 129)
            self.render_manager:create_draw_object_foreground("player_token_icon_6", "icons", "token_" .. self.player.tokens[6].type, 74.5, 70.5, 0, 1, 129)
        end
    end

    if self.enemy then
        -- Draw enemy
        self.render_manager:create_draw_object_foreground("enemy", "enemy1", "idle", 158, 103, 0, 1, 128)
        
        -- Draw enemy's hud (icons)
        self.render_manager:create_draw_object_foreground("hud_enemy_head", "enemy1", "head", 216, 23, 0, 1, 128)
        self.render_manager:create_draw_object_foreground("hud_enemy_health", "icons", "heart", 220.5, 38.5, 0, 1, 128)
        self.render_manager:create_draw_object_foreground("hud_enemy_money", "icons", "money", 220.5, 49.5, 0, 1, 128)
        self.render_manager:create_draw_object_foreground("hud_enemy_deck", "icons", "cards", 220.5, 60.5, 0, 1, 140)
        
        -- Draw enemy's hud (text)
        self.render_manager:create_text_object("enemy_name", "MARTIN", self.render_manager.colours.YELLOW1, 203, 20, 0, 1, 64, "right")
        self.render_manager:create_text_object("enemy_health", tostring(self.player.health) .. "/" .. tostring(self.player.max_health), self.render_manager.colours.RED1, 215, 36, 0, 1, 64, "right")
        self.render_manager:create_text_object("enemy_money", "$" .. tostring(self.enemy.money), self.render_manager.colours.YELLOW1, 215, 47, 0, 1, 64, "right")
        self.render_manager:create_text_object("enemy_deck", tostring(#self.enemy.deck.cards), self.render_manager.colours.BROWN1, 215, 58, 0, 1, 64, "right")
        
        -- Draw enemy's hand
        if #self.player.hand > 0 then
            for i, card in ipairs(self.enemy.hand) do
                self.render_manager:create_draw_object_foreground("enemy_card_" .. i, "cards_" .. card.suit, card.value, 228.5 - (11 * i), 101.5 + (3 * i), 0, 1, 128+i)
            end
        end
    end
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

            if #self.player.deck.cards >= 3 then
                self.player.deck:deal_cards()
            end
            
            if self.enemy then
                if #self.enemy.deck.cards >= 3 then
                    self.enemy.deck:deal_cards()
                end
            end

            self:update_sprites()
        end
    )
end


function GameScene:draw()
    love.graphics.setColor(1, 1, 1, 1)

    if self.player then
        self.player:draw()
    end
end


function GameScene:exit()
    self.event_manager:remove_owner(self)
end


return GameScene
