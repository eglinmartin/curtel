local Class = require("lib.class")
local Bullets = require("src.entity.bullets")
local Cards = require("src.entity.cards")
local Colours = require("src.render.colours")

local Deck = require("src.entity.deck")
local Shop = Class{}
local ShopItem = Class{}


local StockTypes = {
    BULLETS = 'bullets',
    CARDS = 'cards'
}


function ShopItem:init(item, item_type)
    self.item = item
    self.item_type = item_type

    self.colour = Colours.GREY2
    if self.item_type == StockTypes.BULLETS then
        if self.item.type == 'money' then
            self.colour = Colours.YELLOW1
        elseif self.item.type == 'health' then
            self.colour = Colours.GREEN2
        elseif self.item.type == 'damage' then
            self.colour = Colours.RED2
        end
    elseif self.item_type == StockTypes.CARDS then
        self.colour = Colours.BROWN1
    end
end


function Shop:init()
    self.stock = {}
    self.stock_types = StockTypes
    self:reroll_bullets()
    self:reroll_cards()

end


function Shop:reroll_bullets()
    local bullet_keys = {}
    for k, _ in pairs(Bullets) do
        table.insert(bullet_keys, k)
    end

    self.stock[StockTypes.BULLETS] = {}
    for i = 1, 6 do
        local random_key = bullet_keys[math.random(#bullet_keys)]
        table.insert(self.stock[StockTypes.BULLETS], ShopItem(Bullets[random_key], StockTypes.BULLETS))
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
        table.insert(self.stock[StockTypes.CARDS], ShopItem(Cards[card_keys[i]], StockTypes.CARDS))
    end
end



return Shop
