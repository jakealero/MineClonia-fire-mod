
-- Wind system
-- Generates persistent wind with gradual changes in direction and strength.

local wind = {}

local MIN_SPEED = 0.15
local MAX_SPEED = 1.25

local MIN_CHANGE_INTERVAL = 20
local MAX_CHANGE_INTERVAL = 45

-- How quickly wind approaches its new target.
local DIRECTION_RESPONSE = 12
local SPEED_RESPONSE = 8

local direction = math.random() * math.pi * 2
local speed = MIN_SPEED + math.random() * (MAX_SPEED - MIN_SPEED)

local target_direction = direction
local target_speed = speed

local change_timer = 0
local next_change = 0

local function randomize_wind()
    target_direction = math.random() * math.pi * 2

    target_speed = MIN_SPEED
        + math.random() * (MAX_SPEED - MIN_SPEED)

    next_change = MIN_CHANGE_INTERVAL
        + math.random() * (MAX_CHANGE_INTERVAL - MIN_CHANGE_INTERVAL)

    change_timer = 0
end

local function shortest_angle_difference(from, to)
    return (to - from + math.pi) % (2 * math.pi) - math.pi
end

randomize_wind()

core.register_globalstep(function(dtime)
    change_timer = change_timer + dtime

    if change_timer >= next_change then
        randomize_wind()
    end

    -- Gradually rotate wind direction.
    local direction_alpha = 1 - math.exp(-dtime / DIRECTION_RESPONSE)

    direction = direction + shortest_angle_difference(
        direction,
        target_direction
    ) * direction_alpha

    -- Keep direction within 0 to 2*pi.
    direction = direction % (2 * math.pi)

    -- Gradually adjust wind strength.
    local speed_alpha = 1 - math.exp(-dtime / SPEED_RESPONSE)

    speed = speed + (target_speed - speed) * speed_alpha
end)

function wind.get_velocity()
    return {
        x = math.cos(direction) * speed,
        y = 0,
        z = math.sin(direction) * speed,
    }
end

function wind.get_speed()
    return speed
end

function wind.get_direction()
    return direction
end

function wind.get_max_speed()
    return MAX_SPEED
end

return wind
