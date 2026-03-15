local Class = require("lib.class")

local Deck = require("src.entity.deck")
local Player = require("src.entity.player")
local Tokens = require("src.entity.tokens")

local GameState = Class{}


function GameState:init()
    self.tokens = Tokens

    self.player = Player()
    self.player.deck = Deck(self.player)
    self.player.tokens = {Tokens.BULLET_BRONZE, Tokens.BULLET_SILVER, Tokens.BULLET_GOLD, Tokens.BULLET_TITANIUM, Tokens.HEALTH_BEER, Tokens.HEALTH_WHISKY}

end


function GameState:update(dt)
end


function GameState:draw()
end


return GameState
