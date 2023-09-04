Bird = Class {}

local GRAVITY = 2

function Bird:init()
    self.image = love.graphics.newImage(TEXTURE_LOC .. 'bird.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.x = VIRTUAL_WIDTH / 2 - (self.width / 2)
    self.y = VIRTUAL_HEIGHT / 2 - (self.height / 2)

    self.deltaY = 0
end

function Bird:update(dt)
    -- apply gravity to velocity
    self.deltaY = self.deltaY + GRAVITY * dt

    -- add a sudden burst of negative gravity if we hit space
    if love.keyboard.wasPressed('space') then
        self.deltaY = -0.5
    end

    -- apply current velocity to Y position
    self.y = self.y + self.deltaY
end

function Bird:render()
    love.graphics.draw(self.image, self.x, self.y)
end
