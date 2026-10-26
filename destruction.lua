-- Structural destruction
-- Destroys nonflammable solid blocks directly adjacent to active fire.

local FIRE_NODES = {
    ["mcl_fire:fire"] = true,
    ["mcl_fire:eternal_fire"] = true,
}

local ADJACENTS = {
    -- Horizontal sides
    {x = -1, y = 0, z =  0},
    {x =  1, y = 0, z =  0},
    {x =  0, y = 0, z = -1},
    {x =  0, y = 0, z =  1},

    -- Above
    {x = 0, y = 1, z = 0},
}

local function is_destructible(pos)
    local node = core.get_node_or_nil(pos)


    -- Exclude grass blocks.
    if node.name == "mcl_core:dirt_with_grass" then
        return false
    end

    -- Do not interact with unloaded positions.
    if not node then
        return false
    end

    -- Explicitly exclude fire.
    if FIRE_NODES[node.name] then
        return false
    end

    -- Exclude air and other nonflammable blocks handled by the base fire system.
    if node.name == "air"
        or core.get_item_group(node.name, "flammable") ~= 0 then
        return false
    end

    local def = core.registered_nodes[node.name]

    if not def then
        return false
    end

    -- Only destroy solid, non-liquid nodes.
    if not def.walkable or def.liquidtype ~= "none" then
        return false
    end

    return true
end

local function destroy_adjacent_block(fire_pos)
    local candidates = {}

    -- Collect directly adjacent eligible blocks.
    for _, offset in ipairs(ADJACENTS) do
        local pos = vector.add(fire_pos, offset)

        if is_destructible(pos) then
            candidates[#candidates + 1] = pos
        end
    end

    -- Nothing eligible to destroy.
    if #candidates == 0 then
        return
    end

    -- Destroy one randomly selected block.
    local target = candidates[math.random(#candidates)]

    core.remove_node(target)

    -- Allow falling nodes above the removed block to fall.
    core.check_for_falling(target)
end

core.register_abm({
    label = "Fire structural destruction",

    nodenames = {
        "mcl_fire:fire",
        "mcl_fire:eternal_fire",
    },

    interval = 5,
    chance = 8,
    catch_up = false,

    action = destroy_adjacent_block,
})