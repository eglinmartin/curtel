local Class = require("lib.class")

local Bullets = require("src.entity.bullets")
local Deck = require("src.entity.deck")
local Entity = require("src.entity.entity")
local Player = require("src.entity.player")

local GameState = Class{}


function GameState:init(GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER)
    self.input_manager = INPUT_MANAGER
    EVENT_MANAGER:trigger(EVENT_MANAGER.events.TOGGLE_FULLSCREEN)

    -- Create persistent player entity
    self.player = Player("player", GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, {
        x=0, y=0, w=20, h=32, s=1, r=0, sprite_sheet="player", sprite_tag="idle", depth=128, draggable=false
    })
    self.player.deck = Deck(self.player)
    self.player.bullets = {Bullets.BULLET_BRONZE, nil, Bullets.BULLET_GOLD, Bullets.BULLET_TITANIUM, Bullets.HEALTH_BEER, Bullets.HEALTH_WHISKY}

    -- Create persistent cursor entity
    self.cursor = Entity("cursor", GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, {
        x=0, y=0, w=24, h=24, s=1, r=0, sprite_sheet="cursors", sprite_tag="pointer", depth=255,
    })
end


function GameState:update(dt)
    -- Move cursor
    self.cursor:move(self.input_manager.mx, self.input_manager.my)
end


function GameState:draw()
end


return GameState
