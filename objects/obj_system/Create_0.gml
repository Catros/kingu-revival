randomise()
draw_set_circle_precision(64)

global.controller = noone
global.system = id
global.camera = instance_create(obj_camera)
global.console = instance_create(obj_shell)

audio_group_load(audiogroup_music)
audio_group_load(audiogroup_effect)

jukebox_change_settings(0.2)
audio_group_set_gain(audiogroup_effect, 0.5)

locale = "fr"
global.translations = json_parse(file_get_content(working_directory + "locales/" + locale + ".json"))

#region ===== FUNCTIONS =====

randomize_tiles = function() {
	// === CONFIGURATION ===
	var _layer_name = "Ground"          // your tile layer name
	var _tileset    = tile_placeholder    // your tileset asset

	// Tile indices that are eligible to be randomized
	var _eligible = [1]

	// Pool of tile indices to randomly pick from (can overlap with eligible)
	var _variants  = []
	var _ind = 0
	repeat (31) {
		_variants[_ind] = _ind + 1
		_ind++
	}

	// === SETUP ===
	var _tilemap = layer_tilemap_get_id(layer_get_id(_layer_name))
	var _tw      = tilemap_get_tile_width(_tilemap)
	var _th      = tilemap_get_tile_height(_tilemap)
	var _cols    = tilemap_get_width(_tilemap)
	var _rows    = tilemap_get_height(_tilemap)

	var _eligible_count = array_length(_eligible)
	var _variant_count  = array_length(_variants)

	// === RANDOMIZE ===
	for (var _y = 0; _y < _rows; _y++) {
	    for (var _x = 0; _x < _cols; _x++) {
        
	        var _data  = tilemap_get(_tilemap, _x, _y)
	        var _index = tile_get_index(_data)
        
	        // Check if this tile is eligible
	        var _is_eligible = false
	        for (var _i = 0; _i < _eligible_count; _i++) {
	            if (_index == _eligible[_i]) {
	                _is_eligible = true
	                break
	            }
	        }
        
	        if (!_is_eligible) continue
        
	        // Pick a random variant
	        var _new_index = _variants[irandom(_variant_count - 1)]
        
	        // Random horizontal flip
	        var _flip_h = (irandom(1) == 1)
        
	        // Build new tile data and apply
	        var _new_data = tile_set_index(_data, _new_index)
	        _new_data     = tile_set_mirror(_new_data, _flip_h)
	        tilemap_set(_tilemap, _new_data, _x, _y)
	    }
	}
}

#endregion
