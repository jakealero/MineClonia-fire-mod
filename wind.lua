
-- Wind system
-- Generates a persistent random horizontal wind direction and speed.

local wind = {}

local MIN_SPEED = 0.15
local MAX_SPEED = 1.25

local MIN_CHANGE_INTERVAL = 20
local MAX_CHANGE_INTERVAL = 45

local direction = 0
local speed = 0
local change_timer = 0
local next_change = 0

local function randomize_wind()
    -- Random horizontal direction.
    direction = math.random() * math.pi * 2

    -- Random wind speed.
    speed = MIN_SPEED + math.random() * (MAX_SPEED - MIN_SPEED)

    -- Random time until the next wind change.
    next_change = MIN_CHANGE_INTERVAL
        + math.random() * (MAX_CHANGE_INTERVAL - MIN_CHANGE_INTERVAL)

    change_timer = 0
end

-- Generate initial wind.
randomize_wind()

-- Update wind periodically.
core.register_globalstep(function(dtime)
    change_timer = change_timer + dtime

    if change_timer >= next_change then
        randomize_wind()
    end
end)

-- Return the current horizontal wind velocity.
function wind.get_velocity()
    return {
        x = math.cos(direction) * speed,
        y = 0,
        z = math.sin(direction) * speed,
    }
end

-- Return current wind speed.
function wind.get_speed()
    return speed
end

-- Return current wind direction in radians.
function wind.get_direction()
    return direction
end

return wind
