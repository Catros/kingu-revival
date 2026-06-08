switch (typeCurrent) {
	
	case foo_type.follower: {
		
		move_and_collide(
			lengthdir_x(spd, spdDirection),
			lengthdir_y(spd, spdDirection),
			obj_foo
		)
		
		if (follow) {
			var _targetDirection = point_direction(x, y, followTarget.x, followTarget.y);
		    spdDirection += clamp(
		        angle_difference(_targetDirection, spdDirection),
		        -followRotationSpeed,
		        followRotationSpeed
		    );
		}
		
	}
	break
	
	case foo_type.shooter: {
		shootCooldownCurrent -= 1
		var _targetDirection = point_direction(x, y, followTarget.x, followTarget.y);
		spdDirection += clamp(
		    angle_difference(_targetDirection, spdDirection),
		    -followRotationSpeed,
		    followRotationSpeed
		);
		if (shootCooldownCurrent <= 0) {
			var _projectile = instance_create_depth(x, y, depth, obj_projectile)
			_projectile.speed = shootProjectileSpeed
			_projectile.direction = get_target_aim(followTarget, x, y, shootProjectileSpeed)
			shootCooldownCurrent = shootCooldown
		}
	}
	
}

switch (type) {
	
	case foo_type.shooter: {
		if (point_distance(x, y, followTarget.x, followTarget.y) > shootDistance) {
			typeCurrent = foo_type.follower
			shootCooldownCurrent = shootCooldown
		} else {
			typeCurrent = foo_type.shooter
		}
	}
	break
	
}