if (invincible) exit

if (other.singleHit) {
	instance_destroy(other)
}

invincible = true
call_later(statRecoveryInvincibility, time_source_units_frames, function() {
	invincible = false
})

statStarCounter--

var _directionHit = point_direction(other.x, other.y, x, y)
global.camera.shake.start(
	_directionHit, random_range(shakeStrengthLower, shakeStrengthHigher)
)
controlsDisabled = true
call_cancel(controlsDisabledHandle)
call_later(statRecoveryControls, time_source_units_frames, function(){controlsDisabled = false})
moveDirection = _directionHit
spdCurrent = spd

audio_play_sound(SND_HIT_PLAYER, 0, false, 1, 0, SND_PITCH)

if (statStarCounter == 0) room_restart()

