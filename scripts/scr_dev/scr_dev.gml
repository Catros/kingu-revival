/// @function   angle_clamp(_angle, _center_dir, _arc)
/// @param      {real}  _angle        The angle to clamp
/// @param      {real}  _center_dir   The center direction of the arc
/// @param      {real}  _arc          The total arc width in degrees
/// @returns    {real}                The clamped angle
/// @description                      Clamps an angle within a specified arc around a center direction.
///                                   If the angle is already within the arc, it returns unchanged.
function angle_clamp(_angle, _center_dir, _arc) {
	var _half_arc = _arc / 2;
	var _dif = angle_difference(_angle, _center_dir);
	if (abs(_dif) < _half_arc) {
		return _angle;
	}

	return _center_dir + _half_arc * sign(_dif);
}

/// @function   angle_rotate_towards(_current, _target, _velocity, [_direction])
/// @param      {real}  _current      The current angle
/// @param      {real}  _target       The target angle to rotate towards
/// @param      {real}  _velocity     The rotation speed in degrees per step
/// @param      {real}  [_direction]  The direction to rotate (1 = clockwise, -1 = counter-clockwise)
///                                   Defaults to the shortest path direction
/// @returns    {real}                The new angle after rotation
/// @description                      Rotates an angle towards a target angle at a given speed.
///                                   Snaps to target when close enough.
function angle_rotate_towards(
	_current,
	_target,
	_velocity,
	_direction = sign(angle_difference(_current, _target))
) {
	_velocity = abs(_velocity);
	var _remaining = angle_difference(_current, _target);
	if (_remaining == 0) {
		return _target;
	}

	return abs(_remaining) < _velocity && sign(_remaining) == _direction
		? _target
		: _current - _velocity * _direction;
}

/// @function   angle_rotate_towards_smooth(a, b, i)
/// @param      {real}  a             The current angle
/// @param      {real}  b             The target angle
/// @param      {real}  i             Interpolation amount (0-1, where 1 is instant)
/// @returns    {real}                The smoothed angle
/// @description                      Smoothly rotates an angle towards another using lerp,
///                                   properly handling angle wrapping.
function angle_rotate_towards_smooth(a, b, i) {
	var angle = a + angle_difference(b, a);
	return lerp(a, angle, i);
}

/// @function   animation_end()
/// @returns    {bool}                Whether the current animation has reached its end
/// @description                      Checks if the sprite animation has reached the last frame,
///                                   accounting for image speed and game speed.
function animation_end() {
	var frame_range =
		image_speed
		* sprite_get_speed(sprite_index)
		/ game_get_speed(gamespeed_fps);
	return image_index >= image_number - frame_range && image_index < image_number;
}

/// @function   animcurve_lerp(_curve, _channel, _val1, _val2, _position)
/// @param      {asset}  _curve       The animation curve asset
/// @param      {string} _channel     The channel name within the curve
/// @param      {real}   _val1        The starting value
/// @param      {real}   _val2        The ending value
/// @param      {real}   _position    The position along the curve (0-1)
/// @returns    {real}                The interpolated value
/// @description                      Evaluates an animation curve channel and lerps between two values
///                                   based on the curve's output at the given position.
function animcurve_lerp(_curve, _channel, _val1, _val2, _position) {
	var _pos = animcurve_channel_evaluate(
		animcurve_get_channel(_curve, _channel),
		_position
	);
	return lerp(_val1, _val2, _pos);
}

/// @function   approach(_start, _end, _shift)
/// @param      {real}  _start        The current value
/// @param      {real}  _end          The target value
/// @param      {real}  _shift        The amount to move toward the target
/// @returns    {real}                The new value after approaching
/// @description                      Moves a value toward a target by a fixed amount.
///                                   Will not overshoot the target.
function approach(_start, _end, _shift) {
	return _start < _end ? min(_start + _shift, _end) : max(_start - _shift, _end);
}

/// @function   approach_smooth(_start, _end, _shift, [_snap])
/// @param      {real}  _start        The current value
/// @param      {real}  _end          The target value
/// @param      {real}  _shift        The interpolation factor (0-1, where 1 is instant)
/// @param      {real}  [_snap]       Distance threshold to snap to target (default: epsilon)
/// @returns    {real}                The new value after smooth approach
/// @description                      Smoothly approaches a target value using lerp.
///                                   Snaps to target when within the snap distance.
function approach_smooth(_start, _end, _shift, _snap = math_get_epsilon()) {
	if (abs(_start - _end) < _snap) {
		return _end;
	}

	return lerp(_start, _end, _shift);
}

/// @function   audio_play_sound_spaced(_id, _priority, _loops, [_min_time_between], [_gain], [_offset], [_pitch], [_listener_mask])
/// @param      {sound}  _id                     The sound asset to play
/// @param      {real}   _priority               Sound priority
/// @param      {bool}   _loops                  Whether the sound should loop
/// @param      {real}   [_min_time_between=1000] Minimum time in milliseconds between plays
/// @param      {real}   [_gain]                  Volume gain (0-1)
/// @param      {real}   [_offset]                Offset in seconds
/// @param      {real}   [_pitch]                 Pitch multiplier
/// @param      {real}   [_listener_mask]         Listener mask
/// @returns    {real|undefined}                  Sound ID if played, undefined if on cooldown
/// @description                                  Plays a sound with a minimum time spacing between plays.
///                                               Prevents sound spam by tracking last play time per sound.
function audio_play_sound_spaced(
	_id,
	_priority,
	_loops,
	_min_time_between = 1_000,
	_gain = undefined,
	_offset = undefined,
	_pitch = undefined,
	_listener_mask = undefined
) {
	static history = {};

	var _lastPlayed = history[$ _id];
	if (_lastPlayed == undefined || current_time - _lastPlayed > _min_time_between) {
		history[$ _id] = current_time;
		return audio_play_sound(
			_id,
			_priority,
			_loops,
			_gain,
			_offset,
			_pitch,
			_listener_mask
		);
	}
}

/// @function   broadcast_message_is_from_id([_id])
/// @param      {instance} [_id]      The instance to check against (defaults to calling instance)
/// @returns    {bool}                Whether the broadcast message came from the specified instance
/// @description                      Only usable in Broadcast Message event.
///                                   Checks if the broadcast message was sent by a specific instance.
function broadcast_message_is_from_id(_id = id) {
	return layer_instance_get_instance(event_data[? "element_id"]) == _id;
}

/// @function   ceil_n(_val, _inc)
/// @param      {real}  _val          The value to round up
/// @param      {real}  _inc          The increment to round to
/// @returns    {real}                The value rounded up to the nearest increment
/// @description                      Rounds a value up to the nearest multiple of the increment.
function ceil_n(_val, _inc) {
	return ceil(_val / _inc) * _inc;
}

/// @function   cos_oscillate(_min, _max, _duration, [_pos])
/// @param      {real}  _min          The minimum value of the oscillation
/// @param      {real}  _max          The maximum value of the oscillation
/// @param      {real}  _duration     The duration of one full oscillation in microseconds
/// @param      {real}  [_pos]        The current position in microseconds (defaults to get_timer())
/// @returns    {real}                The current oscillation value
/// @description                      Creates a cosine-based oscillation between min and max values.
///                                   Useful for smooth, natural-looking motion.
function cos_oscillate(_min, _max, _duration, _pos = get_timer()) {
	if (_duration == 0) {
		_duration = math_get_epsilon();
	}
	return (_max - _min) / 2 * dcos(360 * 0.000001 * _pos / _duration)
		+ (_max + _min) / 2;
}

/// @function   draw_cone(_x1, _y1, _dist, _dir, _angle, [_smoothness])
/// @param      {real}  _x1           The x origin of the cone
/// @param      {real}  _y1           The y origin of the cone
/// @param      {real}  _dist         The length/radius of the cone
/// @param      {real}  _dir          The direction of the cone center in degrees
/// @param      {real}  _angle        The total angle width of the cone in degrees
/// @param      {real}  [_smoothness=10] Number of segments (higher = smoother cone)
/// @description                      Draws a filled cone shape using primitives.
///                                   The cone originates from (_x1, _y1) and extends outward.
function draw_cone(_x1, _y1, _dist, _dir, _angle, _smoothness = 10) {
	_smoothness = max(1, round(_smoothness));

	draw_primitive_begin(pr_trianglefan);
	var _col = draw_get_color();
	var _alpha = draw_get_alpha();
	var _start_angle = _dir - _angle / 2;
	var _angle_inc = _angle / _smoothness;

	// Center vertex
	draw_vertex_colour(_x1, _y1, _col, _alpha);
	
	// Outer vertices
	for (var _i = _start_angle; _i <= _start_angle + _angle; _i += _angle_inc) {
		draw_vertex_colour(
			_x1 + lengthdir_x(_dist, _i),
			_y1 + lengthdir_y(_dist, _i),
			_col,
			_alpha
		);
	}
	draw_primitive_end();
}

/// @function   draw_self_ext([_sprite_index], [_image_index], [_x], [_y], [_image_xscale], [_image_yscale], [_image_angle], [_image_blend], [_image_alpha])
/// @param      {sprite} [_sprite_index]   The sprite to draw (defaults to current sprite)
/// @param      {real}   [_image_index]    The sub-image to draw (defaults to current image_index)
/// @param      {real}   [_x]              The x position (defaults to current x)
/// @param      {real}   [_y]              The y position (defaults to current y)
/// @param      {real}   [_image_xscale]   The x scale (defaults to current image_xscale)
/// @param      {real}   [_image_yscale]   The y scale (defaults to current image_yscale)
/// @param      {real}   [_image_angle]    The angle (defaults to current image_angle)
/// @param      {color}  [_image_blend]    The blend color (defaults to current image_blend)
/// @param      {real}   [_image_alpha]    The alpha (defaults to current image_alpha)
/// @description                            Draws the instance's sprite with customizable parameters.
///                                        All parameters default to the instance's current properties.
function draw_self_ext(
	_sprite_index = sprite_index,
	_image_index = image_index,
	_x = x,
	_y = y,
	_image_xscale = image_xscale,
	_image_yscale = image_yscale,
	_image_angle = image_angle,
	_image_blend = image_blend,
	_image_alpha = image_alpha
) {
	draw_sprite_ext(
		_sprite_index,
		_image_index,
		_x,
		_y,
		_image_xscale,
		_image_yscale,
		_image_angle,
		_image_blend,
		_image_alpha
	);
}

/// @function   draw_self_ext_subpixel([_sprite_index], [_image_index], [_x], [_y], [_image_xscale], [_image_yscale], [_image_angle], [_image_blend], [_image_alpha], [_view])
/// @param      {sprite}  [_sprite_index]   The sprite to draw
/// @param      {real}    [_image_index]    The sub-image to draw
/// @param      {real}    [_x]              The x position
/// @param      {real}    [_y]              The y position
/// @param      {real}    [_image_xscale]   The x scale
/// @param      {real}    [_image_yscale]   The y scale
/// @param      {real}    [_image_angle]    The angle
/// @param      {color}   [_image_blend]    The blend color
/// @param      {real}    [_image_alpha]    The alpha
/// @param      {camera}  [_view]           The camera for subpixel correction (defaults to view 0)
/// @description                            Draws the instance with subpixel correction to prevent shimmering.
///                                        Rounds position to pixel-aligned coordinates.
function draw_self_ext_subpixel(
	_sprite_index = sprite_index,
	_image_index = image_index,
	_x = x,
	_y = y,
	_image_xscale = image_xscale,
	_image_yscale = image_yscale,
	_image_angle = image_angle,
	_image_blend = image_blend,
	_image_alpha = image_alpha,
	_view = view_camera[0]
) {
	var _sw = surface_get_width(application_surface),
		_vw = camera_get_view_width(_view),
		_ratio = _vw / _sw;

	_x = round(_x / _ratio) * _ratio;
	_y = round(_y / _ratio) * _ratio;

	draw_sprite_ext(
		_sprite_index,
		_image_index,
		_x,
		_y,
		_image_xscale,
		_image_yscale,
		_image_angle,
		_image_blend,
		_image_alpha
	);
}

// Text alignment macros
// Values correspond to numpad layout for intuitive usage:
// 7=top-left, 8=top-center, 9=top-right
// 4=middle-left, 5=middle-center, 6=middle-right
// 1=bottom-left, 2=bottom-center, 3=bottom-right
#macro fa_left_bottom 1
#macro fa_center_bottom 2
#macro fa_right_bottom 3
#macro fa_left_middle 4
#macro fa_center_middle 5
#macro fa_right_middle 6
#macro fa_left_top 7
#macro fa_center_top 8
#macro fa_right_top 9

/// @function   draw_set_text_alignment(_alignment, [_color], [_font])
/// @param      {real}   _alignment  The alignment preset to use (fa_* macros)
/// @param      {color}  [_color]    The color to set (defaults to current draw color)
/// @param      {font}   [_font]     The font to set (defaults to current font)
/// @description                      Sets horizontal and vertical text alignment based on numpad-style presets.
///                                  Also optionally sets draw color and font in one call.
function draw_set_text_alignment(
	_alignment,
	_color = draw_get_color(),
	_font = draw_get_font()
) {
	switch (_alignment) {
		case fa_left_bottom:
			draw_set_halign(fa_left);
			draw_set_valign(fa_bottom);
			break;
		case fa_center_bottom:
			draw_set_halign(fa_center);
			draw_set_valign(fa_bottom);
			break;
		case fa_right_bottom:
			draw_set_halign(fa_right);
			draw_set_valign(fa_bottom);
			break;
		case fa_left_middle:
			draw_set_halign(fa_left);
			draw_set_valign(fa_middle);
			break;
		case fa_center_middle:
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			break;
		case fa_right_middle:
			draw_set_halign(fa_right);
			draw_set_valign(fa_middle);
			break;
		case fa_left_top:
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			break;
		case fa_center_top:
			draw_set_halign(fa_center);
			draw_set_valign(fa_top);
			break;
		case fa_right_top:
			draw_set_halign(fa_right);
			draw_set_valign(fa_top);
			break;
	}
	draw_set_color(_color);
	draw_set_font(_font);
}

/// @function   draw_sprite_from_center(_spr, _img, _x, _y, _xscale, _yscale, _rot, _col, _alpha)
/// @param      {sprite} _spr         The sprite to draw
/// @param      {real}   _img         The sub-image index
/// @param      {real}   _x           The x position of the center
/// @param      {real}   _y           The y position of the center
/// @param      {real}   _xscale      The x scale
/// @param      {real}   _yscale      The y scale
/// @param      {real}   _rot         The rotation angle in degrees
/// @param      {color}  _col         The blend color
/// @param      {real}   _alpha       The alpha value
/// @description                      Draws a sprite centered on the given position, regardless of its origin.
///                                   Uses matrix transformation to offset from the sprite's true center.
function draw_sprite_from_center(
	_spr,
	_img,
	_x,
	_y,
	_xscale,
	_yscale,
	_rot,
	_col,
	_alpha
) {
	var _originX = sprite_get_xoffset(_spr) - sprite_get_width(_spr) / 2;
	var _originY = sprite_get_yoffset(_spr) - sprite_get_height(_spr) / 2;

	_originX *= _xscale;
	_originY *= _yscale;

	matrix_set(matrix_world, matrix_build(_x, _y, 0, 0, 0, _rot, 1, 1, 1));

	draw_sprite_ext(_spr, _img, _originX, _originY, _xscale, _yscale, 0, _col, _alpha);
	matrix_set(matrix_world, matrix_build_identity());
}

/// @function   draw_sprite_solid_color([_spr], [_img], [_x], [_y], [_xs], [_ys], [_ang], [_col], [_a])
/// @param      {sprite} [_spr]       The sprite to draw
/// @param      {real}   [_img]       The sub-image index
/// @param      {real}   [_x]         The x position
/// @param      {real}   [_y]         The y position
/// @param      {real}   [_xs]        The x scale
/// @param      {real}   [_ys]        The y scale
/// @param      {real}   [_ang]       The angle
/// @param      {color}  [_col]       The solid color to draw
/// @param      {real}   [_a]         The alpha
/// @description                      Draws a sprite as a solid silhouette using fog trick.
///                                   All pixels are drawn in the specified color regardless of original colors.
function draw_sprite_solid_color(
	_spr = sprite_index,
	_img = image_index,
	_x = x,
	_y = y,
	_xs = image_xscale,
	_ys = image_yscale,
	_ang = image_angle,
	_col = image_blend,
	_a = image_alpha
) {
	gpu_set_fog(true, _col, -16000, 16000);
	draw_sprite_ext(_spr, _img, _x, _y, _xs, _ys, _ang, _col, _a);
	gpu_set_fog(false, 0, 0, 0);
}

/// @function   draw_surface_ext_origin(_surf, _x, _y, _xscale, _yscale, _rot, _col, _alpha, _originX, _originY)
/// @param      {surface} _surf       The surface to draw
/// @param      {real}    _x          The x position
/// @param      {real}    _y          The y position
/// @param      {real}    _xscale     The x scale
/// @param      {real}    _yscale     The y scale
/// @param      {real}    _rot        The rotation angle
/// @param      {color}   _col        The blend color
/// @param      {real}    _alpha      The alpha
/// @param      {real}    _originX    The x origin offset (before scaling)
/// @param      {real}    _originY    The y origin offset (before scaling)
/// @description                      Draws a surface with a custom origin point using matrix transformation.
function draw_surface_ext_origin(
	_surf,
	_x,
	_y,
	_xscale,
	_yscale,
	_rot,
	_col,
	_alpha,
	_originX,
	_originY
) {
	_originX *= _xscale;
	_originY *= _yscale;

	matrix_set(matrix_world, matrix_build(_x, _y, 0, 0, 0, _rot, 1, 1, 1));

	draw_surface_ext(_surf, -_originX, -_originY, _xscale, _yscale, 0, _col, _alpha);
	matrix_set(matrix_world, matrix_build_identity());
}

/// @function   floor_n(_val, _inc)
/// @param      {real}  _val          The value to round down
/// @param      {real}  _inc          The increment to round to
/// @returns    {real}                The value rounded down to the nearest increment
/// @description                      Rounds a value down to the nearest multiple of the increment.
function floor_n(_val, _inc) {
	return floor(_val / _inc) * _inc;
}

/// @function   grid_pos_to_number(_x, _y, _width)
/// @param      {real}  _x            The x grid position
/// @param      {real}  _y            The y grid position
/// @param      {real}  _width        The width of the grid
/// @returns    {real}                The 1D index from 2D grid coordinates
/// @description                      Converts 2D grid coordinates to a 1D array index.
function grid_pos_to_number(_x, _y, _width) {
	return _x + _y * _width;
}

/// @function   gtfo(_obj, [_precision])
/// @param      {object} _obj         The object to escape from
/// @param      {real}   [_precision=1] The step size for searching (higher = faster but less precise)
/// @description                      "Get The F*** Out" - Moves the instance out of collision with an object.
///                                   Spirals outward from the current position until a free spot is found.
///                                   Fixed: Removed invalid condition that prevented searching at range boundaries.
function gtfo(_obj, _precision = 1) {
	_precision = max(_precision, 1);
	if (!place_meeting(x, y, _obj)) {
		return;
	}
	var _range = _precision;
	var _startX = x;
	var _startY = y;
	while (true) {
		for (var _x = -_range; _x <= _range; _x += _precision) {
			for (var _y = -_range; _y <= _range; _y += _precision) {
				// Only check the perimeter of the current range square
				if (abs(_x) < _range && abs(_y) < _range) {
					continue;
				}
				x = _startX + _x;
				y = _startY + _y;
				if (!place_meeting(x, y, _obj)) {
					show_debug_message(
						"Got the F out after " + string(_range / _precision) + " cycles"
					);
					return;
				}
			}
		}
		_range += _precision;
	}
}

/// @function   gui_get_maximized_bounds()
/// @returns    {struct}              Struct with {left, top, right, bottom} bounds
/// @description                      Calculates the GUI bounds that would cover the entire window,
///                                   accounting for aspect ratio differences and letterboxing.
function gui_get_maximized_bounds() {
	var _gui_w = display_get_gui_width();
	var _gui_h = display_get_gui_height();
	var _win_w = window_get_width();
	var _win_h = window_get_height();

	var _gui_win_scale = min(_win_w / _gui_w, _win_h / _gui_h);
	var _gui_aspect = _gui_w / _gui_h;
	var _win_aspect = _win_w / _win_h;

	if (_win_aspect > _gui_aspect) {
		// Window is wider than GUI - letterboxed on sides
		var _gui_pixel_w = _gui_w * _gui_win_scale;
		var _w_dif = (_win_w - _gui_pixel_w) / 2;

		return {
			left: -(_w_dif / _gui_win_scale),
			top: 0,
			right: _gui_w + (_w_dif / _gui_win_scale),
			bottom: _gui_h,
		};
	} else if (_win_aspect < _gui_aspect) {
		// Window is taller than GUI - letterboxed on top/bottom
		var _gui_pixel_h = _gui_h * _gui_win_scale;
		var _h_dif = (_win_h - _gui_pixel_h) / 2;
		return {
			left: 0,
			top: -(_h_dif / _gui_win_scale),
			right: _gui_w,
			bottom: _gui_h + (_h_dif / _gui_win_scale),
		};
	}

	// Perfect match
	return {left: 0, top: 0, right: _gui_w, bottom: _gui_h};
}

/// @function   gui_x_to_room(_x, [_view])
/// @param      {real}  _x            The GUI x coordinate
/// @param      {real}  [_view=0]     The view index
/// @returns    {real}                The corresponding room x coordinate
/// @description                      Converts a GUI x coordinate to a room x coordinate.
function gui_x_to_room(_x, _view = 0) {
	var _gw = display_get_gui_width();
	var _vx = camera_get_view_x(view_camera[_view]);
	var _vw = camera_get_view_width(view_camera[_view]);
	return lerp(_vx, _vx + _vw, _x / _gw);
}

/// @function   gui_y_to_room(_y, [_view])
/// @param      {real}  _y            The GUI y coordinate
/// @param      {real}  [_view=0]     The view index
/// @returns    {real}                The corresponding room y coordinate
/// @description                      Converts a GUI y coordinate to a room y coordinate.
function gui_y_to_room(_y, _view = 0) {
	var _gh = display_get_gui_height();
	var _vy = camera_get_view_y(view_camera[_view]);
	var _vh = camera_get_view_height(view_camera[_view]);
	return lerp(_vy, _vy + _vh, _y / _gh);
}

/// @function   how_far_out(_val, _min, _max)
/// @param      {real}  _val          The value to check
/// @param      {real}  _min          The minimum allowed value
/// @param      {real}  _max          The maximum allowed value
/// @returns    {real}                How far the value is outside the range (negative if below min, positive if above max, 0 if in range)
/// @description                      Returns the distance a value is outside a given range.
///                                   Returns 0 if the value is within the range.
function how_far_out(_val, _min, _max) {
	if (_val < _min) {
		return _val - _min;
	}
	if (_val > _max) {
		return _val - _max;
	}
	return 0;
}

/// @function   instance_create(_obj, [_struct])
/// @param      {object} _obj         The object to create
/// @param      {struct} [_struct={}] Optional struct of variables to set on the new instance
/// @returns    {instance}            The created instance
/// @description                      Creates an instance at depth 0 with optional initialization struct.
///                                   Simplified wrapper for instance_create_depth.
function instance_create(_obj, _struct = {}) {
	return instance_create_depth(0, 0, 0, _obj, _struct);
}

/// @function   instance_find_center(_inst)
/// @param      {instance} _inst      The instance to find the center of
/// @returns    {struct}              Struct with {x, y} representing the center point
/// @description                      Calculates the center point of an instance based on its bounding box.
function instance_find_center(_inst) {
	return {
		x: mean(_inst.bbox_right, _inst.bbox_left),
		y: mean(_inst.bbox_top, _inst.bbox_bottom),
	};
}

/// @function   is_between(_x, _bound_a, _bound_b, [_equal_to])
/// @param      {real}  _x            The value to check
/// @param      {real}  _bound_a      One bound of the range
/// @param      {real}  _bound_b      The other bound of the range
/// @param      {bool}  [_equal_to=false] Whether to include the boundary values
/// @returns    {bool}                Whether the value is between the bounds
/// @description                      Checks if a value is between two bounds (order doesn't matter).
function is_between(_x, _bound_a, _bound_b, _equal_to = false) {
	var _left = min(_bound_a, _bound_b);
	var _right = max(_bound_a, _bound_b);
	return !_equal_to ? (_left < _x && _x < _right) : (_left <= _x && _x <= _right);
}

/// @function   is_or(_value, ...)
/// @param      {any}  _value         The value to compare
/// @param      {...}  ...            Any number of values to compare against
/// @returns    {bool}                Whether the value matches any of the provided options
/// @description                      Checks if a value equals any of the provided arguments.
///                                   Alternative to multiple || statements.
function is_or(_value) {
	for (var _i = 1; _i < argument_count; _i++) {
		if (_value == argument[_i]) {
			return true;
		}
	}
	return false;
}

/// @function   key_to_string(_key)
/// @param      {real}  _key          The keyboard key code (e.g., from keyboard_lastkey)
/// @returns    {string}              The human-readable name of the key
/// @description                      Converts a keyboard key code to a readable string.
///                                   Written by reddit user disembodieddave.
function key_to_string(_key) {
	if (_key > 48 && _key < 91) {
		return chr(_key);
	}

	switch (_key) {
		case -1: return "No Key";
		case 8: return "Backspace";
		case 9: return "Tab";
		case 13: return "Enter";
		case 16: return "Shift";
		case 17: return "Ctrl";
		case 18: return "Alt";
		case 19: return "Pause/Break";
		case 20: return "CAPS";
		case 27: return "Esc";
		case 33: return "Page Up";
		case 34: return "Page Down";
		case 35: return "End";
		case 36: return "Home";
		case 37: return "Left Arrow";
		case 38: return "Up Arrow";
		case 39: return "Right Arrow";
		case 40: return "Down Arrow";
		case 45: return "Insert";
		case 46: return "Delete";
		case 96: return "Numpad 0";
		case 97: return "Numpad 1";
		case 98: return "Numpad 2";
		case 99: return "Numpad 3";
		case 100: return "Numpad 4";
		case 101: return "Numpad 5";
		case 102: return "Numpad 6";
		case 103: return "Numpad 7";
		case 104: return "Numpad 8";
		case 105: return "Numpad 9";
		case 106: return "Numpad *";
		case 107: return "Numpad +";
		case 109: return "Numpad -";
		case 110: return "Numpad .";
		case 111: return "Numpad /";
		case 112: return "F1";
		case 113: return "F2";
		case 114: return "F3";
		case 115: return "F4";
		case 116: return "F5";
		case 117: return "F6";
		case 118: return "F7";
		case 119: return "F8";
		case 120: return "F9";
		case 121: return "F10";
		case 122: return "F11";
		case 123: return "F12";
		case 144: return "Num Lock";
		case 145: return "Scroll Lock";
		case 186: return ";";
		case 187: return "=";
		case 188: return ",";
		case 189: return "-";
		case 190: return ".";
		case 191: return "\\";
		case 192: return "`";
		case 219: return "/";
		case 220: return "[";
		case 221: return "]";
		case 222: return "'";
	}
}

/// @function   lerp_clamped(_val1, _val2, _pos)
/// @param      {real}  _val1         The starting value
/// @param      {real}  _val2         The ending value
/// @param      {real}  _pos          The interpolation position
/// @returns    {real}                The clamped lerp result
/// @description                      Performs a lerp but clamps the result between the two input values.
///                                   Prevents overshooting that can occur with standard lerp.
function lerp_clamped(_val1, _val2, _pos) {
	var _min = min(_val1, _val2);
	var _max = max(_val1, _val2);
	return clamp(lerp(_val1, _val2, _pos), _min, _max);
}

/// @function   matrix_build_rotation(_x, _y, _z)
/// @param      {real}  _x            X rotation in degrees
/// @param      {real}  _y            Y rotation in degrees
/// @param      {real}  _z            Z rotation in degrees
/// @returns    {matrix}              A rotation matrix
/// @description                      Builds a rotation-only matrix at the origin.
function matrix_build_rotation(_x, _y, _z) {
	return matrix_build(0, 0, 0, _x, _y, _z, 1, 1, 1);
}

/// @function   matrix_build_scale(_x, _y, _z)
/// @param      {real}  _x            X scale
/// @param      {real}  _y            Y scale
/// @param      {real}  _z            Z scale
/// @returns    {matrix}              A scale matrix
/// @description                      Builds a scale-only matrix at the origin.
function matrix_build_scale(_x, _y, _z) {
	return matrix_build(0, 0, 0, 0, 0, 0, _x, _y, _z);
}

/// @function   matrix_build_translation(_x, _y, _z)
/// @param      {real}  _x            X translation
/// @param      {real}  _y            Y translation
/// @param      {real}  _z            Z translation
/// @returns    {matrix}              A translation matrix
/// @description                      Builds a translation-only matrix.
function matrix_build_translation(_x, _y, _z) {
	return matrix_build(_x, _y, _z, 0, 0, 0, 1, 1, 1);
}

/// @function   matrix_combine(matrix1, matrix2, ...)
/// @param      {matrix} matrix1      The first matrix
/// @param      {matrix} matrix2      The second matrix
/// @param      {...}    ...          Additional matrices to multiply
/// @returns    {matrix}              The combined matrix
/// @description                      Combines multiple matrices by multiplying them together in order.
function matrix_combine() {
	var _m = matrix_multiply(argument[0], argument[1]);
	for (var _i = 2; _i < argument_count; _i++) {
		_m = matrix_multiply(_m, argument[_i]);
	}
	return _m;
}

/// @function   merge_struct(_target, _struct, [_overwrite])
/// @param      {struct} _target      The struct to merge into
/// @param      {struct} _struct      The struct to merge from
/// @param      {bool}   [_overwrite=false] Whether to overwrite existing keys
/// @description                      Merges the contents of one struct into another.
///                                   Optionally prevents overwriting existing keys.
function merge_struct(_target, _struct, _overwrite = false) {
	struct_foreach(_struct, method({_target, _overwrite}, function(_name, _value) {
		if (!_overwrite && _target[$ _name] != undefined) {
			return;
		}
		_target[$ _name] = _value;
	}));
}

/// @function   mod2(_dividend, _divisor)
/// @param      {real}  _dividend     The number to divide
/// @param      {real}  _divisor      The divisor
/// @returns    {real}                The remainder
/// @description                      Performs modulo operation with proper handling of negative numbers.
///                                   Unlike the % operator, this always returns a positive result.
function mod2(_dividend, _divisor) {
	return _dividend - floor(_dividend / _divisor) * _divisor;
}

/// @function   mouse_get_position_accurate()
/// @returns    {struct}              Struct with {x, y} in room coordinates
/// @description                      Gets the accurate mouse position in room coordinates by
///                                   using window mouse position and view calculations.
///                                   More accurate than mouse_x/mouse_y in some scenarios.
function mouse_get_position_accurate() {
	var _winMX = window_mouse_get_x();
	var _winMY = window_mouse_get_y();
	var _winW = window_get_width();
	var _winH = window_get_height();
	var _vx = camera_get_view_x(view_camera[0]);
	var _vy = camera_get_view_y(view_camera[0]);
	var _vw = camera_get_view_width(view_camera[0]);
	var _vh = camera_get_view_height(view_camera[0]);

	return {
		x: lerp(_vx, _vx + _vw, _winMX / _winW),
		y: lerp(_vy, _vy + _vh, _winMY / _winH),
	};
}

/// @function   number_to_grid_pos(_num, _width)
/// @param      {real}  _num          The 1D index
/// @param      {real}  _width        The grid width
/// @returns    {struct}              Struct with {x, y} grid position
/// @description                      Converts a 1D index to 2D grid coordinates.
function number_to_grid_pos(_num, _width) {
	var _y = _num div _width;
	var _x = _num - (_y * _width);
	return {x: _x, y: _y};
}

/// @function   point_rotate(_x, _y, _angle)
/// @param      {real}  _x            The x coordinate to rotate
/// @param      {real}  _y            The y coordinate to rotate
/// @param      {real}  _angle        The angle to rotate by (in degrees)
/// @returns    {array}               Array [x, y] of the rotated point
/// @description                      Rotates a point around the origin (0,0) by the given angle.
function point_rotate(_x, _y, _angle) {
	var _angRad = degtorad(_angle);
	var _angCos = cos(_angRad), _angSin = sin(_angRad);

	return [_x * _angCos + _y * _angSin, _y * _angCos + _x * _angSin];
}

/// @function   position_between(_val, _low, _up)
/// @param      {real}  _val          The value to normalize
/// @param      {real}  _low          The lower bound
/// @param      {real}  _up           The upper bound
/// @returns    {real}                The normalized position (0-1) between the bounds
/// @description                      Returns the position of a value between two bounds as a 0-1 ratio.
function position_between(_val, _low, _up) {
	_up -= _low;
	_val -= _low;
	return _val / _up;
}

/// @function   random_point_on_boundary(_x1, _y1, _x2, _y2, [_ex_top], [_ex_bot], [_ex_right], [_ex_left])
/// @param      {real}  _x1           Left bound
/// @param      {real}  _y1           Top bound
/// @param      {real}  _x2           Right bound
/// @param      {real}  _y2           Bottom bound
/// @param      {bool}  [_ex_top=false]    Exclude top edge
/// @param      {bool}  [_ex_bot=false]    Exclude bottom edge
/// @param      {bool}  [_ex_right=false]  Exclude right edge
/// @param      {bool}  [_ex_left=false]   Exclude left edge
/// @returns    {struct|undefined}     Struct with {x, y}, or undefined if all edges excluded
/// @description                      Returns a random point on the boundary of a rectangle.
///                                   Optionally excludes specific edges.
function random_point_on_boundary(
	_x1,
	_y1,
	_x2,
	_y2,
	_ex_top = false,
	_ex_bot = false,
	_ex_right = false,
	_ex_left = false
) {
	var _x = _x1;
	var _y = _y1;
	
	// Return undefined if all edges are excluded
	if (_ex_left && _ex_right && _ex_top && _ex_bot) {
		return;
	}

	var _spawn_on_side = choose(false, true);
	
	// Force top/bottom if both sides excluded, force side if both top/bottom excluded
	if (_spawn_on_side && _ex_left && _ex_right) {
		_spawn_on_side = false;
	} else if (!_spawn_on_side && _ex_top && _ex_bot) {
		_spawn_on_side = true;
	}

	if (_spawn_on_side) {
		// Left or right edge
		_x = choose(_x1, _x2);
		if (_x == _x1 && _ex_left) {
			_x = _x2;
		}
		if (_x == _x2 && _ex_right) {
			_x = _x1;
		}

		_y = irandom_range(_y1, _y2);
	} else {
		// Top or bottom edge
		_x = irandom_range(_x1, _x2);

		_y = choose(_y1, _y2);
		if (_y == _y1 && _ex_top) {
			_y = _y2;
		}
		if (_y == _y2 && _ex_bot) {
			_y = _y1;
		}
	}

	return {x: _x, y: _y};
}

/// @function   room_to_gui_x(_x, [_view])
/// @param      {real}  _x            The room x coordinate
/// @param      {real}  [_view=0]     The view index
/// @returns    {real}                The corresponding GUI x coordinate
/// @description                      Converts a room x coordinate to a GUI x coordinate.
function room_to_gui_x(_x, _view = 0) {
	var _gw = display_get_gui_width();
	var _vx = camera_get_view_x(view_camera[_view]);
	var _vw = camera_get_view_width(view_camera[_view]);
	return lerp(0, _gw, (_x - _vx) / _vw);
}

/// @function   room_to_gui_y(_y, [_view])
/// @param      {real}  _y            The room y coordinate
/// @param      {real}  [_view=0]     The view index
/// @returns    {real}                The corresponding GUI y coordinate
/// @description                      Converts a room y coordinate to a GUI y coordinate.
function room_to_gui_y(_y, _view = 0) {
	var _gh = display_get_gui_height();
	var _vy = camera_get_view_y(view_camera[_view]);
	var _vh = camera_get_view_height(view_camera[_view]);
	return lerp(0, _gh, (_y - _vy) / _vh);
}

/// @function   round_n(_val, _inc)
/// @param      {real}  _val          The value to round
/// @param      {real}  _inc          The increment to round to
/// @returns    {real}                The value rounded to the nearest increment
/// @description                      Rounds a value to the nearest multiple of the increment.
function round_n(_val, _inc) {
	return round(_val / _inc) * _inc;
}

/// @function   seconds_to_timestamp(_seconds)
/// @param      {real}  _seconds      The number of seconds
/// @returns    {string}              Formatted time string "M:SS"
/// @description                      Converts seconds to a M:SS formatted timestamp.
function seconds_to_timestamp(_seconds) {
	_seconds = round(_seconds);
	var _m = _seconds div 60;
	var _s = _seconds % 60;
	if (_s < 10) {
		return string(_m) + ":0" + string(_s);
	} else {
		return string(_m) + ":" + string(_s);
	}
}

/// @function   steps_to_timestamp(_steps)
/// @param      {real}  _steps        The number of game steps
/// @returns    {string}              Formatted time string "M:SS"
/// @description                      Converts game steps to a M:SS formatted timestamp.
function steps_to_timestamp(_steps) {
	return seconds_to_timestamp(_steps div game_get_speed(gamespeed_fps));
}

/// @function   sin_oscillate(_min, _max, _duration, [_pos])
/// @param      {real}  _min          The minimum value of the oscillation
/// @param      {real}  _max          The maximum value of the oscillation
/// @param      {real}  _duration     The duration of one full oscillation in microseconds
/// @param      {real}  [_pos]        The current position in microseconds (defaults to get_timer())
/// @returns    {real}                The current oscillation value
/// @description                      Creates a sine-based oscillation between min and max values.
///                                   Useful for smooth, natural-looking motion.
function sin_oscillate(_min, _max, _duration, _pos = get_timer()) {
	if (_duration == 0) {
		_duration = math_get_epsilon();
	}
	return (_max - _min) / 2 * dsin(360 * 0.000001 * _pos / _duration)
		+ (_max + _min) / 2;
}

/// @function   sprite_is_on_frame(_frame)
/// @param      {real}  _frame        The frame to check
/// @returns    {bool}                Whether the sprite is currently on the specified frame
/// @description                      Returns true on the first step the desired frame is displayed.
///                                   Accounts for image speed and game speed.
///                                   By Gleb Tsereteli
function sprite_is_on_frame(_frame) {
	var _speed =
		image_speed / (game_get_speed(gamespeed_fps) / sprite_get_speed(sprite_index));

	var _positive = _speed > 0;
	var _min = _positive ? _frame : _frame + 1 + _speed;
	var _max = _positive ? _frame + _speed : _frame + 1;

	return (image_index >= _min) && (image_index < _max);
}

/// @function   sprite_swap(_sprite)
/// @param      {sprite} _sprite      The sprite to switch to
/// @description                      Swaps the instance's sprite, resetting the image index
///                                   only if the sprite actually changes.
function sprite_swap(_sprite) {
	if (sprite_index != _sprite) {
		image_index = 0;
		sprite_index = _sprite;
	}
}

/// @function   steps_to_microseconds(_steps)
/// @param      {real}  _steps        The number of game steps
/// @returns    {real}                The equivalent time in microseconds
/// @description                      Converts game steps to microseconds based on room speed.
function steps_to_microseconds(_steps) {
	return 1000000 * (_steps / game_get_speed(gamespeed_fps));
}

/// @function   with_tag(_tags, _func)
/// @param      {string|array} _tags  The tag(s) to match
/// @param      {method}      _func   The function to call for each matching object asset
/// @description                      Executes a function for each object asset that has the specified tag(s).
function with_tag(_tags, _func) {
	var _objs = tag_get_asset_ids(_tags, asset_object);

	for (var _i = 0; _i < array_length(_objs); _i++) {
		_func(_objs[_i]);
	}
}

/// @function   wrap(_val, _min, _max)
/// @param      {real}  _val          The value to wrap
/// @param      {real}  _min          The minimum value (inclusive)
/// @param      {real}  _max          The maximum value (exclusive)
/// @returns    {real}                The wrapped value
/// @description                      Wraps a value between min and max. If the value is outside the range,
///                                   it wraps around (like angles wrapping at 360 degrees).
function wrap(_val, _min, _max) {
	var _small = min(_min, _max);
	var _large = max(_min, _max) - _small;
	var _value = _val - _small;

	return _value - floor(_value / _large) * _large + _small;
}