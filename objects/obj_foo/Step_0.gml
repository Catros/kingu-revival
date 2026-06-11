switch (typeCurrent) {
	
	case FOO_TYPE.FOLLOWER: {
		
		move_and_collide(
			lengthdir_x(spd, spdDirection),
			lengthdir_y(spd, spdDirection),
			obj_foo
		)
		turn_to_target()
	}
	break
	
	case FOO_TYPE.SHOOTER: {
		shootCooldownCurrent--
		turn_to_target()
		
		if (shootCooldownCurrent <= 0) {
			var _projectile = instance_create_depth(x, y, depth, obj_projectile)
			_projectile.speed = shootProjectileSpeed
			_projectile.direction = get_target_aim(target, x, y, shootProjectileSpeed)
			shootCooldownCurrent = shootCooldown
			audio_play_sound(SND_SHT_SHOOTER, 0, false, 1, 0, SND_PITCH)
		}
	}
	break
	
	case FOO_TYPE.CHARGER: {
		chargeCooldownCurrent--
		turn_to_target()
		
		if (chargeCooldownCurrent <= 0) {
			if (chargeTarget == noone) {
				chargeTarget = {
					x: x + lengthdir_x(chargeDistance * chargeDistanceMultiplier, spdDirection),
					y: y + lengthdir_y(chargeDistance * chargeDistanceMultiplier, spdDirection)
				}
				audio_play_sound(SND_MOVE_CHARGER, 0, false, 1, 0, SND_PITCH)
			}
			x = lerp(x, chargeTarget.x, chargeLerp)
			y = lerp(y, chargeTarget.y, chargeLerp)
			
			if (abs(x - chargeTarget.x) < chargeLerpTreshold && abs(y - chargeTarget.y) < chargeLerpTreshold) {
				chargeCooldownCurrent = chargeCooldown
				chargeTarget = noone
			}
		}
	}
	break
	
}

switch (type) {
	
	case FOO_TYPE.SHOOTER: {
		if (distance_to_target() > shootDistance) {
			typeCurrent = FOO_TYPE.FOLLOWER
			shootCooldownCurrent = shootCooldown
		} else {
			typeCurrent = FOO_TYPE.SHOOTER
		}
	}
	break
	
	case FOO_TYPE.CHARGER: {
		if (distance_to_target() > chargeDistance && chargeTarget == noone) {
			typeCurrent = FOO_TYPE.FOLLOWER
			chargeCooldownCurrent = chargeCooldown
		} else {
			typeCurrent = FOO_TYPE.CHARGER
		}
	}
	break
	
}