local Class = require("lib.class")
local Tokens = require("src.entity.tokens")

local Deck = require("src.entity.deck")
local Shop = Class{}


function Shop:init()
    self.stock = {}
    self.stock["tokens"] = {Tokens.BULLET_SILVER, Tokens.BULLET_TITANIUM, Tokens.BULLET_URANIUM, Tokens.HEALTH_BEER, Tokens.HEALTH_WHISKY, Tokens.BULLET_BRONZE}

    self.deck = Deck()
    self.stock["cards"] = {self.deck.card_library.CARD_A_DIAMONDS, self.deck.card_library.CARD_A_SPADES, self.deck.card_library.CARD_A_HEARTS}
end


return Shop
