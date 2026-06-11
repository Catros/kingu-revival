/// @function   collision_line_point(x1, y1, x2, y2, obj, prec, notme)
/// @param      {real}    x1        Start x of the line
/// @param      {real}    y1        Start y of the line
/// @param      {real}    x2        End x of the line
/// @param      {real}    y2        End y of the line
/// @param      {object}  obj       The object to check collision with
/// @param      {bool}    prec      Whether to use precise collision checking
/// @param      {bool}    notme     Whether to exclude the calling instance
/// @returns    {array}             Array containing [instance_id, collision_x, collision_y]
/// @description                    Performs a binary search along a line to find the exact point of
///                                 collision with an object. Returns the collided instance and the
///                                 precise collision coordinates.
///                                 Original algorithm by YellowAfterLife.
function collision_line_point(x1, y1, x2, y2, obj, prec, notme) {
	var rr, rx, ry;
	
	// Check if there's any collision along the line
	rr = collision_line(x1, y1, x2, y2, obj, prec, notme);
	rx = x2;
	ry = y2;
	
	if (rr != noone) {
		var p0 = 0;  // Start of search segment (no collision)
		var p1 = 1;  // End of search segment (collision)
		
		// Binary search for precise collision point
		// Number of iterations based on line length for optimal precision
		repeat (ceil(log2(point_distance(x1, y1, x2, y2))) + 1) {
			var np = p0 + (p1 - p0) * 0.5;  // Midpoint interpolation factor
			var nx = x1 + (x2 - x1) * np;   // Test x at midpoint
			var ny = y1 + (y2 - y1) * np;   // Test y at midpoint
			var px = x1 + (x2 - x1) * p0;   // Start x of search segment
			var py = y1 + (y2 - y1) * p0;   // Start y of search segment
			
			// Check collision from p0 to midpoint
			var nr = collision_line(px, py, nx, ny, obj, prec, notme);
			
			if (nr != noone) {
				// Collision found, search closer to start
				rr = nr;
				rx = nx;
				ry = ny;
				p1 = np;
			} else {
				// No collision, search further from start
				p0 = np;
			}
		}
	}
	
	// Build and return result array
	var r = [];
	r[0] = rr;   // Instance ID (or noone)
	r[1] = rx;   // Collision x coordinate
	r[2] = ry;   // Collision y coordinate
	return r;
}

/// @function   collision_line_width(_x1, _y1, _x2, _y2, _w, _obj)
/// @param      {real}    _x1       Start x of the line
/// @param      {real}    _y1       Start y of the line
/// @param      {real}    _x2       End x of the line
/// @param      {real}    _y2       End y of the line
/// @param      {real}    _w        Width of the collision line
/// @param      {object}  _obj      The object to check collision with
/// @returns    {bool}              Whether a collision was detected
/// @description                    Performs a thick line collision check using a sensor object.
///                                 Requires an object (default: obj_sensor) with:
///                                 - Sprite taller than 32px
///                                 - Rotated Rectangle collision mask
///                                 - Middle-left origin
///                                 If the sensor object doesn't exist, it will be created automatically.
function collision_line_width(_x1, _y1, _x2, _y2, _w, _obj) {
	// Create sensor object if it doesn't exist
	if (!instance_exists(obj_sensor)) {
		instance_create_depth(0, 0, 0, obj_sensor);
	}
	
	with (obj_sensor) {
		x = _x1;
		y = _y1;
		image_angle = point_direction(_x1, _y1, _x2, _y2);
		
		// Scale x to match line length
		image_xscale = point_distance(_x1, _y1, _x2, _y2) / sprite_get_width(sprite_index);
		// Scale y to match desired thickness
		image_yscale = _w / sprite_get_height(sprite_index);

		return place_meeting(x, y, _obj);
	}
}

/// @function   collision_point_line_to_rectangle(l_x1, l_y1, l_x2, l_y2, r_x1, r_y1, r_x2, r_y2)
/// @param      {real}    _x1       Line start x
/// @param      {real}    _y1       Line start y
/// @param      {real}    _x2       Line end x
/// @param      {real}    _y2       Line end y
/// @param      {real}    _x3       Rectangle left x
/// @param      {real}    _y3       Rectangle top y
/// @param      {real}    _x4       Rectangle right x
/// @param      {real}    _y4       Rectangle bottom y
/// @returns    {array|noone}        Array [x, y] of intersection point, or noone if no intersection
/// @description                    Finds the intersection point between a line segment and a rectangle.
///                                 Checks each edge of the rectangle in order (top, left, right, bottom).
///                                 Always check if the return value is an array before using.
function collision_point_line_to_rectangle(_x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4) {
	var _point;
	
	// Check intersection with top edge
	_point = line_intersect_point(_x1, _y1, _x2, _y2, _x3, _y3, _x4, _y3);
	if (is_array(_point)) {
		return _point;
	}

	// Check intersection with left edge
	_point = line_intersect_point(_x1, _y1, _x2, _y2, _x3, _y3, _x3, _y4);
	if (is_array(_point)) {
		return _point;
	}
	
	// Check intersection with right edge
	_point = line_intersect_point(_x1, _y1, _x2, _y2, _x4, _y3, _x4, _y4);
	if (is_array(_point)) {
		return _point;
	}
	
	// Check intersection with bottom edge
	_point = line_intersect_point(_x1, _y1, _x2, _y2, _x3, _y4, _x4, _y4);
	if (is_array(_point)) {
		return _point;
	}

	return noone;
}

/// @function   lines_intersect(x1, y1, x2, y2, x3, y3, x4, y4, segment)
/// @param      {real}    _x1       First line start x
/// @param      {real}    _y1       First line start y
/// @param      {real}    _x2       First line end x
/// @param      {real}    _y2       First line end y
/// @param      {real}    _x3       Second line start x
/// @param      {real}    _y3       Second line start y
/// @param      {real}    _x4       Second line end x
/// @param      {real}    _y4       Second line end y
/// @param      {bool}    _segment  Whether to confine test to line segments
/// @returns    {real}              The parametric multiplier (t) for intersection on the first line.
///                                 0 indicates no intersection (or intersection at start point).
///                                 0 < t <= 1 indicates intersection within the first line segment.
/// @description                    Calculates the intersection of two lines using parametric equations.
///                                 The return value (t) can be used to find the intersection point:
///                                 x = x1 + t * (x2 - x1)
///                                 y = y1 + t * (y2 - y1)
///                                 Source: GMLscripts.com
function lines_intersect(_x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _segment) {
	var ua, ub, ud, ux, uy, vx, vy, wx, wy;
	ua = 0;
	
	// Direction vector of first line
	ux = _x2 - _x1;
	uy = _y2 - _y1;
	
	// Direction vector of second line
	vx = _x4 - _x3;
	vy = _y4 - _y3;
	
	// Vector between line start points
	wx = _x1 - _x3;
	wy = _y1 - _y3;
	
	// Calculate denominator (cross product of direction vectors)
	ud = vy * ux - vx * uy;
	
	if (ud != 0) {
		// Lines are not parallel, calculate intersection parameter
		ua = (vx * wy - vy * wx) / ud;
		
		if (_segment) {
			// Calculate parameter for second line
			ub = (ux * wy - uy * wx) / ud;
			
			// Check if intersection is within both line segments
			if (ua < 0 || ua > 1 || ub < 0 || ub > 1) {
				ua = 0;  // Intersection outside segment bounds
			}
		}
	}
	
	return ua;
}

/// @function   line_intersect_point(x1, y1, x2, y2, x3, y3, x4, y4)
/// @param      {real}    _x1       First line start x
/// @param      {real}    _y1       First line start y
/// @param      {real}    _x2       First line end x
/// @param      {real}    _y2       First line end y
/// @param      {real}    _x3       Second line start x
/// @param      {real}    _y3       Second line start y
/// @param      {real}    _x4       Second line end x
/// @param      {real}    _y4       Second line end y
/// @returns    {array|noone}        Array [x, y] of intersection point, or noone if no intersection
/// @description                    Finds the exact intersection point between two line segments.
///                                 Returns the coordinates as an array, or noone if the lines don't intersect.
function line_intersect_point(_x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4) {
	var _t = lines_intersect(_x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, true);
	
	if (_t > 0 && _t <= 1) {
		var _point = [];  // Initialize array before assignment
		_point[0] = _x1 + _t * (_x2 - _x1);
		_point[1] = _y1 + _t * (_y2 - _y1);

		return _point;
	} else {
		return noone;
	}
}