
if (invincible) {
	draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, image_angle, c_red, 1)
} else {
	draw_self()
}

draw_circle_colour(x, y, statCriticalZone, c_white, c_white, true)

if (dodgeCooldownCurrent != 0) {
	draw_stat_circle(
		statDodgeCooldown - dodgeCooldownCurrent,
		statDodgeCooldown,
		x, y, 32, 7, 100
	)
}