extends Node
## Autoload Bus: global signals so systems can react without knowing each other.

signal zone_entered(zone_id: String)
signal battle_started(kind: String)
signal battle_ended(result: Dictionary)
signal flag_changed(key: String, value: Variant)
signal creature_caught(species_id: String)
signal message(text: String)
signal settings_changed()
