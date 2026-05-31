local Class = require("lib.class")

local DrawObject = Class{}


function DrawObject:init(name, sprite, x, y, scale, rot, depth)
    self.name = name
    self.sprite = sprite
    self.depth = depth
    
    -- Bring in object's real location parameters
    self.x = x
    self.y = y
    self.scale = scale
    self.rot = rot * (math.pi / 180)

    -- Create theoretical location parameters
    self.dx = 0
    self.dy = 0
    self.dscale = 0
    self.drot = 0
end


function DrawObject:move(x, y)
    self.x = x
    self.y = y
end


function DrawObject:animate(args)
    if args.dx then self.dx = args.dx end
    if args.dy then self.dy = args.dy end
    if args.dscale then self.dscale = args.dscale end
    if args.drot then self.drot = math.rad(args.drot) end
end


function DrawObject:update(dt)
    self.sprite:update(dt)

    self.dx = self:return_to_xy(self.dx, dt)
    self.dy = self:return_to_xy(self.dy, dt)
    self.dscale = self:return_to_scale(dt)
    self.drot = self:return_to_rot(dt)
end


function DrawObject:return_to_xy(d, dt)
    local decay = 16
    d = d * math.exp(-decay * dt)

    if math.abs(d) < 0.1 then
        return 0
    end

    return d
end


function DrawObject:return_to_scale(dt)
    local decay = 16
    self.dscale = self.dscale * math.exp(-decay * dt)

    if math.abs(self.dscale) < 0.001 then
        return 0
    end

    return self.dscale
end


function DrawObject:return_to_rot(dt)
    local decay = 16
    self.drot = self.drot * math.exp(-decay * dt)

    if math.abs(self.drot) < 0.001 then
        return 0
    end

    return self.drot
end


return DrawObject
