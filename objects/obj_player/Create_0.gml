set_controller_instance(id, true, true)

starCounter = 99

spd = 8
spdCurrent = 0
spdAcc = 0.5
moveDirection = 0

invincible = false
invincibleCooldown = 180
invincibleTimeSource = time_source_create(time_source_game, invincibleCooldown, time_source_units_frames, function() {
	invincible = false
	time_source_stop(invincibleTimeSource)
})

controlsDisabled = false
controlsDisabledDuration = 12
controlsDisabledTimeSource = time_source_create(time_source_game, controlsDisabledDuration, time_source_units_frames, function() {
	controlsDisabled = false
	time_source_stop(controlsDisabledTimeSource)
})


move = use_tdmc()

zoneCurrent = undefined

#region ==== ANIMATION ====

shakeStrengthLower = 8
shakeStrengthHigher = 12

#endregion
