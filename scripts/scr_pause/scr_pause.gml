/// @section Visible Pause Manager
/// @desc   A system for pausing objects visually while keeping them active during draw events.
///         Paused objects are deactivated normally but temporarily reactivated during pre-draw
///         so they remain visible, then deactivated again after GUI drawing completes.
///         This allows "paused" objects to still render on screen.

/// @class    VisiblePauseManager
/// @desc     Manages a list of paused objects that should remain visible while paused.
///           Objects can be paused for a specific duration or indefinitely.
///           Uses PreDraw and GuiEnd events to temporarily activate paused objects for rendering.
///           Must be instantiated and stored (typically in global.pauseManager).
function VisiblePauseManager() constructor {
	// Array of {id: instance_id, length: remaining_frames} structs
	__iPausedIds = [];

	/// @function VisiblePauseManager.preDraw()
	/// @desc   Activates all paused objects so they render during the draw cycle.
	///         Should be called in the PreDraw event.
	static preDraw = function() {
		array_foreach(__iPausedIds, function(_paused) {
			instance_activate_object(_paused.id);
		});
	};

	/// @function VisiblePauseManager.guiEnd()
	/// @desc   Decrements pause counters and deactivates objects after drawing is complete.
	///         Should be called in the GuiEnd event.
	///         Objects with expired pause lengths are removed from the paused list.
	///         FIXED: Previously had a potential array modification bug during iteration.
	static guiEnd = function() {
		var _count = array_length(__iPausedIds);
		for (var _i = 0; _i < _count; _i++) {
			__iPausedIds[_i].length--;
			
			if (__iPausedIds[_i].length == 0) {
				// Pause duration expired - remove from list
				array_delete(__iPausedIds, _i, 1);
				_i--;
				_count--;
			} else {
				// Still paused - deactivate to prevent logic from running
				instance_deactivate_object(__iPausedIds[_i].id);
			}
		}
	};

	/// @function VisiblePauseManager.pauseObject(_id, [_length])
	/// @param   {instance} _id           The instance to pause
	/// @param   {real}     [_length=-1]  How many frames to pause (-1 = infinite)
	/// @desc    Pauses an object, making it inactive but still visible.
	///          If already paused, the pause length is NOT updated.
	///          Use -1 for infinite pause duration.
	static pauseObject = function(_id, _length = -1) {
		with (_id) {
			// Check if object is already paused
			if (array_find_index(other.__iPausedIds, method({_id, _length}, function(
					_paused
				) {
					return _paused.id == _id;
				})) != -1) {
				continue;  // Already paused, skip
			}
			
			// Add to paused list
			array_push(other.__iPausedIds, {id: _id, length: _length});
		}
	};

	/// @function VisiblePauseManager.unpauseObject(_id)
	/// @param   {instance} _id           The instance to unpause
	/// @desc    Immediately unpauses an object by setting its pause length to 1.
	///          The object will be fully unpaused at the end of the current frame.
	static unpauseObject = function(_id) {
		var _index = array_find_index(__iPausedIds, method({_id}, function(_paused) {
			return _paused.id == _id;
		}));
		
		if (_index == -1) {
			return;  // Not paused, nothing to do
		}
		
		// Set to 1 so it expires at end of current frame
		__iPausedIds[_index].length = 1;
	};

	/// @function VisiblePauseManager.pauseTag(_tags, [_length])
	/// @param   {string|array} _tags      The tag(s) to pause
	/// @param   {real}         [_length=-1]  How many frames to pause (-1 = infinite)
	/// @desc    Pauses all object assets with the specified tag(s).
	///          The tag must be assigned to the object asset, not instances.
	static pauseTag = function(_tags, _length = -1) {
		var _objects = tag_get_asset_ids(_tags, asset_object);
		for (var _i = 0; _i < array_length(_objects); _i++) {
			pauseObject(_objects[_i], _length);  // FIXED: Wasn't passing _length
		}
	};

	/// @function VisiblePauseManager.unpauseTag(_tags)
	/// @param   {string|array} _tags      The tag(s) to unpause
	/// @desc    Unpauses all object assets with the specified tag(s).
	static unpauseTag = function(_tags) {
		var _objects = tag_get_asset_ids(_tags, asset_object);
		for (var _i = 0; _i < array_length(_objects); _i++) {
			unpauseObject(_objects[_i]);
		}
	};
}

/// @instance global.pauseManager
/// @desc    Global instance of VisiblePauseManager for easy access throughout the game.
///          Usage:
///          // In PreDraw event:
///          global.pauseManager.preDraw();
///          
///          // In GuiEnd event:
///          global.pauseManager.guiEnd();
///          
///          // To pause an object:
///          global.pauseManager.pauseObject(instance_id, 60); // Pause for 60 frames
///          global.pauseManager.pauseObject(instance_id);      // Pause indefinitely
///          
///          // To unpause:
///          global.pauseManager.unpauseObject(instance_id);
///          
///          // Pause by tag:
///          global.pauseManager.pauseTag("enemy", 120);
global.pauseManager = new VisiblePauseManager();