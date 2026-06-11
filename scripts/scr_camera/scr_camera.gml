/// @function                   camera_matrix_get_properties(_camera)
/// @param {camera}  _camera    The camera to get properties from
/// @returns {array}            Array containing camera properties:
///                             [0] = View Width
///                             [1] = View Height
///                             [2] = Center X
///                             [3] = Center Y
///                             [4] = Left Bound
///                             [5] = Top Bound
/// @description                Extracts camera dimensions and position from the view and projection matrices.
///                             Fixed: Added parameter binding and array initialization.
function camera_matrix_get_properties(_camera) {
	var _view_mtx = camera_get_view_mat(_camera);
	var _proj_mtx = camera_get_proj_mat(_camera);
	var _return = [];  // Initialize array before assignment
	_return[0] = 2 / _proj_mtx[0];
	_return[1] = 2 / _proj_mtx[5];
	_return[2] = -_view_mtx[12];
	_return[3] = -_view_mtx[13];
	_return[4] = _return[2] - _return[0] / 2;
	_return[5] = _return[3] - _return[1] / 2;

	return _return;
}

/// @function                   camera_set_view_pos_subpixel(_cam, _x, _y)
/// @param {camera}  _cam        The camera to position
/// @param {real}    _x         The x position to set
/// @param {real}    _y         The y position to set
/// @description                Sets camera position with subpixel correction to prevent shimmering artifacts.
///                             Rounds position to nearest pixel-aligned coordinate based on surface-to-view ratio.
function camera_set_view_pos_subpixel(_cam, _x, _y) {
	var _sw = surface_get_width(application_surface),
		_vw = camera_get_view_width(_cam),
		_ratio = _vw / _sw;

	_x = round(_x / _ratio) * _ratio;
	_y = round(_y / _ratio) * _ratio;

	camera_set_view_pos(_cam, _x, _y);
}

/// @function                   display_write_all_specs([_x], [_y], [_scale])
/// @param {real}    [_x=5]      The x position to draw the display info
/// @param {real}    [_y=5]      The y position to draw the display info
/// @param {real}    [_scale=auto] The scale factor for text rendering
/// @description                Draws detailed display information including resolution, aspect ratios,
///                             scaling factors, and view properties for debugging purposes.
///                             Uses text shadow (black/white) for readability.
function display_write_all_specs(
	_x = 5,
	_y = 5,
	_scale = display_get_gui_height() / window_get_height()
) {
	var _dispW = display_get_width(),
		_dispH = display_get_height(),
		_winW = window_get_width(),
		_winH = window_get_height(),
		_appW = surface_get_width(application_surface),
		_appH = surface_get_height(application_surface),
		_guiW = display_get_gui_width(),
		_guiH = display_get_gui_height();

	var _str = "";

	// Display resolution
	var _dispRes = $"{_dispW} x {_dispH}";
	var _dispAspect = string_format(_dispW / _dispH, 2, 4);  // Format aspect ratio to 4 decimal places
	_str += $"Display: {_dispRes} - {_dispAspect}\n";

	// Window resolution
	var _winRes = $"{_winW} x {_winH}";
	var _winAspect = string_format(_winW / _winH, 2, 4);
	_str += $"Window: {_winRes} - {_winAspect}\n";

	// Application surface
	var _appRes = $"{_appW} x {_appH}";
	var _appAspect = string_format(_appW / _appH, 2, 4);
	var _appScale = _winW / _appW
	== _winH / _appH
		? $"{_winW / _appW}"
		: $"({_winW / _appW} : {_winH / _appH})";

	_str += $"App Surface: {_appRes} - {_appAspect} - {_appScale}X\n";

	// GUI layer
	var _guiRes = $"{_guiW} x {_guiH}";
	var _guiAspect = string_format(_guiW / _guiH, 2, 4);
	var _guiScale = _appW / _guiW
	== _appH / _guiH
		? $"{_appW / _guiW}"
		: $"({_appW / _guiW} : {_appH / _guiH})";

	_str += $"GUI: {_guiRes} - {_guiAspect} - {_guiScale}X\n";

	// View information
	if (view_enabled) {  // Only check once before the loop
		for (var _i = 0; _i < 8; _i++) {
			if (!view_visible[_i]) {
				continue;
			}

			var _viewW = camera_get_view_width(view_camera[_i]),
				_viewH = camera_get_view_height(view_camera[_i]);
			var _viewRes = $"{_viewW} x {_viewH}";
			var _viewAspect = string_format(_viewW / _viewH, 2, 4);
			var _viewScale = _appW / _viewW
			== _appH / _viewH
				? $"{_appW / _viewW}"
				: $"({_appW / _viewW} : {_appH / _viewH})";
			
			// Round view position to 2 decimal places for cleaner display
			var _viewX = camera_get_view_x(view_camera[_i]);
			var _viewY = camera_get_view_y(view_camera[_i]);
			var _viewPos = $"   @{_viewX}, {_viewY}";
			
			_str += $"View {_i}: {_viewRes} - {_viewAspect} - {_viewScale}X\n";
			_str += _viewPos + "\n";
		}
	}
	
	// Draw text with shadow effect for readability
	draw_set_color(c_black);
	draw_text_transformed((_x + 1) * _scale, (_y + 1) * _scale, _str, _scale, _scale, 0);
	draw_set_color(c_white);
	draw_text_transformed(_x * _scale, _y * _scale, _str, _scale, _scale, 0);
}