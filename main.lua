_G.love = require("love")

-- assets location
ASSET_LOC = 'assets/'
TEXTURE_LOC = ASSET_LOC .. 'textures/'

-- libraries
-- push https://github.com/Ulydev/push
local push = require 'push'
-- class
Class = require 'class'

require 'Bird'
require 'Pipe'

-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- load textures
local backgroundTexture = love.graphics.newImage(TEXTURE_LOC .. 'background.png')
local groundTexture = love.graphics.newImage(TEXTURE_LOC .. 'ground.png')

--
local backgroundScroll = 0
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413

--
local bird = Bird()

local pipes = {}

local spawnTimer = 0



function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Flappy Bird')

    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    love.keyboard.keyPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keyPressed[key] = true
    if key == 'escape' then
        love.event.quit()
    end
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keyPressed[key]
end

function love.update(dt)
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt)
        % BACKGROUND_LOOPING_POINT

    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt)
        % VIRTUAL_WIDTH

    spawnTimer = spawnTimer + dt
    if spawnTimer > 4 then
        table.insert(pipes, Pipe())
        spawnTimer = 0
    end

    bird:update(dt)

    for key, pipe in pairs(pipes) do
        pipe:update(dt)

        if pipe.x < -pipe.width then
            table.remove(pipes, key)
        end
    end

    -- reset input table every frame
    love.keyboard.keyPressed = {}
end

function love.draw()
    push:start()

    -- layer 0
    love.graphics.draw(backgroundTexture, -backgroundScroll, 0)

    -- layer 1
    for key, pipe in pairs(pipes) do
        pipe:render()
    end

-- layer 2
    love.graphics.draw(groundTexture, -groundScroll, VIRTUAL_HEIGHT - 16)

    -- layer 3
    bird:render()



    push:finish()
end
