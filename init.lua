
-- fire_smoke
-- Generates intermittent smoke bursts above Mineclonia fire nodes.
-- Removes tracked particle spawners when their fire disappears.

local modpath = core.get_modpath(core.get_current_modname())

local wind = dofile(modpath .. "/wind.lua")
fire_smoke_wind = wind

dofile(modpath .. "/destruction.lua")
dofile(modpath .. "/fire_spread.lua")

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

local function spawn_smoke_burst(pos,size,life_time)
    local hash = core.hash_node_position(pos)
    local wind_velocity = wind.get_velocity()

    -- Avoid leaving an older spawner behind at this position.
    stop_smoke(hash)

    local id = core.add_particlespawner({
        amount = 2,
        time = 0,

        -- Emission area above the fire
        minpos = vector.offset(pos, -0.10, 0.25, -0.10),
        maxpos = vector.offset(pos,  0.10, 0.35,  0.10),

        -- Mostly upward movement with wind_velocity
        minvel = vector.new(
            wind_velocity.x - 0.04,
            0.75,
            wind_velocity.z - 0.04
        ),

        maxvel = vector.new(
            wind_velocity.x + 0.04,
            1.35,
            wind_velocity.z + 0.04
        ),

        -- Slight upward acceleration
        minacc = vector.new(-0.02, 0.10, -0.02),
        maxacc = vector.new( 0.02, 0.20,  0.02),

        minexptime = life_time.min,
        maxexptime = life_time.max,

        minsize = size.min,
        maxsize = size.max,

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

local function spawn_small_smoke(pos)
    spawn_smoke_burst(pos,{min = 5.5, max = 17.0},{min = 1, max = 12.0})
end

-- Generate smoke periodically above fire nodes.
core.register_abm({
    label = "Fire smoke burst",
    nodenames = {
        "mcl_fire:fire",
        "mcl_fire:eternal_fire",
    },
    interval = 5,
    chance = 6,
    action = spawn_small_smoke,
})

--Spawns Bigger Smoke

local ADJACENTS = {
    -- Horizontal sides
    {x = -1, y = 0, z =  0},
    {x =  1, y = 0, z =  0},
    {x =  0, y = 0, z = -1},
    {x =  0, y = 0, z =  1},

    -- Above
    {x = 0, y = 1, z = 0},
}

local function do_check_and_spawn(fire_pos)
    local fire_size = 0;

    -- Collect directly adjacent eligible blocks.
    for _, offset in ipairs(ADJACENTS) do
        local pos = vector.add(fire_pos, offset)

        if is_fire(pos) then
            fire_size = fire_size + 1
        end
    end

    -- Nothing eligible to destroy.
    if fire_size == 0 then
        return
    end

    if fire_size >= 4 then
        spawn_smoke_burst(fire_pos,{min = 30, max = 65},{min = 10, max = 17.0})
    end

end

core.register_abm({
    label = "Bigger Less Frequent Smoke",

    nodenames = {
        "mcl_fire:fire",
        "mcl_fire:eternal_fire",
    },

    interval = 5,
    chance = 16,
    catch_up = false,

    action = do_check_and_spawn,
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


