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

function file_get_content(_filename) {
	var _buffer = buffer_load(_filename)
	
	if (_buffer != -1) {
		var _text = buffer_read(_buffer, buffer_string)
		buffer_delete(_buffer)
		return _text
	}
	throw "File doesn't exists."
}

/// @function draw_stat_circle(value, maxValue, centerX, centerY, radius, thickness, hueMax)
/// @description Draws a ring of small circles representing a stat (health, mana, stamina, etc.)
///              as points around a circle, colored on a hue gradient from hueMax down to 0
///              based on the value/maxValue ratio. Only points up to and including the
///              current value are drawn.
/// @param {real} value      Current value of the stat
/// @param {real} maxValue   Maximum value of the stat (also determines number of points)
/// @param {real} centerX    X coordinate of the circle's center
/// @param {real} centerY    Y coordinate of the circle's center
/// @param {real} radius     Radius of the main circle the points are placed on
/// @param {real} thickness Radius of each individual point drawn
/// @param {real} hueMax     Hue value (0-255) representing a full stat (e.g. 80 = green)
function draw_stat_circle(value, maxValue, centerX, centerY, radius, thickness, hueMax) {
	var _points = maxValue
	var _slice = 2 * pi / _points

	for (var _i = 0; _i < _points; _i++) {
		var _angle = _slice * _i
		var _newX = centerX + radius * cos(_angle)
		var _newY = centerY + radius * sin(_angle)

		if (_i <= value) {
			var _hue = value / maxValue * hueMax
			draw_set_color(make_color_hsv(_hue, 255, 255))
			draw_circle(_newX, _newY, thickness, false)
		}
	}
}

// IA-MADE

// Annular collision helpers — ring = area between inner_radius and outer_radius.
//
// Detection is two-stage: collision_circle_list() finds outer-circle candidates,
// then candidates whose entire bounding box fits strictly inside the inner circle
// are rejected. This is conservative: false positives are possible (bbox straddles
// the hole boundary but precise mask is fully inside), false negatives are not.
//
// For the first hit only:  collision_ring()
// For all hits:            collision_ring_list()


/// @function collision_ring(cx, cy, inner_radius, outer_radius, obj, prec, notme)
/// @desc     Returns the first instance of obj intersecting the ring, or noone.
///           Pass inner_radius = 0 for a plain circle (delegates to collision_circle).
/// @param {real}           cx            Ring centre X.
/// @param {real}           cy            Ring centre Y.
/// @param {real}           inner_radius  Hole radius (>= 0, < outer_radius).
/// @param {real}           outer_radius  Outer boundary radius (> 0).
/// @param {Asset.GMObject} obj           Object to test against.
/// @param {bool}           prec          Use precise masks for the outer-circle test.
/// @param {bool}           notme         Exclude the calling instance.
/// @return {Id.Instance}
function collision_ring(cx, cy, inner_radius, outer_radius, obj, prec, notme)
{
    if (inner_radius < 0 || outer_radius <= 0 || inner_radius >= outer_radius)
        return noone;

    // Fast path: no hole, delegate directly.
    if (inner_radius == 0)
        return collision_circle(cx, cy, outer_radius, obj, prec, notme);

    var _candidates = ds_list_create();
    var _count      = collision_circle_list(cx, cy, outer_radius, obj, prec, notme, _candidates, false);
    var _result     = noone;

    for (var _i = 0; _i < _count; ++_i)
    {
        if (!__collision_ring_bbox_fully_inside_circle(_candidates[| _i], cx, cy, inner_radius))
        {
            _result = _candidates[| _i];
            break;
        }
    }

    ds_list_destroy(_candidates);
    return _result;
}


/// @function collision_ring_list(cx, cy, inner_radius, outer_radius, obj, prec, notme, list, ordered)
/// @desc     Appends every instance of obj intersecting the ring to list.
///           Returns the number of instances added. Does not clear list beforehand.
///           Pass inner_radius = 0 for a plain circle (delegates to collision_circle_list).
///           When ordered = true, retained candidates preserve their distance-sorted
///           relative order, but the sequence may have gaps where hole-rejected
///           candidates were removed.
/// @param {real}           cx            Ring centre X.
/// @param {real}           cy            Ring centre Y.
/// @param {real}           inner_radius  Hole radius (>= 0, < outer_radius).
/// @param {real}           outer_radius  Outer boundary radius (> 0).
/// @param {Asset.GMObject} obj           Object to test against.
/// @param {bool}           prec          Use precise masks for the outer-circle test.
/// @param {bool}           notme         Exclude the calling instance.
/// @param {Id.DsList}      list          Existing ds_list to append results into.
/// @param {bool}           ordered       Sort retained results by distance from centre.
/// @return {real}  Number of instances added to list.
function collision_ring_list(cx, cy, inner_radius, outer_radius, obj, prec, notme, list, ordered)
{
    if (inner_radius < 0 || outer_radius <= 0 || inner_radius >= outer_radius)
        return 0;

    // Fast path: no hole, delegate directly.
    if (inner_radius == 0)
        return collision_circle_list(cx, cy, outer_radius, obj, prec, notme, list, ordered);

    var _candidates = ds_list_create();
    var _raw_count  = collision_circle_list(cx, cy, outer_radius, obj, prec, notme, _candidates, ordered);
    var _added      = 0;

    for (var _i = 0; _i < _raw_count; ++_i)
    {
        var _inst = _candidates[| _i];
        if (!__collision_ring_bbox_fully_inside_circle(_inst, cx, cy, inner_radius))
        {
            ds_list_add(list, _inst);
            ++_added;
        }
    }

    ds_list_destroy(_candidates);
    return _added;
}


/// @function __collision_ring_bbox_fully_inside_circle(inst, cx, cy, radius)
/// @desc     Returns true when inst's entire bounding box lies strictly inside
///           the circle — i.e. the farthest bbox corner from (cx, cy) is closer
///           than radius. Touching the boundary returns false (counts as ring hit).
/// @param {Id.Instance} inst
/// @param {real}        cx      Circle centre X.
/// @param {real}        cy      Circle centre Y.
/// @param {real}        radius  Circle radius.
/// @return {bool}
function __collision_ring_bbox_fully_inside_circle(inst, cx, cy, radius)
{
    // The farthest bbox corner on each axis is whichever edge is more distant
    // from the centre. Comparing squared distances avoids a sqrt.
    var _dx = max(abs(inst.bbox_left - cx), abs(inst.bbox_right  - cx));
    var _dy = max(abs(inst.bbox_top  - cy), abs(inst.bbox_bottom - cy));
    return (sqr(_dx) + sqr(_dy)) < sqr(radius);
}
