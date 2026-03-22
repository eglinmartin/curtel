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
    BULLET_BRONZE = Token('bullet_bronze', 'bullet', 'brass bullet', 2, 1, false, "A disappointingly weak bullet"),
    BULLET_SILVER = Token('bullet_silver', 'bullet', 'silver bullet', 3, 2, false, ""),
    BULLET_GOLD = Token('bullet_gold', 'bullet', 'gold bullet', 5, 3, false, ""),
    BULLET_TITANIUM = Token('bullet_titanium', 'bullet', 'titanium bullet', 5, 5, false, ""),
    BULLET_URANIUM = Token('bullet_uranium', 'bullet', 'uranium', 5, 10, false, ""),

    -- Health
    HEALTH_BEER = Token('health_beer', 'health', 'beer', 0, 10, false, ""),
    HEALTH_WHISKY = Token('health_whisky', 'health', 'whisky', 0, 12, false, ""),
    HEALTH_COFFEE = Token('health_coffee', 'health', 'coffee', 0, 12, false, ""),
    HEALTH_BEANS = Token('health_beans', 'health', 'beans', 0, 10, false, ""),
    HEALTH_BREAD = Token('health_bread', 'health', 'bread', 0, 10, false, ""),
    HEALTH_BISCUITS = Token('health_biscuits', 'health', 'biscuits', 0, 10, false, ""),
    HEALTH_MEDKIT = Token('health_medkit', 'health', 'medkit', 0, 10, false, ""),
    HEALTH_CIGARETTES = Token('health_cigarettes', 'health', 'cigarettes', 0, 10, false, ""),

    -- Money
    MONEY_DOLLARBILL = Token('money_dollarbill', 'money', 'dollarbill', 0, 10, false, ""),
    MONEY_BAGOFCASH = Token('money_bagofcash', 'money', 'bagofcash', 0, 10, false, ""),
    MONEY_PILEOFCASH = Token('money_pileofcash', 'money', 'pileofcash', 0, 10, false, ""),
    MONEY_TREASURECHEST = Token('money_treasurechest', 'money', 'treasurechest', 0, 10, false, ""),

    -- Damage
    DAMAGE_DYNAMITE = Token('damage_dynamite', 'damage', 'dynamite', 0, 10, false, ""),
    DAMAGE_TNT = Token('damage_tnt', 'damage', 'tnt', 0, 10, false, ""),
}


return Tokens
