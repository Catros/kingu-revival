/// @class    Library
/// @desc     A generic collection class that allows storing and retrieving values by key.
///           Provides methods for adding items and auto-assigning keys.
///           Note: This constructor pattern may be problematic in newer GML versions.
function Library() constructor {
	/// @function   Library.get(_key)
	/// @param      {string}  _key  The key to retrieve
	/// @returns    {any}           The value associated with the key
	/// @desc       Retrieves a value from the library by its key
	static get = function(_key) {
		return self[$ _key];
	};

	/// @function   Library.set_keys()
	/// @desc       Iterates through all static members and assigns their "key" property
	///             to match their variable name. Useful for objects that need to know their own key.
	static set_keys = function() {
		struct_foreach(static_get(self), function(_key, _val) {
			var _ref = static_get(self)[$ _key];
			if (_ref == undefined) {
				return;
			}

			_ref[$ "key"] = _key;
		});
	};

	/// @function   Library.add(_key, _value)
	/// @param      {string}  _key    The key to store the value under
	/// @param      {any}     _value  The value to store
	/// @desc       Adds a value to the library and assigns it a key property for self-reference
	static add = function(_key, _value) {
		self[$ _key] = _value;
		_value.key = _key;
	};
}

// REQUIRED DEPENDENCIES:
// - sin_oscillate(value_min, value_max, frequency)
// - approach(current, target, amount)

/// @class    Shake
/// @desc     A camera/object shake effect generator. Creates oscillating motion
///           with configurable direction, amplitude, frequency, and falloff.
///           Usage:
///           var shake = new Shake();
///           shake.start(45, 10, 0.5, 0.1);
///           // In step event:
///           var offset = shake.update();
///           x += offset.x;
///           y += offset.y;
function Shake() constructor {
	/// @member {real}  dir         The direction of the shake in degrees
	dir = 0;
	/// @member {real}  frequency   The speed/frequency of the oscillation
	frequency = 0.1;
	/// @member {real}  amp         The current amplitude of the shake
	amp = 0;
	/// @member {real}  falloff     How quickly the amplitude decreases per frame
	falloff = 1;
	/// @member {real}  startTime   The timer value when the shake started
	startTime = get_timer();
	/// @member {real}  x           The current x offset from the shake
	x = 0;
	/// @member {real}  y           The current y offset from the shake
	y = 0;

	/// @function Shake.start(_dir, _amp, [_falloff], [_frequency])
	/// @param    {real}  _dir        The direction of the shake in degrees
	/// @param    {real}  _amp        The maximum amplitude of the shake
	/// @param    {real}  [_falloff=1]   How quickly the shake decays (higher = faster decay)
	/// @param    {real}  [_frequency=0.1] The oscillation frequency
	/// @desc     Starts or restarts the shake effect with new parameters
	start = function(_dir, _amp, _falloff = 1, _frequency = 0.1) {
		dir = _dir;
		frequency = _frequency;
		amp = _amp;
		falloff = _falloff;
		startTime = get_timer();
	};

	/// @function Shake.update()
	/// @returns  {struct}   A struct with x and y properties representing the current offset
	/// @desc     Updates the shake effect and returns the current offset.
	///           Should be called once per frame. Returns {x: 0, y: 0} when shake is complete.
	update = function() {
		if (amp == 0) {
			x = 0;
			y = 0;
			return {x: 0, y: 0};
		}
		
		// Calculate oscillating amplitude (moves from -amp to +amp over time)
		var _amp = sin_oscillate(-amp, amp, frequency);
		
		// Convert polar coordinates (angle + distance) to cartesian offsets
		x = lengthdir_x(_amp, dir);
		y = lengthdir_y(_amp, dir);
		
		// Reduce amplitude towards 0 for falloff effect
		amp = approach(amp, 0, falloff);
		
		return {x: x, y: y};
	};
}