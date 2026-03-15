local Class = require("lib.class")

local Player = Class{}


States = {
    IDLE = 1,
}


function Player:init(controller)
    self.controller = controller
    self.state = States.IDLE
    
    self.health = 10
    self.max_health = 10
    self.money = 10
    self.animations = {}

    self.hand_size = 3
    self.hand = {}
end


function Player:update(dt)
end


function Player:draw()
end


return Player
