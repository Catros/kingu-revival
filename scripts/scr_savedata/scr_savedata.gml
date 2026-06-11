/// @section Save System
/// @desc   Robust JSON-based save system with error handling, backup support,
///         and proper separation of settings and save data.

// Initialize global data structures
global.data = {};
global.settings = {fullscreen: false, windowScale: 1};

// File naming macros
#macro SETTINGS_FILE_NAME "settings.json"  // FIXED: Using .json extension for clarity
#macro SETTINGS global.settings
#macro SAVE_FILE_NAME "save"
#macro SAVE_FILE_EXT ".json"              // Added extension macro for consistency
#macro DATA global.data

/// @function   __write_file(_filename, _data)
/// @param      {string} _filename   The file to write to
/// @param      {struct} _data       The data struct to save
/// @description                     Writes data to a file in formatted JSON.
///                                 Creates backup of existing file before overwriting.
function __write_file(_filename, _data) {
	// Create backup of existing file if it exists
	if (file_exists(_filename)) {
		var _backupName = _filename + ".bak";
		if (file_exists(_backupName)) {
			file_delete(_backupName);
		}
		file_copy(_filename, _backupName);
	}
	
	var _file = file_text_open_write(_filename);
	file_text_write_string(_file, json_stringify(_data, true));  // Pretty-print for readability
	file_text_close(_file);
}

/// @function   __load_file(_filename)
/// @param      {string} _filename       The file to read from
/// @returns    {struct|undefined}       The parsed data, or undefined on failure
/// @description                         Loads and parses JSON data with error recovery.
function __load_file(_filename) {
	if (!file_exists(_filename)) {
		return undefined;
	}

	var _json_string = "";
	
	// Attempt to read the file
	try {
		var _file = file_text_open_read(_filename);
		_json_string = file_text_read_string(_file);
		file_text_close(_file);
	} catch (_error) {
		show_debug_message($"Error reading file {_filename}: {_error}");
		// Try loading backup if main file is corrupted
		var _backupName = _filename + ".bak";
		if (file_exists(_backupName)) {
			show_debug_message($"Attempting to load backup: {_backupName}");
			try {
				var _backupFile = file_text_open_read(_backupName);
				_json_string = file_text_read_string(_backupFile);
				file_text_close(_backupFile);
			} catch (_backupError) {
				show_debug_message($"Backup also corrupted: {_backupError}");
				return undefined;
			}
		} else {
			return undefined;
		}
	}
	
	// Parse JSON string
	if (_json_string == "") {
		return undefined;
	}
	
	var _data = json_parse(_json_string);
	if (_data == undefined) {
		show_debug_message($"Failed to parse JSON from {_filename}");
		// Attempt to recover by trying backup
		var _backupName = _filename + ".bak";
		if (file_exists(_backupName)) {
			show_debug_message($"Attempting to load backup after parse failure");
			var _backupFile = file_text_open_read(_backupName);
			var _backupJson = file_text_read_string(_backupFile);
			file_text_close(_backupFile);
			_data = json_parse(_backupJson);
			if (_data != undefined) {
				show_debug_message("Backup loaded successfully");
			}
		}
	}
	
	return _data;
}

/// @function   save_data([_slot])
/// @param      {real} [_slot=0]     The save slot number (0-9)
/// @returns    {bool}               Whether the save was successful
/// @description                     Saves global.data to a numbered save slot.
function save_data(_slot = 0) {
	_slot = clamp(floor(_slot), 0, 9);  // Limit to valid range
	var _filename = SAVE_FILE_NAME + string(_slot) + SAVE_FILE_EXT;
	
	__write_file(_filename, global.data);
	
	// Verify save was written
	if (file_exists(_filename)) {
		show_debug_message($"Data saved to slot {_slot}");
		return true;
	} else {
		show_debug_message($"Failed to save data to slot {_slot}");
		return false;
	}
}

/// @function   load_data([_slot])
/// @param      {real} [_slot=0]     The save slot number
/// @returns    {bool}               Whether data was successfully loaded
/// @description                     Loads data from a save slot into global.data.
///                                 Does not load if save file doesn't exist.
function load_data(_slot = 0) {
	_slot = clamp(floor(_slot), 0, 9);
	var _filename = SAVE_FILE_NAME + string(_slot) + SAVE_FILE_EXT;
	
	var _loaded = __load_file(_filename);
	if (_loaded != undefined) {
		global.data = _loaded;
		show_debug_message($"Data loaded from slot {_slot}");
		return true;
	} else {
		show_debug_message($"No save data in slot {_slot}");
		return false;
	}
}

/// @function   delete_save_data([_slot])
/// @param      {real} [_slot=0]     The save slot to delete
/// @returns    {bool}               Whether deletion was successful
/// @description                     Deletes a save slot file.
function delete_save_data(_slot = 0) {
	_slot = clamp(floor(_slot), 0, 9);
	var _filename = SAVE_FILE_NAME + string(_slot) + SAVE_FILE_EXT;
	
	if (file_exists(_filename)) {
		file_delete(_filename);
		return true;
	}
	return false;
}

/// @function   write_settings()
/// @returns    {bool}               Whether settings were saved successfully
/// @description                     Saves global.settings to the settings file.
function write_settings() {
	__write_file(SETTINGS_FILE_NAME, global.settings);
	return true;
}

/// @function   load_settings()
/// @returns    {bool}               Whether settings were loaded successfully
/// @description                     Loads settings from file into global.settings.
function load_settings() {
	var _loaded = __load_file(SETTINGS_FILE_NAME);
	if (_loaded != undefined) {
		// Merge loaded settings with defaults to handle new settings keys
		struct_foreach(global.settings, function(_key, _defaultValue) {
			if (_loaded[$ _key] == undefined) {
				_loaded[$ _key] = _defaultValue;
			}
		});
		
		global.settings = _loaded;
		return true;
	} else {
		show_debug_message("No settings file, using defaults");
		return false;
	}
}

/// @function   reset_settings()
/// @description                     Resets settings to defaults and saves them.
function reset_settings() {
	global.settings = {fullscreen: false, windowScale: 1};
	write_settings();
}

// Auto-load settings on game start
load_settings();