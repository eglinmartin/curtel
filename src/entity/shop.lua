local Class = require("lib.class")
local Tokens = require("src.entity.tokens")
local Cards = require("src.entity.cards")

local Deck = require("src.entity.deck")
local Shop = Class{}
local ShopItem = Class{}


local StockTypes = {
    BULLETS = 'bullets',
    CARDS = 'cards'
}


function ShopItem:init(item)
    self.item = item
end


function Shop:init()
    self.stock = {}
    self.stock_types = StockTypes
    self:reroll_bullets()
    self:reroll_cards()

end


function Shop:reroll_bullets()
    local token_keys = {}
    for k, _ in pairs(Tokens) do
        table.insert(token_keys, k)
    end

    self.stock[StockTypes.BULLETS] = {}
    for i = 1, 6 do
        local random_key = token_keys[math.random(#token_keys)]
        table.insert(self.stock[StockTypes.BULLETS], ShopItem(Tokens[random_key]))
    end
end


function Shop:reroll_cards()
    -- Create table of cards
    local card_keys = {}
    for k, _ in pairs(Cards) do
        table.insert(card_keys, k)
    end

    -- Shuffle a copy of the keys and take the first 6
    for i = #card_keys, 2, -1 do
        local j = math.random(i)
        card_keys[i], card_keys[j] = card_keys[j], card_keys[i]
    end
    self.stock[StockTypes.CARDS] = {}
    for i = 1, 6 do
        table.insert(self.stock[StockTypes.CARDS], ShopItem(Cards[card_keys[i]]))
    end
end



return Shop
