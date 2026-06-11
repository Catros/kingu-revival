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
chargeDistanceMultiplier = 2
chargeCooldown = 120
chargeCooldownCurrent = chargeCooldown
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

#endregion

