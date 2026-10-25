# fire_smoke

A small Mineclonia mod that periodically emits smoke bursts above:

- mcl_fire:fire
- mcl_fire:eternal_fire

## Installation

1. Place the fire_smoke folder inside Mineclonia's mods directory.
2. Enable fire_smoke for your world.
3. Start the world.

## Dependencies

- mcl_fire
- mcl_campfires

## Current behavior

- Uses an Active Block Modifier (ABM).
- Emits four smoke particles per burst.
- ABM interval: 4 seconds.
- Particle lifetime: 2–3 seconds.
- Does not modify fire ignition, spreading, or extinguishing.
- Does not target campfires.

## Configuration

Particle count, emission position, velocity,
acceleration, lifetime, and size are configurable
inside init.lua.