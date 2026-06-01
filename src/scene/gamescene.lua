local Class = require("lib.class")
local GameScene = Class{}

local Colours = require("src.render.colours")
local Deck = require("src.entity.deck")
local Enemy = require("src.entity.enemy")
local Entity = require("src.entity.entity")
local Item = require("src.entity.item")
local LeTruc = require("src.core.letruc")

local EMPTY = "empty"


function GameScene:init(GAME_STATE, RENDER_MANAGER, EVENT_MANAGER, INPUT_MANAGER)
    self.game_state = GAME_STATE
    self.render_manager = RENDER_MANAGER
    self.event_manager = EVENT_MANAGER
    self.input_manager = INPUT_MANAGER
    self.entities = {}

    -- Create player
    self.player = self.game_state.player
    self.entities["player"] = self.player

    -- Initialize letruc game
    self.letruc = LeTruc(self.event_manager)

    -- Create pointer
    self.pointer = Entity("pointer", GAME_STATE, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, {
        x=54, y=54, w=8, h=8, s=1, r=0,
        sprite_sheet="icons", sprite_tag="down", depth=254,
    })
    self.entities["pointer"] = self.pointer

    -- Set interaction states
    self.hovering = false

    -- Set animation timers
    self:reset_animations()
end


function GameScene:enter()
    -- Clear out sprites from all entities, and clear screen
    for _, entity in pairs(self.entities) do
        entity:clear_sprite()
    end
    self.render_manager:clear_screen()

    -- Reset animation timers
    self:reset_animations()

    -- Update player
    self.player:move(74,103)
    self.player:create_sprite()
    self.player.hand = {EMPTY, EMPTY, EMPTY}

    -- Create placeholder nil enemy object
    self.enemy = nil
    self:create_enemy()

    -- Start new game of letruc
    self.letruc.player1 = self.player
    self.letruc.player2 = self.enemy
    self.letruc:change_state(self.letruc.states.NEWGAME)

    -- Set up event handling
    self:setup_events()

    self.pointer:create_sprite()

    self.render_manager:set_shadow_colour(Colours.GREEN5)
    self.render_manager:create_draw_object_background("background", "background", "green", 120, 67.5, 0, 1, 255
)   self.render_manager:create_draw_object_foreground("table", "table", "1", 120, 114.5, 0, 1, 128)

    self.player_cards_xy = {}
    self.enemy_cards_xy = {}

    self:create_hud(self.player)
    self:create_hud(self.enemy)

    self:animate_enter()

end


function GameScene:reset_animations()
    -- Auto-generate a timer for each letruc game state
    for key, _ in pairs(self.letruc.states) do
        self["animation_" .. key:lower()] = 999999
    end
    self.enemy_card_timer = 999999
    self.both_cards_timer = 999999
end


function GameScene:setup_events()
    -- Deal cards to the player on deal cards command
    self.event_manager:on(
        self.event_manager.events.NEWGAME, self, function()
            self.letruc:change_state(self.letruc.states['NEWGAME'])
        end
    )

    self.event_manager:on(
        self.event_manager.events.NEWHAND, self, function()
            self.letruc:change_state(self.letruc.states['NEWHAND'])
            self.animation_newhand = 0
            self.animation_dealcards = 999999
            self.enemy_card_timer = 999999
        end
    )

    self.event_manager:on(
        self.event_manager.events.NEWTRICK, self, function()
            self.letruc:change_state(self.letruc.states['NEWTRICK'])
        end
    )

    self.event_manager:on(
        self.event_manager.events.DEALCARDS, self, function()
            self.animation_dealcards = 0
            self.enemy_card_timer = 999999
        end
    )

    -- self.event_manager:on(
    --     self.event_manager.events.PLAYTRICK, self, function()
    --     end
    -- )
end


function GameScene:create_enemy()
    self.enemy = Enemy("enemy", self.game_state, self.event_manager, self.input_manager, self.render_manager, {
        x=166, y=103, w=20, h=32, s=1, r=0, sprite_sheet="enemy1", sprite_tag="idle", depth=128,
    })
    self.enemy.money = 10
    self.enemy:create_sprite()
    self.enemy:animate({dy=4})
    self.enemy.deck = Deck()
    self.enemy.hand = {EMPTY, EMPTY, EMPTY}
    self.entities['enemy'] = self.enemy
    self.letruc.enemy = self.enemy
end


function GameScene:create_hud(character)
    local x_coords = {24, 38, 19.5, 26}
    local text_dir = "left"
    local name = "player"
    local sprite = "player"
    
    if character == self.enemy then
        x_coords = {216, 202, 220.5, 215}
        text_dir = "right"
        name = "enemy"
        sprite = "enemy1"
    end

    self.render_manager:create_draw_object_foreground("hud_" .. name .. "_head", sprite, "head", x_coords[1], 23, 0, 1, 128)
    self.render_manager.draw_objects_foreground["hud_" .. name .. "_head"]:animate({dy=4})

    self.render_manager:create_text_object(name .. "_name", "PLAYER", Colours.YELLOW1, x_coords[2], 20, 0, 1, 64, text_dir)
    self.render_manager.text_objects[name .. "_name"]:animate({dy=4})

    self.render_manager:create_draw_object_foreground("hud_" .. name .. "_health", "icons", "heart", x_coords[3], 38.5, 0, 1, 128)
    self.render_manager.draw_objects_foreground["hud_" .. name .. "_health"]:animate({dy=4})

    self.render_manager:create_text_object(name .. "_health", tostring(character.health), Colours.RED1, x_coords[4], 36, 0, 1, 64, text_dir)
    self.render_manager.text_objects[name .. "_health"]:animate({dy=4})

    self.render_manager:create_draw_object_foreground("hud_" .. name .. "_money", "icons", "money", x_coords[3], 49.5, 0, 1, 128)
    self.render_manager.draw_objects_foreground["hud_" .. name .. "_money"]:animate({dy=4})

    self.render_manager:create_text_object(name .. "_money", "$" .. tostring(character.money), Colours.YELLOW1, x_coords[4], 47, 0, 1, 64, text_dir)
    self.render_manager.text_objects[name .. "_money"]:animate({dy=4})
    
    self.render_manager:create_draw_object_foreground("hud_" .. name .. "_deck", "icons", "cards", x_coords[3] , 60.5, 0, 1, 140)
    self.render_manager.draw_objects_foreground["hud_" .. name .. "_deck"]:animate({dy=4})

    self.render_manager:create_text_object(name .. "_deck", tostring(#character.deck.cards), Colours.BROWN1, x_coords[4], 58, 0, 1, 64, text_dir)
    self.render_manager.text_objects[name .. "_deck"]:animate({dy=4})

    local bullet_icons_xy = {
        {character.x, character.y - 39},
        {character.x + 7, character.y - 34},
        {character.x + 7, character.y - 27},
        {character.x, character.y - 22},
        {character.x - 7, character.y - 27},
        {character.x - 7, character.y - 34}
        
    }
    for i, bullet in pairs(character.bullets) do
        self.entities[name .. "_bullet_icon_" .. i] = Entity(
            name .. "_bullet_icon" .. i, GAME_STATE, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, {
                x=bullet_icons_xy[i][1], y=bullet_icons_xy[i][2], w=8, h=8, s=1, r=0,
                sprite_sheet="icons", sprite_tag="bullet_" .. bullet.type, depth=200
            }
        )
        self.entities[name .. "_bullet_icon_" .. i]:create_sprite()
        self.entities[name .. "_bullet_icon_" .. i]:animate({dy=4})
    end

    for i = 1, self.player.hand_size do
        local x = 11.5+(10*i)
        local y = 101.5+(3*i)
        self.player_cards_xy[i] = {x, y}

        if character == self.enemy then
            x = 228.5-(10*i)
            self.enemy_cards_xy[i] = {x, y}
        end

        self.render_manager:create_draw_object_foreground(
            name .. "_card_empty_" .. i, "cards_general", "empty", x, y, 0, 1, 128
        )
        self.render_manager.draw_objects_foreground[name .. "_card_empty_" .. i]:animate({dy=4})
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


function GameScene:animate_new_hand()
    self.animation_newhand = self.animation_newhand + 1

    if self.animation_newhand == 1 then
        self:reset_hand(self.player)
        if self.enemy then
            self:reset_hand(self.enemy)
        end

        if self.render_manager.draw_objects_foreground['player_card_large'] then
            self.render_manager.draw_objects_foreground['player_card_large'] = nil
        end
        if self.render_manager.draw_objects_foreground['enemy_card_large'] then
            self.render_manager.draw_objects_foreground['enemy_card_large'] = nil
        end


        self.render_manager:create_text_object("status", "HAND " .. tostring(self.letruc.num_hands), Colours.YELLOW1, 120, 42, 0, 1, 255, "centre")
        self.render_manager.text_objects["status"]:animate({dy=3})
    end

    if self.animation_newhand == 30 then
        self.animation_dealcards = 0
    end

    if self.animation_newhand == 60 then
        self.letruc:change_state(self.letruc.states['NEWTRICK'])
        self.render_manager:create_text_object("status", "PLAY!", Colours.YELLOW1, 120, 42, 0, 1, 255, "centre")
        self.render_manager.text_objects["status"]:animate({dy=3})
        self.animation_newtrick = 0
    end

    if self.animation_newhand == 120 then
        self.render_manager.text_objects["status"] = nil
    end
end


function GameScene:animate_new_trick()
    self.animation_newtrick = self.animation_newtrick + 1

    if self.animation_newtrick == 1 then
        self.enemy_card_timer = math.random(30, 120)
        self.player.selected_card = nil
        self.enemy.selected_card = nil
    end

    -- Play enemy card
    if self.animation_newtrick == self.enemy_card_timer then

        -- Create list of available enemy cards to play
        local available_cards = {}
        for i = 1, self.enemy.hand_size do
            if self.enemy.hand[i] ~= EMPTY then
                table.insert(available_cards, {card=self.enemy.hand[i], id=i})
            end
        end

        local chosen_card = available_cards[math.random(#available_cards)]
        self.enemy.selected_card = chosen_card['card']
        self.letruc:select_card(self.enemy, chosen_card['card'])
        self.enemy.hand[chosen_card['id']] = EMPTY

        local card_depth = 225
        if self.render_manager.draw_objects_foreground["player_card_large"] then
            card_depth = 227
        end

        self.render_manager:create_draw_object_foreground(
            "enemy_card_large", "cards_large_" .. self.enemy.selected_card.suit,
            self.enemy.selected_card.value, 127.5, 50.5, 5, 1, card_depth
        )

        local hand_card = self.render_manager.draw_objects_foreground["enemy_card_" .. chosen_card['id']]
        local large_card = self.render_manager.draw_objects_foreground["enemy_card_large"]

        local dx = hand_card.x - large_card.x
        local dy = hand_card.y - large_card.y
        local drot = -5

        self.render_manager.draw_objects_foreground["enemy_card_large"]:animate({dx=dx, dy=dy, drot=drot, dscale=-0.5})
        self.render_manager.draw_objects_foreground["enemy_card_" .. chosen_card['id']] = nil
    end
    
    if self.enemy.selected_card and self.player.selected_card and self.letruc.game_state == self.letruc.states.PLAYTRICK then
        self.letruc:change_state(self.letruc.states.COMPARECARDS)
        self.animation_comparecards = 0
    end
end


function GameScene:animate_card_compare()
    self.animation_comparecards = self.animation_comparecards + 1

    if self.animation_comparecards == 121 then
        local player_card = self.render_manager.draw_objects_foreground['player_card_large']
        local player_card_current_pos = {x=player_card.x, y=player_card.y, rot=player_card.rot}
        player_card:move(79, 56)
        player_card:rotate(0, 0)
        player_card:animate({
            dx=player_card_current_pos.x - player_card.x,
            dy=player_card_current_pos.y - player_card.y,
            drot=-5
        })

        local enemy_card = self.render_manager.draw_objects_foreground['enemy_card_large']
        local enemy_card_current_pos = {x=enemy_card.x, y=enemy_card.y, rot=enemy_card.rot}
        enemy_card:move(160, 56)
        enemy_card:rotate(0, 0)
        enemy_card:animate({
            dx=enemy_card_current_pos.x - enemy_card.x,
            dy=enemy_card_current_pos.y - enemy_card.y,
            drot=5
        })

    end
end


function GameScene:reset_hand(character)
    if character == self.player then
        for i = 1, self.player.hand_size do
            if self.entities["player_card_" .. i] then
                self.entities["player_card_" .. i]:clear_sprite()
                self.entities["player_card_" .. i] = nil
            end
        end

    elseif character == self.enemy then
        for i = 1, self.enemy.hand_size do
            if self.enemy then
                if self.entities["enemy_card_" .. i] then
                    self.entities["enemy_card_" .. i]:clear_sprite()
                    self.entities["enemy_card_" .. i] = nil
                end
            end
        end
    end
end


function GameScene:animate_dealing(dt)
    -- Tick animation timer
    self.animation_dealcards = self.animation_dealcards + 1

    -- If first frame:
    if self.animation_dealcards == 1 then
        -- Clear player's entities
        for i = 1, self.player.hand_size do
            if self.entities["player_card_" .. i] then
                self.entities["player_card_" .. i]:clear_sprite()
                self.entities["player_card_" .. i] = nil
            end
        end

        -- Clear enemy's entities
        if self.enemy then
            for i = 1, self.enemy.hand_size do
                if self.entities["enemy_card_" .. i] then
                    self.entities["enemy_card_" .. i]:clear_sprite()
                    self.entities["enemy_card_" .. i] = nil
                end
            end
        end
    end

    for i = 1, self.player.hand_size do
        self.card_frame = 1 + (8 * (i-1))
        if self.animation_dealcards == self.card_frame then   

            -- Create player card entity on screen and animate
            local player_card = self.player.hand[i]
            if player_card ~= EMPTY then
                self.entities["player_card_" .. i] = Item(
                    "player_card_" .. i, self.game_state, self.event_manager, self.input_manager, self.render_manager, {
                    x=self.player_cards_xy[i][1], y=self.player_cards_xy[i][2], w=15, h=19, s=1, r=0,
                    sprite_sheet="cards_" .. player_card.suit, sprite_tag=player_card.value, depth=128+i, item=self.player.hand[i],
                    draggable=true, hoverable=true
                })
                self.entities["player_card_" .. i]:animate({dx=-3-(14.5*(i-1)), dy=-44-(3*(i-1)), dscale=-0.5})
            end

            -- Create enemy card entity on screen and animate
            if self.enemy then
                local enemy_card = self.enemy.hand[i]
                if enemy_card ~= EMPTY then
                    self.entities["enemy_card_" .. i] = Item(
                        "enemy_card_" .. i, self.game_state, self.event_manager, self.input_manager, self.render_manager, {
                        x=self.enemy_cards_xy[i][1], y=self.enemy_cards_xy[i][2], w=15, h=19, s=1, r=0,
                        sprite_sheet="cards_" .. enemy_card.suit, sprite_tag=enemy_card.value, depth=128+i, item=self.enemy.hand[i]
                    })
                    self.entities["enemy_card_" .. i]:animate({dx=3+(14.5*(i-1)), dy=-44-(3*(i-1)), dscale=-0.5})
                end
            end

            -- Animate deck icons and numbers
            self.render_manager.draw_objects_foreground["hud_player_deck"]:animate({dscale=0.3})
            self.render_manager:create_text_object("player_deck", tostring(#self.player.deck.cards), Colours.BROWN1, 26, 58, 0, 1, 64, "left")
            self.render_manager.text_objects["player_deck"]:animate({dx=3})
            if self.enemy then
                self.render_manager.draw_objects_foreground["hud_enemy_deck"]:animate({dscale=0.3})
                self.render_manager:create_text_object("enemy_deck", tostring(#self.enemy.deck.cards), Colours.BROWN1, 207, 58, 0, 1, 64, "left")
                self.render_manager.text_objects["enemy_deck"]:animate({dx=-3})
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
                if self.letruc.game_state == self.letruc.states['PLAYTRICK'] then
                    if self.render_manager.draw_objects_foreground[entity.id] then
                        self.render_manager.draw_objects_foreground[entity.id]:animate({dscale=0.2})
                    end
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
            if self.letruc.game_state == self.letruc.states['PLAYTRICK'] then
                entity:drag()
                self.player.picked_card = entity.item
            end
        end

        if entity.released and entity.id:find("player_card_") then
            if math.abs(self.input_manager.mx - 120) <= 16 and math.abs(self.input_manager.my - 52.5) <= 32 then
                
                -- Select card
                if self.player.picked_card then
                    self.render_manager:create_draw_object_foreground(
                        "player_card_large", "cards_large_" .. self.player.picked_card.suit,
                        self.player.picked_card.value, 112.5, 40.5, -5, 1, 226
                    )
                    self.letruc:select_card(self.player, self.player.picked_card)
                    self.player.selected_card = self.player.picked_card
                    self.render_manager.draw_objects_foreground["player_card_large"]:animate({dscale=0.3})
                    self.player.picked_card = nil
                end

                entity:clear_sprite()
                self.entities[entity.id] = nil
                self.player.hand[tonumber(entity.id:match("%d+"))] = EMPTY
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

    self:animate_dragging()
    self:animate_hovering()
    
    -- Perform animations
    self:animate_new_hand()
    self:animate_new_trick()
    self:animate_dealing()
    self:animate_card_compare()
end


function GameScene:draw()
    love.graphics.setColor(1, 1, 1, 1)
end


function GameScene:exit()
    self.event_manager:remove_owner(self)
end


return GameScene
