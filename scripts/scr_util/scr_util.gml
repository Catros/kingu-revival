function set_controller_object(_id, _camera = false) {
	global.controller = _id
	if (_camera) global.camera_main.follow = global.controller
}

function get_target_aim(_target, _origin_x, _origin_y, _bullet_spd) {
	var _relativeX = _target.x - _origin_x
	var _relativeY = _target.y - _origin_y
	
	var _targetVectorX = lengthdir_x(_target.spdCurrent, _target.moveVector)
	var _targetVectorY = lengthdir_y(_target.spdCurrent, _target.moveVector)
	
	var _a = power(_targetVectorX, 2) + power(_targetVectorY, 2) - power(_bullet_spd, 2)
	var _b = 2 * (_relativeX * _targetVectorX + _relativeY * _targetVectorY)
	var _c = power(_relativeX, 2) + power(_relativeY, 2)
	
	var _time = -1
	
	if (abs(_a) < 0.0001) {
		if (abs(_b) > 0.0001)
			_time = -_c / _b
	}
	else
	{
		var _disc = _b * _b - 4 * _a * _c
		
		if (_disc >= 0) {
			var _sqrt_disc = sqrt(_disc)
			
			var _time1 = (-_b - _sqrt_disc) / (2 * _a)
			var _time2 = (-_b + _sqrt_disc) / (2 * _a)
			
			if (_time1 > 0 && _time2 > 0) {
				_time = min(_time1, _time2)
			} else if (_time1 > 0) {
				_time = _time1
			} else if (_time2 > 0) {
				_time = _time2
			}
		}
	}
	
	if (_time > 0) {
		var _aim_x = _target.x + _targetVectorX * _time
		var _aim_y = _target.y + _targetVectorY * _time
		
		return point_direction(_origin_x, _origin_y, _aim_x, _aim_y)
	}
}
