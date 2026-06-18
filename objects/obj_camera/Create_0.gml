var _max_h_scale = floor(DISP_W / BASE_W)
var _max_w_scale = floor(DISP_H / BASE_H)

window_scale = max(1, min(_max_h_scale, _max_w_scale))
window_set_size(BASE_W * window_scale, BASE_H * window_scale)
window_center()

surface_resize(APP_SURF, BASE_W * window_scale, BASE_H * window_scale)
display_set_gui_size(BASE_W, BASE_H)

damping = 0.12 //Sets the camera smoothing.

target = noone
zoneCurrent = undefined

shake = new Shake()

#region ==== FUNCTIONS ====

set_target = function(_instance, _startOnInstance = true) {
	target = _instance
	
	if (_startOnInstance)
		snap_to_target()
}

// A supprimer si la fonction n'est pas étoffée
setZone = function(_instance) {
	zoneCurrent = _instance
}

snap_to_target = function() {
	if (target != noone) {
		camera_set_view_pos(
			VIEW,
			target.x - VIEW_W / 2,
			target.y - VIEW_H / 2
		)
	}
}

set_target_point = function(_x, _y) {
	set_target({x: _x, y: _y})
}

#endregion
