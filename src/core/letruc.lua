local Class = require("lib.class")
local LeTruc = Class{}


local Players = {
    PLAYER1 = "Player 1",
    PLAYER2 = "Player 2"
}


function LeTruc:init()
    -- Initialize variables and begin game
    self.game_scores = {PLAYER1 = nil, PLAYER2 = nil}
    self.hand_scores = {PLAYER1 = nil, PLAYER2 = nil}
    self.winner = nil
    self:start_new_game()
end


function LeTruc:start_new_game()
    -- Reset decks, shuffle cards, set scores to zero
    print("New game started")

    -- Reset scores and check
    self.game_scores = {PLAYER1 = 0, PLAYER2 = 0}
    self.hand_scores = {PLAYER1 = 0, PLAYER2 = 0}
end


function LeTruc:reset_cards()
    self.cards = {PLAYER1 = nil, PLAYER2 = nil}
end


function LeTruc:check_score()
    -- Check for win, loss
    print("Game scores: " .. Players.PLAYER1 .. " = " .. self.scores.PLAYER1 .. ", " .. Players.PLAYER2 .. " = " .. self.scores.PLAYER2)
    for player, score in pairs(self.scores) do
        if score == 3 then
            self.winner = player
            self:finish_game()
        end
    end
end


function LeTruc:start_new_hand()
    -- Deal cards, start new trick
    print("New hand started")
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


function LeTruc:evaluate_hand()
    -- Score hand strength to decide whether to raise, continue, or fold
end


function LeTruc:start_new_trick()
    -- Begin a new trick - reset comparisons and trick variables
    print("New trick started")
end


function LeTruc:select_card(player)
    -- Select card for a given player
end


function LeTruc:compare_cards()
    -- Compare between two cards to decide who wins the trick
end


function LeTruc:finish_trick()
    -- Reward the winner, punish the loser and end the trick
end


function LeTruc:finish_game()
    -- End the game - reset all variables
    print("Game over. " .. self.winner .. " wins the game.")
end


function LeTruc:raise(player)
    -- Raise the stakes of the trick
end


function LeTruc:call(player)
    -- Call the opponent's raise
end


function LeTruc:fold(player)
    -- Fold and lose the round
end


return LeTruc
