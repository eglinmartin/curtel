local Class = require("lib.class")
local Bullet = Class{}


function Bullet:init(tag, type, name, effect, cost, unlocked, description)
    self.tag = tag
    self.type = type
    self.name = name
    self.effect = effect
    self.cost = cost
    self.unlocked = unlocked
    self.description = description
end


Bullets = {
    -- Bullets
    BULLET_BRONZE = Bullet('bullet_bronze', 'bullet', 'Brass Round', 2, 1, false, "A dissapointingly weak hit (1 dmg)"),
    BULLET_SILVER = Bullet('bullet_silver', 'bullet', 'Silver Round', 3, 2, false, "Description"),
    BULLET_GOLD = Bullet('bullet_gold', 'bullet', 'Gold Round', 5, 3, false, "Description"),
    BULLET_TITANIUM = Bullet('bullet_titanium', 'bullet', 'Titanium Round', 5, 5, false, "Description"),
    BULLET_URANIUM = Bullet('bullet_uranium', 'bullet', 'Uranium Round', 5, 10, false, "Description"),

    -- Health
    HEALTH_BEER = Bullet('health_beer', 'health', 'Beer', 0, 10, false, "Description"),
    HEALTH_WHISKY = Bullet('health_whisky', 'health', 'Whisky', 0, 12, false, "Description"),
    HEALTH_COFFEE = Bullet('health_coffee', 'health', 'Coffee', 0, 12, false, "Description"),
    HEALTH_BEANS = Bullet('health_beans', 'health', 'Beans', 0, 10, false, "Description"),
    HEALTH_BREAD = Bullet('health_bread', 'health', 'Bread', 0, 10, false, "Description"),
    HEALTH_BISCUITS = Bullet('health_biscuits', 'health', 'Biscuits', 0, 10, false, "Description"),
    HEALTH_MEDKIT = Bullet('health_medkit', 'health', 'Medkit', 0, 10, false, "Description"),
    HEALTH_CIGARETTES = Bullet('health_cigarettes', 'health', 'Cigarettes', 0, 10, false, "Description"),

    -- Money
    MONEY_DOLLARBILL = Bullet('money_dollarbill', 'money', 'Dollar Bill', 0, 10, false, "Description"),
    MONEY_BAGOFCASH = Bullet('money_bagofcash', 'money', 'Bag of Cash', 0, 10, false, "Description"),
    MONEY_PILEOFCASH = Bullet('money_pileofcash', 'money', 'Pile of Cash', 0, 10, false, "Description"),
    MONEY_TREASURECHEST = Bullet('money_treasurechest', 'money', 'Treasure Chest', 0, 10, false, "Description"),

    -- Damage
    DAMAGE_DYNAMITE = Bullet('damage_dynamite', 'damage', 'Dynamite', 0, 10, false, "Description"),
    DAMAGE_BOMB = Bullet('damage_bomb', 'damage', 'Bomb', 0, 10, false, "Description"),
    DAMAGE_GUNPOWDER = Bullet('damage_gunpowder', 'damage', 'Gunpowder', 0, 10, false, "Description"),
    DAMAGE_TNT = Bullet('damage_tnt', 'damage', 'T.N.T', 0, 10, false, "Description"),
    DAMAGE_SHOTGUN = Bullet('damage_shotgun', 'damage', 'Shotgun', 0, 10, false, "Description"),
    DAMAGE_ANVIL = Bullet('damage_anvil', 'damage', 'Anvil', 0, 10, false, "Description"),
}


return Bullets
