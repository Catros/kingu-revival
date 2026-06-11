/// @function                   array_2d_foreach(_arr, _func)
/// @param {array}   _arr        The 2D array to iterate over
/// @param {method}  _func       The callback function to call for each element
/// @description                Iterates over every element in a 2D array, calling the callback
///                             with (value, array, [x, y]) for each element
function array_2d_foreach(_arr, _func) {
	var _width = array_length(_arr);
	var _height = array_length(_arr[0]);

	for (var _x = 0; _x < _width; _x++) {
		for (var _y = 0; _y < _height; _y++) {
			_func(_arr[_x][_y], _arr, [_x, _y]);
		}
	}
}

/// @function                   array_2d_foreach_adjacent(_arr, _pos, _func, [_skipCenter], [_dist], [_cardinalOnly])
/// @param {array}   _arr        The 2D array to iterate over
/// @param {array}   _pos        The center position [x, y] to iterate around
/// @param {method}  _func       The callback function to call for each adjacent element
/// @param {bool}    [_skipCenter=true]  Whether to skip the center position
/// @param {real}    [_dist=1]           The distance from center to iterate
/// @param {bool}    [_cardinalOnly=true] Whether to only include cardinal directions (N,S,E,W)
/// @description                Iterates over adjacent cells in a 2D array around a given position.
///                             Calls callback with (value, array, [x, y]) for each adjacent element.
function array_2d_foreach_adjacent(
	_arr,
	_pos,
	_func,
	_skipCenter = true,
	_dist = 1,
	_cardnialOnly = true
) {
	var _xC = _pos[X];
	var _yC = _pos[Y];

	for (var _x = _xC - _dist; _x <= _xC + _dist; _x++) {
		for (var _y = _yC - _dist; _y <= _yC + _dist; _y++) {
			if (!array_2d_is_in_bounds(_arr, [_x, _y])) {
				continue;
			}
			
			// Skip center cell if requested
			if (_skipCenter && _x == _xC && _y == _yC) {
				continue;
			}
			
			// Skip non-cardinal cells if cardinal only mode
			if (_cardnialOnly && abs(_x - _xC) + abs(_y - _yC) > _dist) {
				continue;
			}
			
			var _val = _arr[_x][_y];
			_func(_val, _arr, [_x, _y]);
		}
	}
}

/// @function                   array_2d_foreach_area(_arr, _pos, _area, _func)
/// @param {array}   _arr        The 2D array to iterate over
/// @param {array}   _pos        The top-left position [x, y] of the area
/// @param {array}   _area       The dimensions [width, height] of the area to iterate
/// @param {method}  _func       The callback function to call for each element
/// @description                Iterates over a rectangular area in a 2D array, calling the callback
///                             with (value, array, [x, y]) for each element within the area
function array_2d_foreach_area(_arr, _pos, _area, _func) {
	var _x1 = _pos[X];
	var _y1 = _pos[Y];
	for (var _x = _x1; _x < _x1 + _area[X]; _x++) {
		for (var _y = _y1; _y < _y1 + _area[Y]; _y++) {
			if (!array_2d_is_in_bounds(_arr, [_x, _y])) {
				continue;
			}
			_func(_arr[_x][_y], _arr, [_x, _y]);
		}
	}
}

/// @function                   array_2d_get(_arr, _pos)
/// @param {array}   _arr        The 2D array to get a value from
/// @param {array}   _pos        The position [x, y] to retrieve
/// @returns {any}              The value at the specified position, or EMPTY if out of bounds
/// @description                Safely retrieves a value from a 2D array, returning EMPTY if the
///                             position is out of bounds
function array_2d_get(_arr, _pos) {
	if (!array_2d_is_in_bounds(_arr, _pos)) {
		return EMPTY;
	}

	return _arr[_pos[X]][_pos[Y]];
}

/// @function                   array_2d_init(_width, _height, _value, [_clone])
/// @param {real}    _width      The width of the array to create
/// @param {real}    _height     The height of the array to create
/// @param {any}     _value      The value to fill the array with
/// @param {bool}    [_clone=false] Whether to clone the value for each cell
/// @returns {array}            The newly created 2D array
/// @description                Creates a new 2D array filled with the specified value.
///                             Fixed: Now properly initializes sub-arrays before assignment.
function array_2d_init(_width, _height, _value, _clone = false) {
	var _arr = [];
	for (var _x = 0; _x < _width; _x++) {
		// Initialize the row as an array before assigning values
		_arr[_x] = [];
		for (var _y = 0; _y < _height; _y++) {
			_arr[_x][_y] = _clone ? variable_clone(_value) : _value;
		}
	}
	return _arr;
}

/// @function                   array_2d_is_in_bounds(_arr, _pos)
/// @param {array}   _arr        The 2D array to check
/// @param {array}   _pos        The position [x, y] to check
/// @returns {bool}             Whether the position is within the array bounds
/// @description                Checks if a given position is within the bounds of a 2D array
function array_2d_is_in_bounds(_arr, _pos) {
	return _pos[X] >= 0
		&& _pos[X] < array_length(_arr)
		&& _pos[Y] >= 0
		&& _pos[Y] < array_length(_arr[0]);
}

/// @function                   array_2d_set(_arr, _pos, _val)
/// @param {array}   _arr        The 2D array to modify
/// @param {array}   _pos        The position [x, y] to set
/// @param {any}     _val        The value to set
/// @description                Sets a value in a 2D array at the specified position.
///                             Throws an error if the position is out of bounds.
function array_2d_set(_arr, _pos, _val) {
	if (!array_2d_is_in_bounds(_arr, _pos)) {
		throw "Attempted to set OOB value for 2D Array";
	}
	_arr[_pos[X]][_pos[Y]] = _val;
}

/// @function                   array_2d_set_area(_arr, _pos, _w, _h, _val)
/// @param {array}   _arr        The 2D array to modify
/// @param {array}   _pos        The top-left position [x, y] of the area
/// @param {real}    _w          The width of the area to set
/// @param {real}    _h          The height of the area to set
/// @param {any}     _val        The value to set
/// @description                Sets all values in a rectangular area of a 2D array to the specified value
function array_2d_set_area(_arr, _pos, _w, _h, _val) {
	for (var _x = _pos[X]; _x < _pos[X] + _w; _x++) {
		for (var _y = _pos[Y]; _y < _pos[Y] + _h; _y++) {
			if (!array_2d_is_in_bounds(_arr, [_x, _y])) {
				continue;
			}
			_arr[_x][_y] = _val;
		}
	}
}

/// @function                   array_3d_foreach(_arr, _func)
/// @param {array}   _arr        The 3D array to iterate over
/// @param {method}  _func       The callback function to call for each element
/// @description                Iterates over every element in a 3D array, calling the callback
///                             with (value, array, [x, y, z]) for each element
function array_3d_foreach(_arr, _func) {
	var _width = array_length(_arr);
	var _height = array_length(_arr[0]);
	var _depth = array_length(_arr[0][0]);

	for (var _x = 0; _x < _width; _x++) {
		for (var _y = 0; _y < _height; _y++) {
			for (var _z = 0; _z < _depth; _z++) {
				_func(_arr[_x][_y][_z], _arr, [_x, _y, _z]);
			}
		}
	}
}

/// @function                   array_3d_foreach_adjacent(_arr, _pos, _func, [_skipCenter], [_dist], [_cardinalOnly])
/// @param {array}   _arr        The 3D array to iterate over
/// @param {array}   _pos        The center position [x, y, z] to iterate around
/// @param {method}  _func       The callback function to call for each adjacent element
/// @param {bool}    [_skipCenter=true]  Whether to skip the center position
/// @param {real}    [_dist=1]           The distance from center to iterate
/// @param {bool}    [_cardinalOnly=true] Whether to only include cardinal directions
/// @description                Iterates over adjacent cells in a 3D array around a given position.
///                             Calls callback with (value, array, [x, y, z]) for each adjacent element.
///                             Fixed: Center-skip and cardinal-only logic now properly implemented.
function array_3d_foreach_adjacent(
	_arr,
	_pos,
	_func,
	_skipCenter = true,
	_dist = 1,
	_cardnialOnly = true
) {
	var _xC = _pos[X];
	var _yC = _pos[Y];
	var _zC = _pos[Z];

	for (var _x = _xC - _dist; _x <= _xC + _dist; _x++) {
		for (var _y = _yC - _dist; _y <= _yC + _dist; _y++) {
			for (var _z = _zC - _dist; _z <= _zC + _dist; _z++) {
				if (!array_3d_is_in_bounds(_arr, [_x, _y, _z])) {
					continue;
				}
				
				// Skip center cell if requested
				if (_skipCenter && _x == _xC && _y == _yC && _z == _zC) {
					continue;
				}
				
				// Skip non-cardinal cells if cardinal only mode
				// Cardinal neighbors are those where exactly one axis differs by exactly _dist
				if (_cardnialOnly) {
					var _diffX = abs(_x - _xC);
					var _diffY = abs(_y - _yC);
					var _diffZ = abs(_z - _zC);
					
					// Count how many axes have a difference equal to _dist
					var _axesWithDist = (_diffX == _dist ? 1 : 0) + 
					                    (_diffY == _dist ? 1 : 0) + 
					                    (_diffZ == _dist ? 1 : 0);
					
					// Cardinal means exactly one axis differs by _dist, and others are 0
					var _otherAxesZero = (_diffX == 0 || _diffX == _dist) && 
					                     (_diffY == 0 || _diffY == _dist) && 
					                     (_diffZ == 0 || _diffZ == _dist);
					
					if (!(_axesWithDist == 1 && _otherAxesZero)) {
						continue;
					}
				}
				
				var _val = _arr[_x][_y][_z];
				_func(_val, _arr, [_x, _y, _z]);
			}
		}
	}
}

/// @function                   array_3d_foreach_area(_arr, _pos, _area, _func)
/// @param {array}   _arr        The 3D array to iterate over
/// @param {array}   _pos        The origin position [x, y, z] of the area
/// @param {array}   _area       The dimensions [width, height, depth] of the area to iterate
/// @param {method}  _func       The callback function to call for each element
/// @description                Iterates over a cubic area in a 3D array, calling the callback
///                             with (value, array, [x, y, z]) for each element within the area
function array_3d_foreach_area(_arr, _pos, _area, _func) {
	var _x1 = _pos[X];
	var _y1 = _pos[Y];
	var _z1 = _pos[Z];
	for (var _x = _x1; _x < _x1 + _area[X]; _x++) {
		for (var _y = _y1; _y < _y1 + _area[Y]; _y++) {
			for (var _z = _z1; _z < _z1 + _area[Z]; _z++) {
				if (!array_3d_is_in_bounds(_arr, [_x, _y, _z])) {
					continue;
				}
				_func(_arr[_x][_y][_z], _arr, [_x, _y, _z]);
			}
		}
	}
}

/// @function                   array_3d_get(_arr, _pos)
/// @param {array}   _arr        The 3D array to get a value from
/// @param {array}   _pos        The position [x, y, z] to retrieve
/// @returns {any}              The value at the specified position, or EMPTY if out of bounds
/// @description                Safely retrieves a value from a 3D array, returning EMPTY if the
///                             position is out of bounds
function array_3d_get(_arr, _pos) {
	if (!array_3d_is_in_bounds(_arr, _pos)) {
		return EMPTY;
	}

	return _arr[_pos[X]][_pos[Y]][_pos[Z]];
}

/// @function                   array_3d_init(_width, _height, _depth, _value, [_clone])
/// @param {real}    _width      The width of the array to create
/// @param {real}    _height     The height of the array to create
/// @param {real}    _depth      The depth of the array to create
/// @param {any}     _value      The value to fill the array with
/// @param {bool}    [_clone=false] Whether to clone the value for each cell
/// @returns {array}            The newly created 3D array
/// @description                Creates a new 3D array filled with the specified value.
///                             Fixed: Now properly initializes sub-arrays before assignment.
function array_3d_init(_width, _height, _depth, _value, _clone = false) {
	var _arr = [];
	for (var _x = 0; _x < _width; _x++) {
		// Initialize the row as an array
		_arr[_x] = [];
		for (var _y = 0; _y < _height; _y++) {
			// Initialize the column as an array
			_arr[_x][_y] = [];
			for (var _z = 0; _z < _depth; _z++) {
				_arr[_x][_y][_z] = _clone ? variable_clone(_value) : _value;
			}
		}
	}
	return _arr;
}

/// @function                   array_3d_is_in_bounds(_arr, _pos)
/// @param {array}   _arr        The 3D array to check
/// @param {array}   _pos        The position [x, y, z] to check
/// @returns {bool}             Whether the position is within the array bounds
/// @description                Checks if a given position is within the bounds of a 3D array
function array_3d_is_in_bounds(_arr, _pos) {
	return _pos[X] >= 0
		&& _pos[X] < array_length(_arr)
		&& _pos[Y] >= 0
		&& _pos[Y] < array_length(_arr[0])
		&& _pos[Z] >= 0
		&& _pos[Z] < array_length(_arr[0][0]);
}

/// @function                   array_3d_set(_arr, _pos, _val)
/// @param {array}   _arr        The 3D array to modify
/// @param {array}   _pos        The position [x, y, z] to set
/// @param {any}     _val        The value to set
/// @description                Sets a value in a 3D array at the specified position.
///                             Throws an error if the position is out of bounds.
function array_3d_set(_arr, _pos, _val) {
	if (!array_3d_is_in_bounds(_arr, _pos)) {
		throw "Attempted to set OOB value for 3D Array";
	}
	_arr[_pos[X]][_pos[Y]][_pos[Z]] = _val;
}