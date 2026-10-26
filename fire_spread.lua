-- Wind-driven supplementary fire spread.
-- Does not replace Mineclonia's original fire-spread ABM.

local FIRE_NODES = {
    ["mcl_fire:fire"] = true,
    ["mcl_fire:eternal_fire"] = true,
}

local BASE_SPREAD_CHANCE = 36
local MAX_WIND_MULTIPLIER = 2
local MAX_WIND_SPEED = 0.40

local SEARCH_MIN = {x = -1, y = -1, z = -1}
local SEARCH_MAX = {x =  1, y =  4, z =  1}

local function get_wind()
    local wind = fire_smoke_wind

    if not wind then
        return vector.new(0, 0, 0), 0
    end

    local velocity = wind.get_velocity()
    local speed = wind.get_speed()

    return velocity, math.min(speed / MAX_WIND_SPEED, 1)
end

local function has_flammable(pos)
    local adjacent = {
        {x = -1, y =  0, z =  0},
        {x =  1, y =  0, z =  0},
        {x =  0, y = -1, z =  0},
        {x =  0, y =  1, z =  0},
        {x =  0, y =  0, z = -1},
        {x =  0, y =  0, z =  1},
    }

    for _, offset in ipairs(adjacent) do
        local p = vector.add(pos, offset)
        local node = core.get_node_or_nil(p)

        if node and core.get_item_group(node.name, "flammable") > 0 then
            return true
        end
    end

    return false
end

local function get_wind_weighted_ignition(pos, wind_velocity)
    local p1 = vector.add(pos, SEARCH_MIN)
    local p2 = vector.add(pos, SEARCH_MAX)

    local candidates = core.find_nodes_in_area(p1, p2, {"air"})
    local weighted_candidates = {}
    local total_weight = 0

    for _, candidate in ipairs(candidates) do
        if has_flammable(candidate) then
            local dx = candidate.x - pos.x
            local dz = candidate.z - pos.z

            local distance = math.sqrt(dx * dx + dz * dz)
            local alignment = 0

            if distance > 0 then
                alignment = (
                    dx * wind_velocity.x +
                    dz * wind_velocity.z
                ) / (distance * MAX_WIND_SPEED)
            end

            alignment = math.max(0, math.min(alignment, 1))

            local weight = 1 + alignment * 4

            total_weight = total_weight + weight

            weighted_candidates[#weighted_candidates + 1] = {
                pos = candidate,
                weight = weight,
            }
        end
    end

    if total_weight == 0 then
        return nil
    end

    local selection = math.random() * total_weight

    for _, candidate in ipairs(weighted_candidates) do
        selection = selection - candidate.weight

        if selection <= 0 then
            return candidate.pos
        end
    end

    return nil
end

core.register_abm({
    label = "Wind-driven fire spread",

    nodenames = {
        "mcl_fire:fire",
        "mcl_fire:eternal_fire",
    },

    interval = 7,
    chance = 1,
    catch_up = false,

    action = function(pos)
        local wind_velocity, wind_strength = get_wind()

        local multiplier = 1 +
            (MAX_WIND_MULTIPLIER - 1) * wind_strength

        local probability = multiplier / BASE_SPREAD_CHANCE

        if math.random() >= probability then
            return
        end

        local target = get_wind_weighted_ignition(
            pos,
            wind_velocity
        )

        if target then
            core.set_node(target, {name = "mcl_fire:fire"})
            core.check_single_for_falling({
                x = target.x,
                y = target.y + 1,
                z = target.z,
            })
        end
    end,
})