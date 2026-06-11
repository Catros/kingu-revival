enum FOO_TYPE {
	FOLLOWER, SHOOTER, CHARGER
}

type = debug_type
typeCurrent = FOO_TYPE.FOLLOWER
spd = 3 + random_range(-0.2, 0.2)
spdDirection = 0

targetFollow = true
targetRotationSpeed = 3 + random_range(-1, 1)
target = obj_player

shootDistance = 600 + random_range(-50, 50)
shootProjectileSpeed = 16
shootCooldown = 180 + random_range(-20, 20)
shootCooldownCurrent = shootCooldown

chargeDistance = 500 + random_range(-50, 50)
chargeDistanceMultiplier = 1.75
chargeCooldown = 120
chargeCooldownCurrent = chargeCooldown
chargeGraceTime = 20
chargeTarget = noone
chargeLerp = 0.1
chargeLerpTreshold = 5

#region ==== FUNCTIONS ====

distance_to_target = function() {
	return point_distance(x, y, target.x, target.y)
}

direction_to_target = function() {
	return point_direction(x, y, target.x, target.y)
}

turn_to_target = function() {
	var _targetDirection = direction_to_target()
	spdDirection += clamp(
		angle_difference(_targetDirection, spdDirection),
		-targetRotationSpeed,
		targetRotationSpeed
	);
}

foo_separate = function() {
    var _others = ds_list_create()
    instance_place_list(x, y, obj_foo, _others, false)
    
    var _count = ds_list_size(_others)
    if (_count == 0) {
        ds_list_destroy(_others)
        return
    }
    
    // Calculate centroid of all overlapping instances (including self)
    var _mean_x = x
    var _mean_y = y
    
    for (var _i = 0; _i < _count; _i++) {
        var _other = _others[| _i]
        if (_other == id) continue
        _mean_x += _other.x
        _mean_y += _other.y
    }
    
    _mean_x /= (_count + 1) // +1 to include self
    _mean_y /= (_count + 1)
    
    // Push self away from centroid
    var _dist = point_distance(_mean_x, _mean_y, x, y)
    if (_dist == 0) {
        x += lengthdir_x(1, irandom(359))
        y += lengthdir_y(1, irandom(359))
    } else {
        var _angle = point_direction(_mean_x, _mean_y, x, y)
        x += lengthdir_x(1, _angle) // nudge of 1px per step, very soft
        y += lengthdir_y(1, _angle)
    }
    
    ds_list_destroy(_others)
}

#endregion

