var _count = 0
var _angle = 360 / statStarCounter
while (_count < statStarCounter) {
	draw_sprite_ext(spr_starBranch, 0, x, y, 1, 1, 90 + _angle * _count, c_white, 0.5)
	_count++
}


if (invincible) {
	draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, image_angle, c_red, 1)
} else {
	draw_self()
}

draw_circle_colour(x, y, statCriticalZone, c_white, c_white, true)

draw_stat_circle(
	dodgeCooldownCurrent,
	statDodgeCooldown,
	x, y, 32, 3, 255
)