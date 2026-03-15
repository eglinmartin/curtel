local Class = require("lib.class")

local Enemy = Class{}


States = {
    IDLE = 1,
}


function Enemy:init(controller)
    self.state = States.IDLE
    
    self.health = 10
    self.max_health = 10
    self.money = 100
    self.animations = {}

    self.hand = {}
    self.hand_size = 3
end


function Enemy:update(dt)
end


function Enemy:draw()
end


return Enemy
