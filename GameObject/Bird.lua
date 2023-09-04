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

function Bird:isCollide(pipe)
    if (self.x + 2) + (self.width - 4) >= pipe.x and self.x + 2 <= pipe.x + PIPE_WIDTH then
        if (self.y + 2) + (self.height - 4) >= pipe.y and self.y + 2 <= pipe.y + PIPE_HEIGHT then
            return true
        end
    end

    return false
end

function Bird:update(dt)
    -- apply gravity to velocity
    self.deltaY = self.deltaY + GRAVITY * dt

    -- add a sudden burst of negative gravity if we hit space
    if love.keyboard.wasPressed('space') then
        -- jump
        self.deltaY = -0.5
        audios['jump']:play()
    end

    -- apply current velocity to Y position
    self.y = self.y + self.deltaY
end

function Bird:render()
    love.graphics.draw(self.image, self.x, self.y)
end
