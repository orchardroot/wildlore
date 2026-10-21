# Deep Places kit

A zone's `"deep"` block (rules in `core/deep_place.gd`, overworld side in `world/deep_scene.gd`):

- `levers`: `{id, x, y, needs_light?, on?, off?, find?: {item, n}}`. Face and confirm to toggle (flag `dp_<zone>_<id>`). `needs_light` levers only work with the Lantern in a dark zone. `find` is given once.
- `gates`: `{x, y, by: ["lever:a", "!lever:b", "plate:p"], line}`. Write the tile as walkable in `rows`; closed gates are drawn as fence.
- `plates` `{id, x, y, weight: "crate"|"any"}` latch for good; `crates` `{id, x, y}` are pushed by walking into them and reset when you re-enter.
- `floods`: `{id, by, tiles: [[x, y]]}`; write the tiles as `w` (shallow) in `rows`; they are deep water until `by` holds.

Validator: ids unique, in bounds, every warp, lever and plate reachable with all gates open. Reference: `blue_john_*` (Castleton, via Buxton's south path).
