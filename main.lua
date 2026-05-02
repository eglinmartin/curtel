if arg and arg[2] == "debug" then
    local ok, dbg = pcall(require, "lldebugger")
    if ok then dbg.start() end
end

local rs = require("lib.resolution_solution")

local GameContext = require("src.core.gamecontext")
local GameState = require("src.core.gamestate")

local EventManager = require("src.event.eventmanager")
local InputManager = require("src.input.inputmanager")
local RenderManager = require("src.render.rendermanager")
local SceneManager = require("src.scene.scenemanager")

rs.conf({game_width = 240, game_height = 135, pixel_perfect = true})
rs.setMode(1920, 1080, {fullscreen = true})


function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())
    love.window.setIcon(love.image.newImageData("assets/icon_128x128.png"))
    love.mouse.setVisible(false)

    -- Initialize game constants
    GAME_CONTEXT = GameContext()

    -- Initialize managers
    EVENT_MANAGER = EventManager()
    INPUT_MANAGER = InputManager(EVENT_MANAGER, rs)
    RENDER_MANAGER = RenderManager(EVENT_MANAGER, rs)

    -- Initialize game state
    GAME_STATE = GameState(GAME_CONTEXT, EVENT_MANAGER, INPUT_MANAGER, RENDER_MANAGER)

    SCENE_MANAGER = SceneManager(GAME_STATE, RENDER_MANAGER, EVENT_MANAGER, INPUT_MANAGER)
end


function love.resize(w, h)
    rs.resize(w, h)
end


function love.keypressed(key)
    INPUT_MANAGER:keypressed(key)
end


function love.mousepressed(x, y, button)
    INPUT_MANAGER:mousepressed(x, y, button)
end


function love.mousereleased(x, y, button)
    INPUT_MANAGER:mousereleased(x, y, button)
end


function love.update(dt)
    -- Update game loop
    GAME_CONTEXT:update(dt)
    GAME_STATE:update(dt)
    
    -- Update managers
    INPUT_MANAGER:update(dt)
    RENDER_MANAGER:update(dt)
    SCENE_MANAGER:update(dt)
end


function love.draw()
    RENDER_MANAGER:draw(rs)
end


if lldebugger then
    local love_errorhandler = love.errorhandler
    function love.errorhandler(msg)
        error(msg, 2)
    end
end

