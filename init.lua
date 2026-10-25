
-- fire_smoke
-- Generates intermittent smoke bursts above Mineclonia fire nodes.
-- Removes tracked particle spawners when their fire disappears.

local FIRE_NODES = {
    ["mcl_fire:fire"] = true,
    ["mcl_fire:eternal_fire"] = true,
}

local active_smoke = {}

local CLEANUP_INTERVAL = 1
local cleanup_timer = 0

local function is_fire(pos)
    local node = core.get_node_or_nil(pos)

    -- An unloaded position is not necessarily an extinguished fire.
    if not node then
        return nil
    end

    return FIRE_NODES[node.name] == true
end

local function stop_smoke(hash)
    local smoke = active_smoke[hash]

    if not smoke then
        return
    end

    if smoke.id then
        core.delete_particlespawner(smoke.id)
    end

    active_smoke[hash] = nil
end

local function spawn_smoke_burst(pos)
    local hash = core.hash_node_position(pos)

    -- Avoid leaving an older spawner behind at this position.
    stop_smoke(hash)

    local id = core.add_particlespawner({
        amount = 4,
        time = 0,

        -- Emission area above the fire
        minpos = vector.offset(pos, -0.10, 0.25, -0.10),
        maxpos = vector.offset(pos,  0.10, 0.35,  0.10),

        -- Mostly upward movement
        minvel = vector.new(-0.04, 0.65, -0.04),
        maxvel = vector.new( 0.04, 1.25,  0.04),

        -- Slight upward acceleration
        minacc = vector.new(-0.02, 0.10, -0.02),
        maxacc = vector.new( 0.02, 0.20,  0.02),

        minexptime = 1.0,
        maxexptime = 7.5,

        minsize = 5.5,
        maxsize = 14.0,

        collisiondetection = false,

        texpool = {
            {
                name = "mcl_campfires_particle_1.png",
                scale = 1,
                alpha_tween = {1, 0}
            },
            {
                name = "mcl_campfires_particle_2.png",
                scale = 1,
                alpha_tween = {1, 0}
            },
            {
                name = "mcl_campfires_particle_3.png",
                scale = 1,
                alpha_tween = {1, 0}
            },
            {
                name = "mcl_campfires_particle_4.png",
                scale = 1,
                alpha_tween = {1, 0}
            },
        },
    })

    active_smoke[hash] = {
        id = id,
        pos = vector.copy(pos),
    }
end

-- Generate smoke periodically above fire nodes.
core.register_abm({
    label = "Fire smoke burst",
    nodenames = {
        "mcl_fire:fire",
        "mcl_fire:eternal_fire",
    },
    interval = 5,
    chance = 1,
    action = spawn_smoke_burst,
})

-- Periodically remove spawners whose fire has disappeared.
core.register_globalstep(function(dtime)
    cleanup_timer = cleanup_timer + dtime

    if cleanup_timer < CLEANUP_INTERVAL then
        return
    end

    cleanup_timer = 0

    for hash, smoke in pairs(active_smoke) do
        local fire_exists = is_fire(smoke.pos)

        if fire_exists == false then
            stop_smoke(hash)
        end
    end
end)
