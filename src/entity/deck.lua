local Class = require("lib.class")

local Deck = Class{}



function Deck:init()
    -- Create pack of cards
    self.card_library = Cards
    self.cards = {}
    self:reset()
end


function Deck:reset()
    self.cards = {}
    for _, card in pairs(Cards) do
        table.insert(self.cards, card)
    end
end


function Deck:shuffle()
    -- Shuffle the deck
    for i = #self.cards, 2, -1 do
        local j = math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end

end


function Deck:deal_card()
    local card = table.remove(self.cards, 1)
    return card
end


return Deck
