var _count = 0
var _angle = 360 / statStarCounter
while (_count < statStarCounter) {
	draw_sprite_ext(spr_starBranch, 0, 32, 32, 0.5, 0.5, 90 + _angle * _count, c_white, 0.5)
	_count++
}