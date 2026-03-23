local Class = require("lib.class")
local Token = Class{}


function Token:init(tag, type, name, effect, cost, unlocked, description)
    self.tag = tag
    self.type = type
    self.name = name
    self.effect = effect
    self.cost = cost
    self.unlocked = unlocked
    self.description = description
end


Tokens = {
    -- Bullets
    BULLET_BRONZE = Token('bullet_bronze', 'bullet', 'Brass Round', 2, 1, false, "A dissapointingly weak hit (1 dmg)"),
    BULLET_SILVER = Token('bullet_silver', 'bullet', 'Silver Round', 3, 2, false, "Description"),
    BULLET_GOLD = Token('bullet_gold', 'bullet', 'Gold Round', 5, 3, false, "Description"),
    BULLET_TITANIUM = Token('bullet_titanium', 'bullet', 'Titanium Round', 5, 5, false, "Description"),
    BULLET_URANIUM = Token('bullet_uranium', 'bullet', 'Uranium Round', 5, 10, false, "Description"),

    -- Health
    HEALTH_BEER = Token('health_beer', 'health', 'Beer', 0, 10, false, "Description"),
    HEALTH_WHISKY = Token('health_whisky', 'health', 'Whisky', 0, 12, false, "Description"),
    HEALTH_COFFEE = Token('health_coffee', 'health', 'Coffee', 0, 12, false, "Description"),
    HEALTH_BEANS = Token('health_beans', 'health', 'Beans', 0, 10, false, "Description"),
    HEALTH_BREAD = Token('health_bread', 'health', 'Bread', 0, 10, false, "Description"),
    HEALTH_BISCUITS = Token('health_biscuits', 'health', 'Biscuits', 0, 10, false, "Description"),
    HEALTH_MEDKIT = Token('health_medkit', 'health', 'Medkit', 0, 10, false, "Description"),
    HEALTH_CIGARETTES = Token('health_cigarettes', 'health', 'Cigarettes', 0, 10, false, "Description"),

    -- Money
    MONEY_DOLLARBILL = Token('money_dollarbill', 'money', 'Dollar Bill', 0, 10, false, "Description"),
    MONEY_BAGOFCASH = Token('money_bagofcash', 'money', 'Bag of Cash', 0, 10, false, "Description"),
    MONEY_PILEOFCASH = Token('money_pileofcash', 'money', 'Pile of Cash', 0, 10, false, "Description"),
    MONEY_TREASURECHEST = Token('money_treasurechest', 'money', 'Treasure Chest', 0, 10, false, "Description"),

    -- Damage
    DAMAGE_DYNAMITE = Token('damage_dynamite', 'damage', 'Dynamite', 0, 10, false, "Description"),
    DAMAGE_TNT = Token('damage_tnt', 'damage', 'T.N.T', 0, 10, false, "Description"),
}


return Tokens
