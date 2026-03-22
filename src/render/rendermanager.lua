local Class = require("lib.class")
local peachy = require("lib.peachy")

local Colours = require("src.render.colours")
local Shaders = require("src.render.shaders")
local DrawObject = require("src.render.drawobject")
local TextObject = require("src.render.textobject")
local RenderManager = Class{}


function RenderManager:init(event_manager, rs)
    self.event_manager = event_manager
    self.rs = rs
    self:setup_events()
    self.colours = Colours

    self.font = love.graphics.newFont("assets/Curtel.ttf", 16)
    love.graphics.setFont(self.font)

    self.shadow_colour = {75/255, 90/255, 87/255, 1}
    self.draw_objects_background = {}
    self.draw_objects_foreground = {}
    self.text_objects = {}
end


function RenderManager:setup_events()
    -- Shuffle and reset the deck on shuffle command
    self.event_manager:on(
        self.event_manager.events.TOGGLE_FULLSCREEN, self, function()
            local fs = love.window.getFullscreen()
            if fs then
                self.rs.setMode(960, 540, {fullscreen = false})
            else
                self.rs.setMode(1920, 1080, {fullscreen = true})
            end
        end
    )

    -- Deal cards to the player on deal cards command
    self.event_manager:on(
        self.event_manager.events.DEALCARDS, self, function()
            self.animation_dealing = 0
        end
    )
end


function RenderManager:clear_screen()
    self.draw_objects_background = {}
    self.draw_objects_foreground = {}
    self.text_objects = {}
end


function RenderManager:update(dt)
    -- Update background animations
    for _, draw_object in pairs(self.draw_objects_background) do
       draw_object:update(dt)
    end

    -- Update foreground animations
    for _, draw_object in pairs(self.draw_objects_foreground) do
       draw_object:update(dt)
    end
    
    -- Update text animations
    for _, text_object in pairs(self.text_objects) do
       text_object:update(dt)
    end
end


function RenderManager:draw(rs)
    rs.push()

    self:draw_background()
    self:draw_foreground()

    rs.pop()
end


function RenderManager:create_draw_object_background(sprite_id, sprite_name, sprite_tag, x, y, scale, rot, depth)
    self.draw_objects_background[sprite_id] =
        DrawObject(
            sprite_id,
            peachy.new(
                "bin/json/" .. sprite_name .. ".json",
                love.graphics.newImage("bin/backgrounds/" .. sprite_name .. ".png"),
                sprite_tag
            ),
            x, y, rot, scale, depth
        )
end


function RenderManager:create_draw_object_foreground(sprite_id, sprite_name, sprite_tag, x, y, scale, rot, depth)
    self.draw_objects_foreground[sprite_id] =
        DrawObject(
            sprite_id,
            peachy.new(
                "bin/json/" .. sprite_name .. ".json",
                love.graphics.newImage("bin/sprites/" .. sprite_name .. ".png"),
                sprite_tag
            ),
            x, y, rot, scale, depth
        )
end


function RenderManager:remove_draw_object_foreground(sprite_id)
    self.draw_objects_foreground[sprite_id] = nil
end


function RenderManager:create_text_object(text_id, string, colour, x, y, scale, rot, depth, align)
    self.text_objects[text_id] = TextObject(text_id, string, colour, x, y, scale, rot, depth, align)
end


function RenderManager:remove_text_object(text_id)
    self.text_objects[text_id] = nil
end


function RenderManager:draw_background()
    -- Draw background layer
    for _, draw_obj in pairs(self.draw_objects_background) do
        draw_obj.sprite:draw(
            draw_obj.x + draw_obj.dx,
            draw_obj.y + draw_obj.dy,
            draw_obj.rot + draw_obj.drot,
            draw_obj.scale + draw_obj.dscale,
            draw_obj.scale + draw_obj.dscale,
            draw_obj.sprite:getWidth() / 2,
            draw_obj.sprite:getHeight() / 2
        )
    end
end


function RenderManager:draw_foreground()
    -- Sort sprites by depth
    local draw_list = {}
    for _, obj in pairs(self.draw_objects_foreground) do
        table.insert(draw_list, obj)
    end
    table.sort(draw_list, function(a, b)
        return a.depth < b.depth
    end)

    -- Sort text by depth
    local draw_text_list = {}
    for _, obj in pairs(self.text_objects) do
        table.insert(draw_text_list, obj)
    end
    table.sort(draw_text_list, function(a, b)
        return a.depth < b.depth
    end)
    
    -- Draw shadows layer (sprites)
    for _, draw_obj in ipairs(draw_list) do
        self:draw_shadow(
            draw_obj.sprite,
            draw_obj.x + draw_obj.dx,
            draw_obj.y + draw_obj.dy,
            draw_obj.rot + draw_obj.drot,
            draw_obj.scale + draw_obj.dscale,
            draw_obj.sprite:getWidth() / 2,
            draw_obj.sprite:getHeight() / 2
        )
    end

    -- Draw shadows layer (text)
    for _, text_obj in ipairs(draw_text_list) do
        local text_scale = text_obj.scale + text_obj.dscale

        -- Draw text shadow
        love.graphics.setColor(self.shadow_colour)
        local offsets = {{2, 0}, {2, 1}, {2, 2}, {1, 2}, {0, 2}}
        for i = 1, #offsets do
            local ox, oy = offsets[i][1], (offsets[i][2] - 6)
            self:draw_characters(text_obj.text, text_obj.x + text_obj.dx + ox, text_obj.y + text_obj.dy + oy, text_scale, text_obj.align)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw foreground layer (sprites)
    for _, draw_obj in ipairs(draw_list) do
        draw_obj.sprite:draw(
            draw_obj.x + draw_obj.dx,
            draw_obj.y + draw_obj.dy,
            draw_obj.rot + draw_obj.drot,
            draw_obj.scale + draw_obj.dscale,
            draw_obj.scale + draw_obj.dscale,
            draw_obj.sprite:getWidth() / 2,
            draw_obj.sprite:getHeight() / 2
        )
    end

    -- Draw foreground layer (text)
    for _, text_obj in ipairs(draw_text_list) do
        local text_scale = text_obj.scale + text_obj.dscale
        
        -- Draw text outline
        love.graphics.setColor(self.colours.BLACK)
        local offsets = {{1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}, {0, -1}, {1, -1}}

        for i = 1, #offsets do
            print(text_obj.scale + text_obj.dscale)
            local ox = (offsets[i][1] * text_scale)
            local oy = (offsets[i][2] * text_scale)
            self:draw_characters(text_obj.text, text_obj.x + text_obj.dx + ox, text_obj.y + text_obj.dy + oy - 6, text_scale, text_obj.align)
        end

        -- Draw text
        love.graphics.setColor(text_obj.colour)
        self:draw_characters(text_obj.text, text_obj.x + text_obj.dx, text_obj.y + text_obj.dy - 6, text_scale, text_obj.align)
    end
    love.graphics.setColor(1, 1, 1, 1)
end


function RenderManager:draw_characters(text, x, y, scale, align)
    if align ~= 'left' then
        local totalWidth = 0
        for i = 1, #text do
            local char = text:sub(i, i)
            totalWidth = totalWidth + self.font:getWidth(char) * scale
        end
        if align == 'centre' then
            x = x - totalWidth / 2
        elseif align == 'right' then
            x = x - totalWidth
        end
    end

    for i = 1, #text do
        local char = text:sub(i, i)
        love.graphics.print(char, x, y, 0, scale, scale)
        x = x + self.font:getWidth(char) * scale
    end
end

function RenderManager:set_shadow_colour(colour)
    self.shadow_colour = colour
end


function RenderManager:draw_shadow(anim, x, y, rot, scale, ox, oy)
    local outlineColor = self.shadow_colour

    love.graphics.setShader(Shaders["SHADOW"])
    love.graphics.setColor(outlineColor)

    anim:draw(x + 1, y + 1, rot, scale, scale, ox, oy)

    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1, 1)
end


return RenderManager

