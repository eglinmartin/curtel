local Class = require("lib.class")
local flux  = require("lib.flux")
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
end


function GameScene:enter()
    -- Clear out sprites from all entities, and clear screen
    for _, entity in pairs(self.entities) do
        entity:clear_sprite()
    end
    self.render_manager:clear_screen()

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
    
    self:draw_hud(self.player)
    self:draw_hud(self.enemy)

    self:draw_bullets(self.player)
    self:draw_bullets(self.enemy)

    -- Set up event handling
    -- self:setup_events()

    self.render_manager:set_shadow_colour(Colours.GREEN5)
    self.render_manager:create_draw_object_background("background", "background", "green", 120, 67.5, 0, 1, 255)
    self.render_manager:create_draw_object_foreground("table", "table", "1", 120, 114.5, 0, 1, 128)

    self:start_new_game()
end


function GameScene:draw_hud(character)
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

    -- Draw card markers
    for i = 1, character.hand_size do
        local x = (11.5 + ( 10 * i))
        local y = 101.5 + (3 * i)

        local cards_xy = {0 + x, 0 + y}
        local name = "player"
        if character == self.enemy then
            cards_xy = {240 - x, 0 + y}
            name = "enemy"
        end
        
        self.render_manager:create_draw_object_foreground(
            name .. "_card_empty_" .. i, "cards_general", "empty", cards_xy[1], cards_xy[2], 0, 1, 128
        )
    end

    self.render_manager:create_draw_object_foreground("hud_" .. name .. "_head", sprite, "head", x_coords[1], 23, 0, 1, 128)
    self.render_manager:create_text_object(name .. "_name", "PLAYER", Colours.YELLOW1, x_coords[2], 20, 0, 1, 64, text_dir)

    self.render_manager:create_draw_object_foreground("hud_" .. name .. "_health", "icons", "heart", x_coords[3], 38.5, 0, 1, 128)
    self.render_manager:create_text_object(name .. "_health", tostring(character.health), Colours.RED1, x_coords[4], 36, 0, 1, 64, text_dir)

    self.render_manager:create_draw_object_foreground("hud_" .. name .. "_money", "icons", "money", x_coords[3], 49.5, 0, 1, 128)
    self.render_manager:create_text_object(name .. "_money", "$" .. tostring(character.money), Colours.YELLOW1, x_coords[4], 47, 0, 1, 64, text_dir)

    self.render_manager:create_draw_object_foreground("hud_" .. name .. "_deck", "icons", "cards", x_coords[3] , 60.5, 0, 1, 140)
    self.render_manager:create_text_object(name .. "_deck", tostring(#character.deck.cards), Colours.BROWN1, x_coords[4], 58, 0, 1, 64, text_dir)
end


function GameScene:draw_bullets(character)
    local name = "player"
    if character == self.enemy then
        name = "enemy"
    end

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
    end
end


function GameScene:start_new_game()
    self.letruc:start_new_game(self.player, self.enemy)

    local animation_steps = {
        {delay=0, action= function () self.render_manager:create_text_object("status", "- CURTEL -", Colours.YELLOW1, 120, 45, 0, 1, 255, "centre") end},
        {delay=0, action= function () flux.to(self.render_manager.text_objects["status"], 1, {y=40}):ease("elasticout") end},
        {delay=2, action= function () self:start_new_hand() end}

    }
    self:start_animation("new_game", animation_steps)
end


function GameScene:start_new_hand()
    self.letruc:start_new_hand()

    local animation_steps = {
        {delay=0, action= function () self.render_manager:create_text_object("status", "- HAND " .. self.letruc.num_hands .. " -", Colours.YELLOW1, 120, 45, 0, 1, 255, "centre") end},
        {delay=0, action= function () flux.to(self.render_manager.text_objects["status"], 1, {y=40}):ease("elasticout") end},
        {delay=0.5, action= function() self:deal_hand(self.player) end},
        {delay=0, action= function() self:deal_hand(self.enemy) end},
        {delay=1, action= function() self:start_new_trick() end}
    }
    self:start_animation("new_hand", animation_steps)
end


function GameScene:start_new_trick()
    self.letruc:start_new_trick()
    local animation_steps = {
        {delay=0, action= function () self.render_manager:create_text_object("status", "PLAY!", Colours.GREEN1, 120, 45, 0, 1, 255, "centre") end},
        {delay=0, action= function () flux.to(self.render_manager.text_objects["status"], 1, {y=40}):ease("elasticout") end},
        {delay=2, action= function () flux.to(self.render_manager.text_objects["status"], 0.1, {y=45}):ease("backin"):oncomplete(function() self.render_manager.text_objects["status"] = nil end) end},
        {delay=1, action= function () self:play_card(self.enemy) end}
    }
    self:start_animation("new_trick", animation_steps)
end


function GameScene:deal_hand(character)
    self.letruc:deal_hand(character)

    local animation_steps = {}
    local name = character == self.enemy and "enemy" or "player"

    for i = 1, character.hand_size do
        local x = 11.5 + (10 * i)
        local y = 101.5 + (3 * i)
        local cards_xy = character == self.enemy and {240 - x, y} or {x, y}
        
        table.insert(animation_steps, {
            delay = 0.1,
            action = function()
                self:deal_card(character, character.hand[i], i, name, cards_xy)
            end
        })
    end

    self:start_animation("deal_" .. name, animation_steps)
end


function GameScene:deal_card(character, player_card, i, name, cards_xy)
    local deck_x = 19.5
    local text_x = 26
    local text_dir = -1
    local card_interact = true
    if character == self.enemy then
        deck_x = 220.5
        text_x = 215
        text_dir = 1
        card_interact = false
    end

    -- Create card entity at coordinate
    if player_card ~= EMPTY then
        self.entities[name .. "_card_" .. i] = Item(
            name .. "_card_" .. i, self.game_state, self.event_manager, self.input_manager, self.render_manager, {
            x=deck_x, y=60.5, w=15, h=19, s=0.8, r=0,
            sprite_sheet="cards_" .. player_card.suit, sprite_tag=player_card.value, depth=128+i, item=self.player.hand[i],
            draggable=card_interact, hoverable=card_interact
        })
        flux.to(self.entities[name .. "_card_" .. i], 0.5, {x=cards_xy[1], y=cards_xy[2], scale=1}):ease("expoout")
        
        self.render_manager.text_objects[name .. "_deck"].x = text_x - (4 * text_dir)
        flux.to(self.render_manager.text_objects[name .. "_deck"], 0.5, {x=text_x}):ease("expoout")

        self.render_manager.draw_objects_foreground["hud_" .. name .. "_deck"].scale = 2
        flux.to(self.render_manager.draw_objects_foreground["hud_" .. name .. "_deck"], 0.5, {scale=1}):ease("expoout")
    end
end


function GameScene:play_card(character)
    local card_params = {x=112.5, y=40.5, rot=-5, depth=226}

    if character == self.enemy then
        card_params = {x=127.5, y=50.5, rot=5, depth=225}
        if self.render_manager.draw_objects_foreground['player_card_large'] then
            card_params.depth = 227
        end

        local available_cards = {}
        for i = 1, self.enemy.hand_size do
            if self.enemy.hand[i] ~= EMPTY then
                table.insert(available_cards, {card=self.enemy.hand[i], id=i})
            end
        end

        local card = available_cards[math.random(#available_cards)]
        self.enemy.picked_card = card['card']
        self.letruc:select_card(self.enemy, card['card'])

        self.enemy.hand[card['id']] = EMPTY
        self.render_manager.draw_objects_foreground["enemy_card_" .. card['id']] = nil

        -- local card_y = self.render_manager.draw_objects_foreground["enemy_card_" .. card['id']].y
        -- flux.to(self.render_manager.draw_objects_foreground["enemy_card_" .. card['id']], 0.1, {y=card_y-10}):ease("backin"):oncomplete(
        --     function() self.render_manager.draw_objects_foreground["enemy_card_" .. card['id']] = nil end
        -- )
    end

    self.render_manager:create_draw_object_foreground(
        character.id .. "_card_large", "cards_large_" .. character.picked_card.suit,
        character.picked_card.value, card_params.x, card_params.y, card_params.rot, 1.2, card_params.depth
    )
    flux.to(self.render_manager.draw_objects_foreground[character.id .. "_card_large"], 0.5, {scale=1}):ease("expoout")
    self.letruc:select_card(character, character.picked_card)
    character.selected_card = character.picked_card
    character.picked_card = nil
end


function GameScene:create_enemy()
    self.enemy = Enemy("enemy", self.game_state, self.event_manager, self.input_manager, self.render_manager, {
        x=166, y=103, w=20, h=32, s=1, r=0, sprite_sheet="enemy1", sprite_tag="idle", depth=128,
    })
    self.enemy.money = 10

    self.enemy.deck = Deck()
    self.enemy.hand = {EMPTY, EMPTY, EMPTY}

    self.entities['enemy'] = self.enemy
end


function GameScene:update(dt, mx, my, md, mp)
    for _, entity in pairs(self.entities) do
        entity:update(dt, mx, my, md, mp)
    end

    flux.update(dt)
    self:update_animations(dt)

    -- Move cursor back to neutral, off-screen position
    self.pointer:move(-50, -50)

    -- Animate interaction effects
    self:animate_dragging()
    self:animate_hovering()
end


function GameScene:start_animation(name, steps)
    self.animations = self.animations or {}
    self.animations[name] = {
        steps        = steps,
        current_step = 1,
        current_time = 0,
    }
end


function GameScene:update_animations(dt)
    if not self.animations then
        return
    end

    for name, animation in pairs(self.animations) do
        local step = animation.steps[animation.current_step]
        animation.current_time = animation.current_time + dt

        if animation.current_time >= step.delay then
            step.action()
            animation.current_time = 0
            animation.current_step = animation.current_step + 1

            if animation.current_step > #animation.steps then
                self.animations[name] = nil
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
                if not was_hovering or prev_hovered_entity ~= entity then

                    if entity.id:find("player_card_") and self.letruc.game_state ~= self.letruc.states['PLAYTRICK'] then
                        break
                    end

                    entity:on_hover_start()
                end
            end

            break
        end
    end

    if not self.hovering and was_hovering and prev_hovered_entity then
        prev_hovered_entity:on_hover_end()
    elseif self.hovering and was_hovering and prev_hovered_entity ~= self.hovered_entity then
        prev_hovered_entity:on_hover_end()
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
            
            if entity.id:find("player_card_") and self.letruc.game_state == self.letruc.states['PLAYTRICK'] then
                entity:drag()
                self.player.picked_card = entity.item
            end
        end

        if entity.released and entity.id:find("player_card_") then
            if math.abs(self.input_manager.mx - 120) <= 20 then
                
                -- Select card
                if self.player.picked_card then
                    self:play_card(self.player)
                end

                entity:clear_sprite()
                self.entities[entity.id] = nil
                self.player.hand[tonumber(entity.id:match("%d+"))] = EMPTY
            end
        end
    end
end


function GameScene:draw()
    love.graphics.setColor(1, 1, 1, 1)
end


function GameScene:exit()
    self.event_manager:remove_owner(self)
end


return GameScene
