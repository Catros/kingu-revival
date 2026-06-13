if (invincible) exit

if (other.singleHit) {
	instance_destroy(other)
}

invincible = true
time_source_start(invincibleTimeSource)

statStarCounter--

var _directionHit = point_direction(other.x, other.y, x, y)
global.camera.shake.start(
	_directionHit, random_range(shakeStrengthLower, shakeStrengthHigher)
)
controlsDisabled = true
controlsDisabledDuration = controlsDisabledDurationHit
time_source_start(controlsDisabledTimeSource)
moveDirection = _directionHit
spdCurrent = spd

audio_play_sound(SND_HIT_PLAYER, 0, false, 1, 0, SND_PITCH)

if (statStarCounter == 0) room_restart()

