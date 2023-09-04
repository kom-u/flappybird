PlayState = Class { __includes = BaseState }

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 2
    self.score = 0

    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:update(dt)
    -- update timer for pipe spawning
    self.timer = self.timer + dt

    -- spawn a new pipe pair every second and a half
    if self.timer > 3 then
        -- modify the last Y coordinate we placed so pipe gaps aren't too far apart no higher than 10 pixels below the top edge of the screen, and no lower than a gap length (90 pixels) from the bottom
        local y = math.max(-PIPE_HEIGHT + 10,
            math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
        self.lastY = y

        -- add a new pipe pair at the end of the screen at our new Y
        table.insert(self.pipePairs, PipePair(y))

        -- reset timer
        self.timer = 0
    end

    -- for every pair of pipes..
    for k, pipePair in pairs(self.pipePairs) do
        -- check if scored or not
        if not pipePair.scored then
            if pipePair.x + PIPE_WIDTH < self.bird.x then
                -- scored
                self.score = self.score + 1
                pipePair.scored = true
                audios['score']:play()
            end
        end

        -- update position of pair
        pipePair:update(dt)
    end

    -- we need this second loop, rather than deleting in the previous loop, because modifying the table in-place without explicit keys will result in skipping the next pipe, since all implicit keys (numerical indices) are automatically shifted down after a table removal
    for k, pipePair in pairs(self.pipePairs) do
        if pipePair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    -- update bird based on gravity and input
    self.bird:update(dt)

    -- simple collision between bird and all pipes in pairs
    for k, pipePair in pairs(self.pipePairs) do
        for l, pipe in pairs(pipePair.pipes) do
            if self.bird:isCollide(pipe) then
                -- hit
                audios['explosion']:play()
                audios['hurt']:play()

                gStateMachine:change('score', {
                    score = self.score
                })
            end
        end
    end

    -- reset if we get to the ground
    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        -- hit
        audios['explosion']:play()
        audios['hurt']:play()

        gStateMachine:change('score', {
            score = self.score
        })
    end
end

function PlayState:render()
    for k, pipePair in pairs(self.pipePairs) do
        pipePair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()
end
