if arg[2] == "debug" then
    require("lldebugger").start()
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
-- rs.setMode(960, 540, {fullscreen = false})


function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())

    -- Initialize game loop
    GAME_CONTEXT = GameContext()
    GAME_STATE = GameState(GAME_CONTEXT)

    -- Initialize managers
    EVENT_MANAGER = EventManager()
    INPUT_MANAGER = InputManager(EVENT_MANAGER)
    RENDER_MANAGER = RenderManager()
    SCENE_MANAGER = SceneManager(GAME_STATE, RENDER_MANAGER, EVENT_MANAGER)
end


function love.resize(w, h)
    rs.resize(w, h)
end


function love.keypressed(key)
    INPUT_MANAGER:keypressed(key)
end


function love.update(dt)
    -- Update game loop
    GAME_CONTEXT:update(dt)
    GAME_STATE:update(dt)
    
    -- Update managers
    RENDER_MANAGER:update(dt)
    SCENE_MANAGER:update(dt)
end


function love.draw()
    RENDER_MANAGER:draw(rs)
end


local love_errorhandler = love.errorhandler
function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end

