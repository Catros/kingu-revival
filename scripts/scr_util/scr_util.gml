/// @param {object}			_instance		The instance that now has control
/// @param {boolean}		_setCamera		Whether the camera should follow this instance
/// @param {boolean}		_setCameraFocus	Whether the camera should already be centered on the instance
/// @description			Sets the control of keybinds to the given object.
function set_controller_instance(_instance, _setCamera = true, _setCameraFocus = true) {
	global.controller = _instance
	if (_setCamera) {
		global.camera.set_target(_instance, _setCameraFocus)
	}
}

/**
 * @description 
 * Calculates the aim direction to intercept a moving target with a projectile. Uses quadratic formula to solve for the earliest future intercept point, accounting for both target velocity and bullet speed.
 *
 * Fire a bullet from (100, 100) toward a moving target:
 * var aimAngle = get_target_aim(target, 100, 100, 15)
 * if (aimAngle != undefined) {
 *     bullet.direction = aimAngle
 * }
 * 
 * @param {Object} _target             - The target object to intercept.
 * @param {number} _origin_x           - X position of the shooter/projectile origin.
 * @param {number} _origin_y           - Y position of the shooter/projectile origin.
 * @param {number} _bullet_spd         - Speed of the projectile to be fired.
 *
 * @returns {number}	The aim angle in degrees toward the predicted intercept
 *
 */
function get_target_aim(_target, _origin_x, _origin_y, _bullet_spd) {
	var _relativeX = _target.x - _origin_x
	var _relativeY = _target.y - _origin_y
	
	var _targetVectorX = lengthdir_x(_target.spdCurrent, _target.moveDirection)
	var _targetVectorY = lengthdir_y(_target.spdCurrent, _target.moveDirection)
	
	var _a = _targetVectorX * _targetVectorX + _targetVectorY * _targetVectorY - _bullet_spd * _bullet_spd
	var _b = 2 * (_relativeX * _targetVectorX + _relativeY * _targetVectorY)
	var _c = _relativeX * _relativeX + _relativeY * _relativeY
	
	var _time = -1
	
	if (abs(_a) < 0.0001) {
		if (abs(_b) > 0.0001) {
			var _t = -_c / _b
			if (_t > 0) _time = _t
		}
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
	
	return point_direction(_origin_x, _origin_y, _target.x, _target.y)
}
