local Class = require("lib.class")
local Card = Class{}


function Card:init(name, suit, value, effect, cost, unlocked)
    self.value = value
    self.suit = suit
    self.name = name
    self.effect = effect
    self.cost = cost
    self.unlocked = unlocked
end


Cards = {
    -- Hearts
    CARD_2_HEARTS = Card('2 of hearts', 'hearts', '2', 2, 1, false),
    CARD_3_HEARTS = Card('3 of hearts', 'hearts', '3', 2, 1, false),
    CARD_4_HEARTS = Card('4 of hearts', 'hearts', '4', 2, 1, false),
    CARD_5_HEARTS = Card('5 of hearts', 'hearts', '5', 2, 2, false),
    CARD_6_HEARTS = Card('6 of hearts', 'hearts', '6', 2, 2, false),
    CARD_7_HEARTS = Card('7 of hearts', 'hearts', '7', 2, 2, false),
    CARD_8_HEARTS = Card('8 of hearts', 'hearts', '8', 2, 3, false),
    CARD_9_HEARTS = Card('9 of hearts', 'hearts', '9', 2, 3, false),
    CARD_10_HEARTS = Card('10 of hearts', 'hearts', '10', 2, 5, false),
    CARD_J_HEARTS = Card('jack of hearts', 'hearts', 'jack', 2, 7, false),
    CARD_Q_HEARTS = Card('queen of hearts', 'hearts', 'queen', 2, 8, false),
    CARD_K_HEARTS = Card('king of hearts', 'hearts', 'king', 2, 9, false),
    CARD_A_HEARTS = Card('ace of hearts', 'hearts', 'ace', 2, 10, false),

    -- Clubs
    CARD_2_CLUBS = Card('2 of clubs', 'clubs', '2', 2, 1, false),
    CARD_3_CLUBS = Card('3 of clubs', 'clubs', '3', 2, 1, false),
    CARD_4_CLUBS = Card('4 of clubs', 'clubs', '4', 2, 1, false),
    CARD_5_CLUBS = Card('5 of clubs', 'clubs', '5', 2, 2, false),
    CARD_6_CLUBS = Card('6 of clubs', 'clubs', '6', 2, 2, false),
    CARD_7_CLUBS = Card('7 of clubs', 'clubs', '7', 2, 2, false),
    CARD_8_CLUBS = Card('8 of clubs', 'clubs', '8', 2, 3, false),
    CARD_9_CLUBS = Card('9 of clubs', 'clubs', '9', 2, 3, false),
    CARD_10_CLUBS = Card('10 of clubs', 'clubs', '10', 2, 5, false),
    CARD_J_CLUBS = Card('jack of clubs', 'clubs', 'jack', 2, 7, false),
    CARD_Q_CLUBS = Card('queen of clubs', 'clubs', 'queen', 2, 8, false),
    CARD_K_CLUBS = Card('king of clubs', 'clubs', 'king', 2, 9, false),
    CARD_A_CLUBS = Card('ace of clubs', 'clubs', 'ace', 2, 10, false),

    -- Spades
    CARD_2_SPADES = Card('2 of spades', 'spades', '2', 2, 1, false),
    CARD_3_SPADES = Card('3 of spades', 'spades', '3', 2, 1, false),
    CARD_4_SPADES = Card('4 of spades', 'spades', '4', 2, 1, false),
    CARD_5_SPADES = Card('5 of spades', 'spades', '5', 2, 2, false),
    CARD_6_SPADES = Card('6 of spades', 'spades', '6', 2, 2, false),
    CARD_7_SPADES = Card('7 of spades', 'spades', '7', 2, 2, false),
    CARD_8_SPADES = Card('8 of spades', 'spades', '8', 2, 3, false),
    CARD_9_SPADES = Card('9 of spades', 'spades', '9', 2, 3, false),
    CARD_10_SPADES = Card('10 of spades', 'spades', '10', 2, 5, false),
    CARD_J_SPADES = Card('jack of spades', 'spades', 'jack', 2, 7, false),
    CARD_Q_SPADES = Card('queen of spades', 'spades', 'queen', 2, 8, false),
    CARD_K_SPADES = Card('king of spades', 'spades', 'king', 2, 9, false),
    CARD_A_SPADES = Card('ace of spades', 'spades', 'ace', 2, 10, false),

    -- Diamonds
    CARD_2_DIAMONDS = Card('2 of diamonds', 'diamonds', '2', 2, 1, false),
    CARD_3_DIAMONDS = Card('3 of diamonds', 'diamonds', '3', 2, 1, false),
    CARD_4_DIAMONDS = Card('4 of diamonds', 'diamonds', '4', 2, 1, false),
    CARD_5_DIAMONDS = Card('5 of diamonds', 'diamonds', '5', 2, 2, false),
    CARD_6_DIAMONDS = Card('6 of diamonds', 'diamonds', '6', 2, 2, false),
    CARD_7_DIAMONDS = Card('7 of diamonds', 'diamonds', '7', 2, 2, false),
    CARD_8_DIAMONDS = Card('8 of diamonds', 'diamonds', '8', 2, 3, false),
    CARD_9_DIAMONDS = Card('9 of diamonds', 'diamonds', '9', 2, 3, false),
    CARD_10_DIAMONDS = Card('10 of diamonds', 'diamonds', '10', 2, 5, false),
    CARD_J_DIAMONDS = Card('jack of diamonds', 'diamonds', 'jack', 2, 7, false),
    CARD_Q_DIAMONDS = Card('queen of diamonds', 'diamonds', 'queen', 2, 8, false),
    CARD_K_DIAMONDS = Card('king of diamonds', 'diamonds', 'king', 2, 9, false),
    CARD_A_DIAMONDS = Card('ace of diamonds', 'diamonds', 'ace', 2, 10, false)
}


return Cards
