/// @section Display Macros
/// @desc   Convenience macros for commonly accessed display, window, surface, and view properties.

// Base resolution constants
#macro BASE_W 1920
#macro BASE_H 1080
#macro BASE_ASPECT (BASE_W / BASE_H)

// Display (monitor) dimensions
#macro DISP_W display_get_width()
#macro DISP_H display_get_height()

// Window dimensions and state
#macro WIN_W window_get_width()
#macro WIN_H window_get_height()
#macro WIN_GET_FULL window_get_fullscreen()

// Application surface
#macro APP_SURF application_surface
#macro APP_W surface_get_width(APP_SURF)
#macro APP_H surface_get_height(APP_SURF)
#macro APP_ASPECT (APP_W / APP_H)

// Current view (View 0)
#macro VIEW view_camera[0]
#macro VIEW_X camera_get_view_x(VIEW)
#macro VIEW_Y camera_get_view_y(VIEW)
#macro VIEW_W camera_get_view_width(VIEW)
#macro VIEW_H camera_get_view_height(VIEW)
#macro VIEW_R (VIEW_X + VIEW_W)        // Right edge
#macro VIEW_B (VIEW_Y + VIEW_H)        // Bottom edge
#macro VIEW_CENTER_X (VIEW_X + VIEW_W / 2)
#macro VIEW_CENTER_Y (VIEW_Y + VIEW_H / 2)
#macro VIEW_ASPECT (VIEW_W / VIEW_H)

// GUI layer dimensions
#macro GUI_W display_get_gui_width()
#macro GUI_H display_get_gui_height()
#macro GUI_ASPECT (GUI_W / GUI_H)

/// @section Window Resize Detection
/// @desc   Properly implemented window resize detection system.
///         Stores previous dimensions and provides a callback for resize events.

/// @function   display_init_resize_detection([_callback])
/// @param      {method} [_callback]   Function to call when window is resized
/// @description                       Initializes the window resize detection system.
///                                   The callback receives {width, height, prevWidth, prevHeight} struct.
///                                   Call this once at game start.
function display_init_resize_detection(_callback = undefined) {
	if (struct_exists(global.display, "resizeDetection")) {
		// Clean up existing detection if reinitializing
		display_cleanup_resize_detection();
	}
	
	global.display.resizeDetection = {
		width: WIN_W,
		height: WIN_H,
		callback: _callback,
		isActive: true,
		timeSource: call_later(
			10,  // Check every 10 frames (reduced from 5 to minimize overhead)
			time_source_units_frames,
			method({}, function() {
				var _detection = global.display.resizeDetection;
				
				// Skip if detection was deactivated
				if (!_detection.isActive) {
					return;
				}
				
				var _currentW = WIN_W;
				var _currentH = WIN_H;
				
				// Check if dimensions changed
				if (_currentW == _detection.width && _currentH == _detection.height) {
					return;
				}
				
				// Store previous values for callback
				var _prevW = _detection.width;
				var _prevH = _detection.height;
				
				// Update stored values
				_detection.width = _currentW;
				_detection.height = _currentH;
				
				// Fire callback if provided
				if (_detection.callback != undefined) {
					_detection.callback({
						width: _currentW,
						height: _currentH,
						prevWidth: _prevW,
						prevHeight: _prevH,
					});
				}
			}),
			true  // Repeat
		),
	};
}

/// @function   display_cleanup_resize_detection()
/// @description                       Cleans up the resize detection time source.
///                                   Call this when no longer needed (e.g., game end).
function display_cleanup_resize_detection() {
	if (!struct_exists(global.display, "resizeDetection")) {
		return;
	}
	
	var _detection = global.display.resizeDetection;
	_detection.isActive = false;
	
	if (time_source_exists(_detection.timeSource)) {
		time_source_destroy(_detection.timeSource);
	}
	
	struct_remove(global.display, "resizeDetection");
}

// Usage example:
// display_init_resize_detection(function(_info) {
//     show_debug_message($"Window resized: {_info.prevWidth}x{_info.prevHeight} -> {_info.width}x{_info.height}");
//     // Handle surface resizing, UI updates, etc.
// });