if (invincible) exit

if (other.object_index == obj_projectile) {
	instance_destroy(other)
}

invincible = true
time_source_start(invincibleTimeSource)

starCounter--