enum foo_type {
	follower, shooter
}

type = debug_type
typeCurrent = foo_type.follower
spd = 1 + random_range(-0.2, 0.2)
spdDirection = 0
follow = true
followRotationSpeed = 3 + random_range(-1, 1)
followTarget = obj_player
shootDistance = 600 + random_range(-50, 50)
shootProjectileSpeed = 16
shootCooldown = 180 + random_range(-20, 20)
shootCooldownCurrent = shootCooldown



