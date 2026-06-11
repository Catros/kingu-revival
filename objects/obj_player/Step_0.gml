move.spdDir(spdCurrent, moveDirection)

if (global.controller != id || controlsDisabled) exit

var _inputX = InputValue(INPUT_VERB.RIGHT) - InputValue(INPUT_VERB.LEFT)
var _inputY = InputValue(INPUT_VERB.DOWN) - InputValue(INPUT_VERB.UP)

if (_inputX != 0 || _inputY != 0) {
	spdCurrent = lerp(spdCurrent, spd * min(abs(_inputX) + abs(_inputY), 1), spdAcc)
	moveDirection = InputDirection(0, INPUT_CLUSTER.NAVIGATION)
} else if (spdCurrent != 0) {
	spdCurrent = lerp(spdCurrent, 0, spdAcc)
}

