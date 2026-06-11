/// @section Event System
/// @desc   A flexible event system that allows objects to subscribe to and raise custom events.
///        Listeners are stored in a global events struct and can be one-time or persistent.

// Global events storage
#macro EVENTS global.events
global.events = {};

/// @function   event_add_listener(_listener)
/// @param      {EventListener} _listener  The EventListener instance to register
/// @returns    {EventListener}            The registered listener (for chaining)
/// @description                           Registers an event listener with the global event system.
///                                       Listeners are automatically sorted by priority (lower = higher priority).
///                                       If the event type doesn't exist yet, a new list is created.
function event_add_listener(_listener) {
	var _list = EVENTS[$ _listener.type];
	if (_list == undefined) {
		_list = [];
		EVENTS[$ _listener.type] = _list;  // Fixed: Was using _listener.type but storing under _listener
	}
	array_push(_list, _listener);
	
	// Sort by priority (lower number = higher priority, runs first)
	array_sort(_list, function(_a, _b) {
		return _a.priority < _b.priority;
	});

	return _listener;
}

/// @function   event_remove_listener(_listener)
/// @param      {EventListener} _listener  The EventListener instance to remove
/// @description                           Removes a specific event listener from the global event system.
///                                       If the listener isn't found, nothing happens.
function event_remove_listener(_listener) {
	var _list = EVENTS[$ _listener.type];
	if (_list == undefined) {
		return;  // Guard against undefined list
	}
	
	for (var _i = 0; _i < array_length(_list); _i++) {
		if (_list[_i] != _listener) {
			continue;
		}

		array_delete(_list, _i, 1);
		return;
	}
}

/// @function   event_raise(_type, [_data])
/// @param      {string} _type            The event type to raise
/// @param      {any}    [_data=undefined] Optional data to pass to listeners
/// @description                          Raises an event, executing all registered listeners of that type.
///                                      Listeners with destroyed owners or marked as one-time are
///                                      automatically removed after execution.
function event_raise(_type, _data = undefined) {
	var _list = EVENTS[$ _type];
	if (_list == undefined) {
		return;  // Guard against undefined list
	}
	
	for (var _i = 0; _i < array_length(_list); _i++) {
		var _listener = _list[_i];
		var _instExists = instance_exists(_listener.owner);
		
		if (_instExists) {
			_listener.callback(_data);
		}
		
		// Remove listener if owner is destroyed or it's a one-shot listener
		if (!_instExists || _listener.onlyOnce) {
			array_delete(_list, _i, 1);
			_i--;
		}
	}
}

/// @class    EventListener
/// @desc     Represents a listener for a specific event type. Created automatically by the event system
///           or can be instantiated manually for custom behavior.
/// @param    {method}  _callback    The function to call when the event is raised
/// @param    {string}  _type        The event type string to listen for
/// @param    {bool}    [_onlyOnce=false] Whether to automatically remove after first execution
/// @param    {real}    [_priority=0]     The priority (lower = higher priority, runs first)
/// @param    {instance} [_owner=other.id] The instance that owns this listener
function EventListener(
	_callback,
	_type,
	_onlyOnce = false,
	_priority = 0,
	_owner = other.id
) constructor {
	/// @member {string}   type        The event type this listener responds to
	type = _type;
	/// @member {instance} owner       The instance that owns this listener (for lifecycle management)
	owner = _owner;
	/// @member {method}   callback    The function to execute when the event is raised
	callback = _callback;
	/// @member {bool}     onlyOnce    Whether this listener is removed after first execution
	onlyOnce = _onlyOnce;
	/// @member {real}     priority    Sort priority (lower numbers execute first)
	priority = _priority;
}

/// @class    EventGameLoaded
/// @extends  EventListener
/// @desc     Event listener specifically for the game loaded event.
/// @param    {method}  _callback    The function to call when the game is loaded
function EventGameLoaded(_callback) : EventListener(
	_callback,
	EventGameLoaded
) constructor {}

/// @class    EventLocationChanged
/// @extends  EventListener
/// @desc     Event listener for when the location changes.
///           FIXED: Was incorrectly using EventGameLoaded as the event type.
/// @param    {method}  _callback    The function to call when the location changes
function EventLocationChanged(_callback) : EventListener(
	_callback,
	EventLocationChanged
) constructor {}

/// @class    EventLanderReturned
/// @extends  EventListener
/// @desc     Event listener for when the lander returns.
/// @param    {method}  _callback    The function to call when the lander returns
function EventLanderReturned(_callback) : EventListener(
	_callback,
	EventLanderReturned
) constructor {}

/// @class    EventLeftSystem
/// @extends  EventListener
/// @desc     Event listener for when leaving a system.
/// @param    {method}  _callback    The function to call when leaving a system
function EventLeftSystem(_callback) : EventListener(
	_callback,
	EventLeftSystem
) constructor {}

/// @class    EventEnteredSystem
/// @extends  EventListener
/// @desc     Event listener for when entering a system.
/// @param    {method}  _callback    The function to call when entering a system
function EventEnteredSystem(_callback) : EventListener(
	_callback,
	EventEnteredSystem
) constructor {}