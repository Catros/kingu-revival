set_controller_object(id, true)

starCounter = 3

spd = 8
spdCurrent = 0
moveVector = 0

invincible = false
invincibleCooldown = 180
invincibleTimeSource = time_source_create(time_source_game, invincibleCooldown, time_source_units_frames, function() {
	invincible = false
	time_source_stop(invincibleTimeSource)
})
