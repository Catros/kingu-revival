function sh_mute() {
	audio_group_set_gain(audiogroup_effect, 0)
	audio_group_set_gain(audiogroup_music, 0)
	return "Sound muted"
}

function sh_get(args) {
	var _var_name = args[1]

	if (variable_global_exists(_var_name)) {
		return _var_name + " (global) = " + string(variable_global_get(_var_name))
	} else if (variable_instance_exists(self, _var_name)) {
		return _var_name + " = " + string(variable_instance_get(self, _var_name))
	} else {
		return "Variable '" + _var_name + "' not found"
	}
}

function meta_get() {
	return {
		description: "reads and outputs the value of a variable",
		arguments: ["variable_name"],
		suggestions: [[]],
		argumentDescriptions: [
			"the name of the global or instance variable to read"
		],
		hidden: false,
		deferred: false
	}
}

function sh_get_obj(args) {
	var _target_str = args[1]
	var _var_name = args[2]
	var _target = asset_get_index(_target_str)

	if (_target == -1) {
		// not an object name, try as instance id
		_target = real(_target_str)
	} else {
		// it's an object, find first active instance
		_target = instance_find(_target, 0)
		if (_target == noone) {
			return "No active instance of '" + _target_str + "' found"
		}
	}

	if (!instance_exists(_target)) {
		return "Instance " + _target_str + " does not exist"
	}

	if (variable_instance_exists(_target, _var_name)) {
		return _target_str + "." + _var_name + " = " + string(variable_instance_get(_target, _var_name))
	} else {
		return "Variable '" + _var_name + "' not found on " + _target_str
	}
}

function meta_get_obj() {
	return {
		description: "reads a variable from an object's first instance, or from a specific instance id",
		arguments: ["object_or_instance", "variable_name"],
		suggestions: [
			[],
			[]
		],
		argumentDescriptions: [
			"an object name (e.g. obj_player) or instance id",
			"the name of the variable to read"
		],
		hidden: false,
		deferred: false
	}
}

function sh_set(args) {
	var _var_name = args[1]
	var _value_str = args[2]
	var _value

	if (_value_str == "true") {
		_value = true
	} else if (_value_str == "false") {
		_value = false
	} else if (string_digits(_value_str) == string_replace_all(_value_str, ".", "") && _value_str != "") {
		_value = real(_value_str)
	} else {
		_value = _value_str
	}

	if (variable_global_exists(_var_name)) {
		variable_global_set(_var_name, _value)
		return _var_name + " (global) = " + string(_value)
	} else {
		variable_instance_set(self, _var_name, _value)
		return _var_name + " = " + string(_value)
	}
}

function meta_set() {
	return {
		description: "sets a global or shell-instance variable to a value",
		arguments: ["variable_name", "value"],
		suggestions: [[], []],
		argumentDescriptions: [
			"the name of the global variable to set (creates an instance var on the shell if not global)",
			"the value to assign (numbers and true/false are auto-converted)"
		],
		hidden: false,
		deferred: false
	}
}

function sh_set_obj(args) {
	var _target_str = args[1]
	var _var_name = args[2]
	var _value_str = args[3]
	var _value
	var _target = asset_get_index(_target_str)

	if (_target == -1) {
		// not an object name, try as instance id
		_target = real(_target_str)
	} else {
		// it's an object, find first active instance
		_target = instance_find(_target, 0)
		if (_target == noone) {
			return "No active instance of '" + _target_str + "' found"
		}
	}

	if (!instance_exists(_target)) {
		return "Instance " + _target_str + " does not exist"
	}

	if (_value_str == "true") {
		_value = true
	} else if (_value_str == "false") {
		_value = false
	} else if (string_digits(_value_str) == string_replace_all(_value_str, ".", "") && _value_str != "") {
		_value = real(_value_str)
	} else {
		_value = _value_str
	}

	variable_instance_set(_target, _var_name, _value)

	return _target_str + "." + _var_name + " = " + string(_value)
}

function meta_set_obj() {
	return {
		description: "sets a variable on an object's first instance, or on a specific instance id",
		arguments: ["object_or_instance", "variable_name", "value"],
		suggestions: [
			[],
			[],
			[]
		],
		argumentDescriptions: [
			"an object name (e.g. obj_player) or instance id",
			"the name of the variable to set",
			"the value to assign (numbers and true/false are auto-converted)"
		],
		hidden: false,
		deferred: false
	}
}

function sh_goto(args) {
	var _x = real(args[1])
	var _y = real(args[2])

	if (!instance_exists(obj_player)) {
		return "No obj_player instance found"
	}

	obj_player.x = _x
	obj_player.y = _y

	return "Moved player to " + string(_x) + ", " + string(_y)
}

function meta_goto() {
	return {
		description: "teleports the player to the given coordinates",
		arguments: ["x", "y"],
		suggestions: [
			mouseArgumentType.worldX,
			mouseArgumentType.worldY
		],
		argumentDescriptions: [
			"the X coordinate to move the player to",
			"the Y coordinate to move the player to"
		],
		hidden: false,
		deferred: false
	}
}

function sh_spawn(args) {
	var _obj_str = args[1]
	var _x = real(args[2])
	var _y = real(args[3])
	var _obj = asset_get_index(_obj_str)

	if (_obj == -1 || !object_exists(_obj)) {
		return "Object '" + _obj_str + "' does not exist"
	}

	var _inst = instance_create_layer(_x, _y, "Instances", _obj)

	return "Spawned " + _obj_str + " (" + string(real(_inst)) + ") at " + string(_x) + ", " + string(_y)
}

function meta_spawn() {
	return {
		description: "spawns an instance of an object at the given coordinates",
		arguments: ["object", "x", "y"],
		suggestions: [
			[],
			mouseArgumentType.worldX,
			mouseArgumentType.worldY
		],
		argumentDescriptions: [
			"the name of the object to spawn (e.g. obj_enemy)",
			"the X coordinate to spawn at",
			"the Y coordinate to spawn at"
		],
		hidden: false,
		deferred: false
	}
}

function sh_warp(args) {
	var _room_str = args[1]
	var _room = asset_get_index(_room_str)

	if (_room == -1 || !room_exists(_room)) {
		return "Room '" + _room_str + "' does not exist"
	}

	room_goto(_room)

	return "Warping to " + _room_str
}

function meta_warp() {
	return {
		description: "changes to the specified room",
		arguments: ["room"],
		suggestions: [[]],
		argumentDescriptions: [
			"the name of the room to warp to"
		],
		hidden: false,
		deferred: false
	}
}

function sh_list(args) {
	var _obj_str = args[1]
	var _obj = asset_get_index(_obj_str)

	if (_obj == -1 || !object_exists(_obj)) {
		return "Object '" + _obj_str + "' does not exist"
	}

	var _count = instance_number(_obj)

	if (_count == 0) {
		return "No active instances of " + _obj_str
	}

	var _result = string(_count) + " instance(s) of " + _obj_str + ":"

	for (var i = 0; i < _count; i++) {
		var _inst = instance_find(_obj, i)
		_result += "\n  " + string(real(_inst)) + " @ (" + string(_inst.x) + ", " + string(_inst.y) + ")"
	}

	return _result
}

function meta_list() {
	return {
		description: "lists all active instances of an object with their ids and positions",
		arguments: ["object"],
		suggestions: [[]],
		argumentDescriptions: [
			"the name of the object to list instances of"
		],
		hidden: false,
		deferred: false
	}
}

function sh_speed(args) {
	if (array_length(args) < 2) {
		return "Current game speed: " + string(game_get_speed(gamespeed_fps))
	}

	var _scale = real(args[1])

	if (_scale <= 0) {
		return "Speed must be greater than 0"
	}

	game_set_speed(60 * _scale, gamespeed_fps)

	return "Game speed set to " + string(_scale) + "x"
}

function meta_speed() {
	return {
		description: "sets the game speed as a multiplier of normal speed, or shows the current speed if no argument given",
		arguments: ["multiplier"],
		suggestions: [[]],
		argumentDescriptions: [
			"speed multiplier (e.g. 1 = normal, 0.5 = half speed, 2 = double speed)"
		],
		hidden: false,
		deferred: false
	}
}

