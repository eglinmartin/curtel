local Class = require("lib.class")
local LeTruc = Class{}

local EMPTY = "empty"


local Players = {
    PLAYER1 = "Player 1",
    PLAYER2 = "Player 2"
}


local GameStates = {
    NEWGAME = "Start new game",
    NEWHAND = "Start new hand",
    NEWTRICK = "Start new trick",
    DEALCARDS = "Deal cards",
    PLAYTRICK = "Play trick",
    COMPARECARDS = "Compare cards",
    RESOLVETRICK = "Resolve trick",
    GUNFIGHT = "Gunfight",
}


function LeTruc:init(event_manager)
    -- Initialize variables and begin game
    self.states = GameStates
    self.game_state = ''
    self.event_manager = event_manager

    -- Initialize players
    self.player1 = nil
    self.player2 = nil
    
    self.stakes = 0
end


function LeTruc:start_new_game(player1, player2)
    print("new game started")
    self.game_state = GameStates.NEWGAME
    self.player1 = player1
    self.player2 = player2

    -- Reset decks, shuffle cards, set scores to zero
    self.game_score = {[self.player1] = 0, [self.player2] = 0}
    self.hand_score = {[self.player1] = 0, [self.player2] = 0}
    self.played_cards = {[self.player1] = EMPTY, [self.player2] = EMPTY}

    self.num_hands = 0
    self.num_tricks = 0

    self.winner = nil

    self:shuffle_deck(self.player1)
    self:shuffle_deck(self.player2)
end


function LeTruc:start_new_hand()
    print("new hand started")
    self.game_state = GameStates.NEWHAND

    -- Deal cards, start new trick
    self.num_hands = self.num_hands + 1
    self.num_tricks = 0
    self.hand_score = {[self.player1] = 0, [self.player2] = 0}
    self.stakes = {[self.player1] = 0, [self.player2] = 0}

    self:deal_hand(self.player1)
    self:deal_hand(self.player2)

    self:evaluate_hand(self.player1)
    self:evaluate_hand(self.player2)
end


function LeTruc:shuffle_deck(player)
    player.deck:reset()
    player.deck:shuffle()
end


function LeTruc:deal_hand(player)
    for i = 1, player.hand_size do
        -- If no cards left to deal, reset and shuffle decks
        if #player.deck.cards == 0 then
            self:shuffle_deck(player)
        end
        -- Deal a card
        player.hand[i] = player.deck:deal_card()
    end
end


function LeTruc:evaluate_hand(player)
    -- Score hand strength to decide whether to raise, continue, or fold
    local hand_sum = 0
    for i, card in pairs(player.hand) do
        hand_sum = hand_sum + card.effect
    end

    local hand_score = 0
    if hand_sum <= 12 then hand_score = 1
    elseif hand_sum <= 19 then hand_score = 2
    elseif hand_sum <= 26 then hand_score = 3
    elseif hand_sum <= 33 then hand_score = 4
    else hand_score = 5
    end
    
    print("- " .. player.id .. "'s hand is worth " .. hand_score .. "/5 (" .. hand_sum .. "/42)")
end


function LeTruc:start_new_trick()
    -- Begin a new trick - reset comparisons and trick variables
    print("new trick started")
    self.num_tricks = self.num_tricks + 1
    self.game_state = GameStates.PLAYTRICK
end


function LeTruc:select_card(player, card)
    if player.id == 'player' then
        self.played_cards[Players.PLAYER1] = card
    elseif player.id == 'enemy' then
        self.played_cards[Players.PLAYER2] = card
    end
    print("- " .. player.id .. " has played " .. card.value .. " of " .. card.suit)
end


function LeTruc:compare_cards()
    local winner = nil
    -- Compare between two cards to decide who wins the trick
    if self.played_cards[Players.PLAYER1] ~= EMPTY and self.played_cards[Players.PLAYER2] ~= EMPTY then
        if self.played_cards[Players.PLAYER1].effect > self.played_cards[Players.PLAYER2].effect then
            winner =  self.player1
        elseif self.played_cards[Players.PLAYER1].effect < self.played_cards[Players.PLAYER2].effect then
            winner = self.player2
        end
    end
    if winner then
        self.hand_score[winner] = self.hand_score[winner] + 1
    end
    return winner
end


function LeTruc:finish_trick()
    -- Reward the winner, punish the loser and end the trick
    self.played_cards[Players.PLAYER1] = nil
    self.played_cards[Players.PLAYER2] = nil
end


function LeTruc:finish_hand()
    -- Reward the winner, punish the loser and end the trick
    if self.hand_score[self.player1] > self.hand_score[self.player2] then
        self.game_score[self.player1] = self.game_score[self.player1] + 1
    elseif self.hand_score[self.player2] > self.hand_score[self.player2] then
        self.game_score[self.player2] = self.game_score[self.player2] + 1
    end
end


function LeTruc:finish_game()
    -- End the game - reset all variables
    print("Game over. " .. self.winner .. " wins the game.")
end


function LeTruc:bet(player)
    -- Raise the stakes of the trick
    self.stakes[player] = self.stakes[player] +  1
    print(player.id .. " has betted")
end


function LeTruc:call(player)
    -- Call the opponent's raise
    self.stakes[player] = self.stakes[player] +  1
    print(player.id .. " has called")
end


function LeTruc:fold(player)
    -- Fold and lose the round
    print(player.id .. " has folded")
end


return LeTruc
