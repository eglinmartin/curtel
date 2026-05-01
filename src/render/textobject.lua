local Class = require("lib.class")

local TextObject = Class{}


function TextObject:init(name, text, colour, x, y, rot, scale, depth, align)
    self.name = name
    self.text = text
    self.colour = colour
    self.depth = depth
    self.align = align
    
    -- Bring in object's real location parameters
    self.x = x
    self.y = y
    self.rot = rot
    self.scale = scale

    -- Create theoretical location parameters
    self.dx = 0
    self.dy = 0
    self.dscale = 0
    self.drot = 0
end


function TextObject:update(dt)
    self.dx = self:return_to_xy(self.dx, dt)
    self.dy = self:return_to_xy(self.dy, dt)
    self.dscale = self:return_to_scale(dt)
end


function TextObject:animate(args)
    if args.dx then self.dx = args.dx end
    if args.dy then self.dy = args.dy end
    if args.dscale then self.dscale = args.dscale end
    if args.drot then self.drot = args.drot end
end


function TextObject:return_to_xy(d, dt)
    local decay = 16
    d = d * math.exp(-decay * dt)

    if math.abs(d) < 0.1 then
        return 0
    end

    return d
end


function TextObject:return_to_scale(dt)
    local decay = 16
    self.dscale = self.dscale * math.exp(-decay * dt)

    if math.abs(self.dscale) < 0.001 then
        return 0
    end

    return self.dscale
end


return TextObject
