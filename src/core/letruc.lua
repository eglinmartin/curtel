local Class = require("lib.class")
local LeTruc = Class{}


function LeTruc:init()
    -- Initialize variables
end


function LeTruc:start_new_game()
    -- Reset decks, shuffle cards, set score to zero
end


function LeTruc:check_score()
    -- Check for win, loss
end


function LeTruc:start_new_hand()
    -- Deal cards, start new trick
end


function LeTruc:evaluate_hand()
    -- Score hand strength to decide whether to raise, continue, or fold
end


function LeTruc:start_new_trick()
    -- Begin a new trick - reset comparisons and trick variables
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

