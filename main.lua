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
require 'PipePair'

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
local GROUND_LOOPING_POINT = 514

--
local bird = Bird()

local pipePairs = {}

local spawnTimer = 2

local lastY = -PIPE_HEIGHT + math.random(80) + 20

local scrolling = true



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
    if (scrolling) then
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt)
            % BACKGROUND_LOOPING_POINT

        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt)
            % GROUND_LOOPING_POINT

        spawnTimer = spawnTimer + dt
        if spawnTimer > 3 then
            local y = math.max(-PIPE_HEIGHT + 10,
                math.min(lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
            lastY = y

            table.insert(pipePairs, PipePair(y))
            spawnTimer = 0
        end

        bird:update(dt)

        for k, pipePair in pairs(pipePairs) do
            pipePair:update(dt)

            for l, pipe in pairs(pipePair.pipes) do
                if bird:isCollide(pipe) then
                    scrolling = false
                end
            end

            if pipePair.remove then
                table.remove(pipePairs, k)
            end
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
    for key, pipePair in pairs(pipePairs) do
        pipePair:render()
    end

    -- layer 2
    love.graphics.draw(groundTexture, -groundScroll, VIRTUAL_HEIGHT - 16)

    -- layer 3
    bird:render()



    push:finish()
end
