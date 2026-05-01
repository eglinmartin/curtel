-- entity.lua
local Class = require("lib.class")
local Entity = Class{}


function Entity:init(x, y, w, h)
    self.x = x or 0
    self.y = y or 0
    self.w = w or 0
    self.h = h or 0

    self.state = nil
    self.animations = {}

    -- input state
    self.hovered = false
    self.dragging = false
    self.clicked = false
end


function Entity:contains_point(mx, my)
    local half_w = self.w / 2
    local half_h = self.h / 2
    return mx > self.x - half_w and mx < self.x + half_w
       and my > self.y - half_h and my < self.y + half_h
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
                     or is_hovered and mouse_down
    if is_dragging ~= self.dragging then
        self.dragging = is_dragging
        if self.dragging then self:on_drag_start()
        else self:on_drag_end() end
    end
end


-- stubs for subclasses to override
function Entity:on_hover_changed() end
function Entity:on_click() end
function Entity:on_drag_start() end
function Entity:on_drag_end() end


function Entity:update(dt, mx, my, mouse_down, mouse_pressed)
    self:update_input(mx, my, mouse_down, mouse_pressed)
end


function Entity:draw()

end


return Entity
