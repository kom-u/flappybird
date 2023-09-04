_G.love = require("love")

-- assets location
ASSET_LOC = 'assets/'
AUDIO_LOC = ASSET_LOC .. 'audios/'
FONT_LOC = ASSET_LOC .. 'fonts/'
TEXTURE_LOC = ASSET_LOC .. 'textures/'

-- packages
-- push https://github.com/Ulydev/push
local push = require '_packages.push'
-- class
Class = require '_packages.class'

require 'GameObject.Bird'
require 'GameObject.Pipe'
require 'GameObject.PipePair'

require 'State.StateMachine'
require 'State.BaseState'
require 'State.CountdownState'
require 'State.PlayState'
require 'State.TitleScreenState'
require 'State.ScoreState'

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
-- local scrolling = true



function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Flappy Bird')

    -- init fonts
    _G.smallFont = love.graphics.newFont(FONT_LOC .. 'font.ttf', 8)
    _G.mediumFont = love.graphics.newFont(FONT_LOC .. 'flappy.ttf', 14)
    _G.flappyFont = love.graphics.newFont(FONT_LOC .. 'flappy.ttf', 28)
    _G.hugeFont = love.graphics.newFont(FONT_LOC .. 'flappy.ttf', 56)
    love.graphics.setFont(flappyFont)

    -- init audios
    _G.audios = {
        ['jump'] = love.audio.newSource(AUDIO_LOC .. 'jump.wav', 'static'),
        ['explosion'] = love.audio.newSource(AUDIO_LOC .. 'explosion.wav', 'static'),
        ['hurt'] = love.audio.newSource(AUDIO_LOC .. 'hurt.wav', 'static'),
        ['score'] = love.audio.newSource(AUDIO_LOC .. 'score.wav', 'static'),

        -- https://freesound.org/people/xsgianni/sounds/388079/
        ['music'] = love.audio.newSource(AUDIO_LOC .. 'marios_way.mp3', 'static')
    }

    -- play bgm audio
    audios['music']:setLooping(true)
    audios['music']:play()

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- init state machine
    _G.gStateMachine = StateMachine {
        ['title'] = function()
            return TitleScreenState()
        end,
        ['countdown'] = function()
            return CountdownState()
        end,
        ['play'] = function()
            return PlayState()
        end,
        ['score'] = function()
            return ScoreState
        end
    }
    gStateMachine:change('title')

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
    -- update background and ground scroll offsets
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) %
        BACKGROUND_LOOPING_POINT
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % GROUND_LOOPING_POINT

    -- now, we just update the state machine, which defers to the right state
    gStateMachine:update(dt)

    -- reset input table every frame
    love.keyboard.keyPressed = {}
end

function love.draw()
    push:start()

    -- layer 0
    love.graphics.draw(backgroundTexture, -backgroundScroll, 0)

    -- layer 1
    gStateMachine:render()

    -- layer 2
    love.graphics.draw(groundTexture, -groundScroll, VIRTUAL_HEIGHT - 16)



    push:finish()
end
