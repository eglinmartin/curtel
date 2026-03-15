local Class = require("lib.class")
local Tokens = require("src.entity.tokens")

local Card = Class{}
local Shop = Class{}


function Shop:init()
    self.stock = {}
    self.stock["tokens"] = {Tokens.BULLET_SILVER, Tokens.BULLET_TITANIUM, Tokens.BULLET_URANIUM, Tokens.HEALTH_BEER, Tokens.HEALTH_WHISKY, Tokens.BULLET_BRONZE}
end


return Shop
