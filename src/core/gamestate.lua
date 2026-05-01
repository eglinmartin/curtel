local Class = require("lib.class")

local Deck = require("src.entity.deck")
local Player = require("src.entity.player")
local Bullets = require("src.entity.bullets")

local GameState = Class{}


function GameState:init(GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER)
    self.bullets = Bullets

    self.player = Player(0, 0, RENDER_MANAGER)
    self.player.deck = Deck(self.player)
    self.player.bullets = {Bullets.BULLET_BRONZE, Bullets.BULLET_SILVER, Bullets.BULLET_GOLD, Bullets.BULLET_TITANIUM, Bullets.HEALTH_BEER, Bullets.HEALTH_WHISKY}

end


function GameState:update(dt)
end


function GameState:draw()
end


return GameState
