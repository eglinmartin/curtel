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
    
end


function LeTruc:change_state(state)
    self.game_state = state

    -- Start a new game
    if self.game_state == GameStates.NEWGAME then
        self:start_new_game()
    
    elseif self.game_state == GameStates.NEWHAND then
        self:start_new_hand()
        self:deal_hand(self.player1)
        self:deal_hand(self.player2)

    elseif self.game_state == GameStates.NEWTRICK then
        self:start_new_trick()

    end 
    print("STATE: " .. self.game_state)
end


function LeTruc:start_new_game()
    -- Reset decks, shuffle cards, set scores to zero
    self.game_scores = {[Players.PLAYER1] = 0, [Players.PLAYER2] = 0}
    self.hand_scores = {[Players.PLAYER1] = 0, [Players.PLAYER2] = 0}
    self.played_cards = {[Players.PLAYER1] = EMPTY, [Players.PLAYER2] = EMPTY}
    self.num_hands = 0
    self.winner = nil

    self:shuffle_deck(self.player1)
    self:shuffle_deck(self.player2)
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
    self.num_hands = self.num_hands + 1
    self.hand_scores = {[Players.PLAYER1] = 0, [Players.PLAYER2] = 0}
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
    self:change_state(GameStates.PLAYTRICK)
end


function LeTruc:select_card(player, card)
    if player.id == 'player' then
        self.played_cards[Players.PLAYER1] = card
    elseif player.id == 'enemy' then
        self.played_cards[Players.PLAYER2] = card
    end
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
