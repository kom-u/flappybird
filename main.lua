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


function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Flappy Bird')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.update(dt)
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt)
        % BACKGROUND_LOOPING_POINT

    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt)
        % VIRTUAL_WIDTH
end

function love.draw()
    push:start()

    love.graphics.draw(backgroundTexture, -backgroundScroll, 0)
    love.graphics.draw(groundTexture, -groundScroll, VIRTUAL_HEIGHT - 16)

    bird:render()

    push:finish()
end
