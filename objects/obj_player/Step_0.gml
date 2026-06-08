if (global.controller != id) exit

var _inputX = InputCheck(INPUT_VERB.RIGHT) - InputCheck(INPUT_VERB.LEFT)
var _inputY = InputCheck(INPUT_VERB.DOWN) - InputCheck(INPUT_VERB.UP)
moveVector = point_direction(0, 0, _inputX, _inputY)
spdCurrent = 0

if (_inputX != 0 || _inputY != 0) {
	move_and_collide(lengthdir_x(spd, moveVector), lengthdir_y(spd, moveVector), obj_collision)
	spdCurrent = spd
}
