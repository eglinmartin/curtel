-- entity.lua
local Class = require("lib.class")
local Entity = Class{}


function Entity:init(id, GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER, args)
    self.id = id
    
    self.game_context = GAME_CONTEXT
    self.event_manager = EVENT_MANAGER
    self.input_manager = INPUT_MANAGER
    self.render_manager = RENDER_MANAGER

    if type(args) ~= "table" then return end

    -- Create physical positions
    if args.x then self.x = args.x or 0 end
    if args.y then self.y = args.y or 0 end
    if args.w then self.width = args.w or 0 end
    if args.h then self.height = args.h or 0 end
    if args.s then self.scale = args.s or 1 end
    if args.r then self.rotation = args.r * (math.pi / 180) end

    -- Create theoretical positions
    self.dx = 0
    self.dy = 0
    self.dscale = 0
    self.drotation = 0
    self.shadow_x = self.x
    self.shadow_y = self.y
    
    -- Get interaction information
    if args.draggable then self.draggable = args.draggable or false end

    -- Get sprite information
    if args.sprite_sheet then self.sprite_sheet = args.sprite_sheet end
    if args.sprite_tag then  self.sprite_tag = args.sprite_tag end
    if args.depth then self.depth = args.depth or 255 end
    if args.background then self.background = true or false end

    -- input state
    self.hovered = false
    self.dragging = false
    self.clicked = false
end


function Entity:move(x, y)
    self.shadow_x = self.x
    self.shadow_y = self.y
    self.x = x
    self.y = y
    self:create_sprite()
end


function Entity:rescale(scale)
    self.scale = scale * (math.pi / 180)
    self:create_sprite()
end


function Entity:rotate(rotation)
    self.rotation = rotation * (math.pi / 180)
    self:create_sprite()
end


function Entity:create_sprite()
    -- Create sprite on screen
    if self.background then
        self.render_manager:create_draw_object_background(
        self.id, self.sprite_sheet, self.sprite_tag, self.x + self.dx, self.y + self.dy, self.rotation + self.drotation, self.scale + self.dscale, self.depth
    )
    else
        self.render_manager:create_draw_object_foreground(
            self.id, self.sprite_sheet, self.sprite_tag, self.x + self.dx, self.y + self.dy, self.rotation + self.drotation, self.scale + self.dscale, self.depth
        )
    end
end


function Entity:animate(args)
    if args.dx then self.dx = args.dx end
    if args.dy then self.dy = args.dy end
    if args.dscale then self.dscale = args.dscale end
    if args.drotation then self.drotation = args.drotation end
end


function Entity:contains_point(mx, my)
    local half_width = self.width / 2
    local half_height = self.height / 2
    return mx > self.x - half_width and mx < self.x + half_width
       and my > self.y - half_height and my < self.y + half_height
end


function Entity:update(dt, mx, my, mouse_down, mouse_pressed)
    -- Update inputs
    self:update_input(mx, my, mouse_down, mouse_pressed)

    if self.dx ~= 0 or self.dy ~= 0 or self.dscale ~= 0 and not self.dragging then
        self.dx = self:return_to_xy(self.dx, dt)
        self.dy = self:return_to_xy(self.dy, dt)
        self.dscale = self:return_to_scale(dt)
        self:create_sprite()
    end
    
end


function Entity:drag()
    self.dx = self.input_manager.mx - self.x
    self.dy = self.input_manager.my - self.y
    self:create_sprite()
end


function Entity:return_to_xy(d, dt)
    local decay = 16
    d = d * math.exp(-decay * dt)
    self:create_sprite()

    if math.abs(d) < 0.1 then
        return 0
    end

    return d
end


function Entity:return_to_scale(dt)
    local decay = 16
    self.dscale = self.dscale * math.exp(-decay * dt)

    if math.abs(self.dscale) < 0.001 then
        return 0
    end

    return self.dscale
end


function Entity:update_input(mx, my, mouse_down, mouse_pressed)
    local is_hovered = self:contains_point(mx, my)
    if is_hovered ~= self.hovered then
        self.hovered = is_hovered
        self:on_hover_changed()
    end
    
    local is_clicked = is_hovered and mouse_pressed
    if is_clicked ~= self.clicked then
        self.clicked = is_clicked
        if self.clicked then self:on_click() end
    end

    local is_dragging = self.dragging and mouse_down
                     or is_hovered and mouse_pressed
    if is_dragging ~= self.dragging and self.draggable then
        self.dragging = is_dragging
        if self.dragging then self:on_drag_start()
        else self:on_drag_end() end
    end
end


function Entity:clear_sprite()
    self.render_manager.draw_objects_foreground[self.id] = nil
    self.render_manager.draw_objects_background[self.id] = nil
end


function Entity:on_hover_changed()
end


function Entity:on_click()
end


function Entity:on_drag_start()
end


function Entity:on_drag_end()
    self.dragging = false
end


return Entity
