-- entity.lua
local Class = require("lib.class")
local flux = require("lib.flux")

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

    self.drotation = 0
    self.shadow_x = self.x
    self.shadow_y = self.y
    
    -- Get interaction information
    if args.hoverable then self.hoverable = args.hoverable or false end
    if args.draggable then self.draggable = args.draggable or false end

    -- Get sprite information
    if args.sprite_sheet then self.sprite_sheet = args.sprite_sheet end
    if args.sprite_tag then  self.sprite_tag = args.sprite_tag end
    if args.background then self.background = true or false end

    if args.depth then self.original_depth = args.depth or 255 end
    self.depth = self.original_depth

    -- input state
    self.hovered = false
    self.dragging = false
    self.clicked = false
    self.released = false

    if self.sprite_sheet and self.sprite_tag then
        self:create_sprite()
    end
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
        self.id, self.sprite_sheet, self.sprite_tag, self.x, self.y, self.rotation, self.scale, self.depth
    )
    else
        self.render_manager:create_draw_object_foreground(
            self.id, self.sprite_sheet, self.sprite_tag, self.x, self.y, self.rotation, self.scale, self.depth
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
    
    if self.x ~= self.xprevious or self.y ~= self.yprevious or self.scale ~= self.scaleprevious or self.rotation ~= self.rotationprevious then
        self:create_sprite()
    end

    self.xprevious = self.x
    self.yprevious = self.y
    self.scaleprevious = self.scale
    self.rotationprevious = self.rotation
end


function Entity:drag()
    self.x = self.input_manager.mx
    self.y = self.input_manager.my
    self.dscale = 0.2
    self.depth = 254
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
    end
    
    local is_clicked = is_hovered and mouse_pressed
    if is_clicked ~= self.clicked then
        self.clicked = is_clicked
        if self.clicked then self:on_click() end
    end

    self.released = false
    local is_dragging = self.dragging and mouse_down
                     or is_hovered and mouse_pressed
    if is_dragging ~= self.dragging and self.draggable then
        self.dragging = is_dragging

        if self.dragging then
            self:on_drag_start()
        else
            self:on_drag_end()
        end
    end

    if self.dragging then
    end

end


function Entity:clear_sprite()
    self.render_manager.draw_objects_foreground[self.id] = nil
end


function Entity:on_hover_start()
    flux.to(self, 0.25, {scale=1.2}):ease("expoout"):oncomplete(function()
    end)
end


function Entity:on_hover_end()
    flux.to(self, 0.25, {scale=1}):ease("expoout"):oncomplete(function()
    end)
end


function Entity:on_click()
    
end


function Entity:on_drag_start()
    self.original_x = self.x
    self.original_y = self.y
end


function Entity:on_drag_end()
    self.dragging = false
    self.released = true
    self.depth = self.original_depth
    
    self.release_x = self.x
    self.release_y = self.y
    flux.to(self, 0.5, {x=self.original_x, y=self.original_y, scale=1}):ease("expoout")
end


return Entity
