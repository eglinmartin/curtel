local shadowShader = love.graphics.newShader([[
    vec4 effect(vec4 color, Image tex, vec2 texCoords, vec2 screenCoords) {
        vec4 pixel = Texel(tex, texCoords);
        if (pixel.a == 0.0) {
            // Keep transparent pixels untouched
            return vec4(0.0, 0.0, 0.0, 0.0);
        }
        // Overwrite non-transparent pixels with outline color
        return vec4(color.rgb, pixel.a);
    }
]])

local Shaders = {
    SHADOW = shadowShader
}

return Shaders
