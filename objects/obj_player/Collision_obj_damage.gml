if (invincible) exit

if (other.object_index == obj_projectile) {
	instance_destroy(other)
}

invincible = true
time_source_start(invincibleTimeSource)

starCounter--

var _directionHit = point_direction(other.x, other.y, x, y)
global.camera.shake.start(
	_directionHit, random_range(shakeStrengthLower, shakeStrengthHigher)
)
controlsDisabled = true
time_source_start(controlsDisabledTimeSource)
moveDirection = _directionHit
spdCurrent = spd

audio_play_sound(SND_HIT_PLAYER, 0, false, 1, 0, SND_PITCH)

if (starCounter == 0) room_restart()
