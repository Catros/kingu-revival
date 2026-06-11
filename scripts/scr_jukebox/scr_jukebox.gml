/// @section Jukebox System
/// @desc   A comprehensive music management system with queue support, crossfading,
///         ducking, volume control, and debug visualization.

// Global jukebox state stored in a persistent struct
#macro JUKEBOX global.__jukebox
JUKEBOX = {
	duckVolumeFactor: 0.25,      // Volume multiplier when ducked (0-1)
	priority: 100,                // Audio priority for sounds
	volume: 0.75,                 // Master volume (0-1)
	queue: [],                    // Array of songs in the queue
	queuePosition: 0,             // Current position in the queue
	queueCrossfadeLength: 2000,   // Default crossfade duration in ms
	currentSong: noone,           // Currently playing sound ID
	isDucked: false,              // Whether audio is currently ducked
	currentVolume: 1,             // Current effective volume after ducking
	timeSource: noone,            // Time source for tracking song length
	debugView: undefined,         // Debug view ID for the jukebox debugger
};

/// @function   jukebox_change_settings([_volume], [_duckVol], [_priority])
/// @param      {real} [_volume]     New master volume (0-1), unchanged if undefined
/// @param      {real} [_duckVol]    New duck volume factor (0-1), unchanged if undefined
/// @param      {real} [_priority]   New audio priority, unchanged if undefined
/// @description                     Updates jukebox settings. Only changes provided values.
///                                 Automatically updates current volume if volume or duck factor changes.
function jukebox_change_settings(
	_volume = undefined,
	_duckVol = undefined,
	_priority = undefined
) {
	if (_volume != undefined && _volume != JUKEBOX.volume) {
		JUKEBOX.volume = clamp(_volume, 0, 1);
		__jukebox_internal_update_volume();
	}
	if (_duckVol != undefined) {
		JUKEBOX.duckVolumeFactor = _duckVol;
		__jukebox_internal_update_volume();
	}
	if (_priority != undefined) {
		JUKEBOX.priority = _priority;
	}
}

/// @function   jukebox_play_song(_song, [_fadeIn], [_fadeOut], [_cross])
/// @param      {sound} _song        The song asset to play
/// @param      {real}  [_fadeIn=0]  Fade in duration in ms
/// @param      {real}  [_fadeOut=0] Fade out duration for current song in ms
/// @param      {bool}  [_cross=false] Whether to crossfade (fade out and in simultaneously)
/// @description                     Plays a song, optionally crossfading with the current song.
///                                 If the song is already playing, nothing happens.
///                                 If no song is playing, fade in starts immediately.
function jukebox_play_song(_song, _fadeIn = 0, _fadeOut = 0, _cross = false) {
	// If nothing is playing, start immediately
	if (JUKEBOX.currentSong == noone || !audio_is_playing(JUKEBOX.currentSong)) {
		__jukebox_internal_play(_song, _fadeIn);
		return;
	}

	// Don't restart if the same song is already playing
	if (audio_is_playing(_song)) {
		return;
	}

	if (_cross) {
		// Crossfade: fade out current while fading in new simultaneously
		__jukebox_internal_stop(_fadeOut);
		__jukebox_internal_play(_song, _fadeIn);
	} else {
		// Sequential: wait for fade out to complete before starting new song
		__jukebox_internal_stop(_fadeOut, method({_song, _fadeIn}, function() {
			__jukebox_internal_play(_song, _fadeIn);
		}));
	}
}

/// @function   jukebox_stop_song([_fadeOut])
/// @param      {real} [_fadeOut=0]  Fade out duration in ms
/// @description                     Stops the current song with an optional fade out.
///                                 Resets currentSong to noone.
function jukebox_stop_song(_fadeOut = 0) {
	__jukebox_internal_stop(_fadeOut);
	JUKEBOX.currentSong = noone;
}

/// @function   jukebox_toggle_duck([_length])
/// @param      {real} [_length=0]   Transition duration in ms
/// @description                     Toggles audio ducking on/off.
///                                 When ducked, volume is reduced to duckVolumeFactor * master volume.
function jukebox_toggle_duck(_length = 0) {
	JUKEBOX.isDucked = !JUKEBOX.isDucked;
	
	// Calculate target volume based on duck state
	var _targetVolume = JUKEBOX.volume * (JUKEBOX.isDucked ? JUKEBOX.duckVolumeFactor : 1);
	
	audio_sound_gain(JUKEBOX.currentSong, _targetVolume, _length);
	JUKEBOX.currentVolume = _targetVolume;
}

/// @function   jukebox_queue(_songs, [_clear], [_startNow])
/// @param      {array} _songs       Array of song assets to queue
/// @param      {bool}  [_clear=false] Whether to clear the existing queue first
/// @param      {bool}  [_startNow=true] Whether to start playing immediately
/// @description                     Adds songs to the queue and optionally starts playback.
///                                 If starting now, playback begins from the first song in the queue.
function jukebox_queue(_songs, _clear = false, _startNow = true) {
	if (_clear) {
		jukebox_queue_clear();
	}

	array_foreach(_songs, function(_x) {
		array_push(JUKEBOX.queue, _x);
	});

	if (_startNow) {
		JUKEBOX.queuePosition = 0;
		__jukebox_internal_start();
	}
}

/// @function   jukebox_queue_start([_pos])
/// @param      {real} [_pos]        Position in queue to start from (defaults to current position)
/// @description                     Starts or restarts playback from a specific queue position.
///                                 Position is clamped to valid range.
function jukebox_queue_start(_pos = JUKEBOX.queuePosition) {
	JUKEBOX.queuePosition = clamp(_pos, 0, array_length(JUKEBOX.queue));
	__jukebox_internal_start();
}

/// @function   jukebox_queue_clear()
/// @description                     Clears the entire queue and resets position to 0.
function jukebox_queue_clear() {
	JUKEBOX.queue = [];
	JUKEBOX.queuePosition = 0;
}

/// @function   jukebox_play_next()
/// @description                     Plays the next song in the queue. Wraps around to the beginning
///                                 if at the end of the queue. Destroys any existing time source.
function jukebox_play_next() {
	if (time_source_exists(JUKEBOX.timeSource)) {
		time_source_destroy(JUKEBOX.timeSource);
	}
	JUKEBOX.queuePosition++;
	if (JUKEBOX.queuePosition >= array_length(JUKEBOX.queue)) {
		JUKEBOX.queuePosition = 0;
	}
	__jukebox_internal_start();
}

/// @function   jukebox_play_previous()
/// @description                     Plays the previous song in the queue. Wraps around to the end
///                                 if at the beginning of the queue. Destroys any existing time source.
function jukebox_play_previous() {
	if (time_source_exists(JUKEBOX.timeSource)) {
		time_source_destroy(JUKEBOX.timeSource);
	}
	JUKEBOX.queuePosition--;
	if (JUKEBOX.queuePosition < 0) {
		JUKEBOX.queuePosition = array_length(JUKEBOX.queue) - 1;
	}
	__jukebox_internal_start();
}

/// @function   jukebox_toggle_pause()
/// @description                     Toggles pause/resume for the current song.
///                                 Also pauses/resumes the associated time source.
function jukebox_toggle_pause() {
	if (audio_is_paused(JUKEBOX.currentSong)) {
		audio_resume_sound(JUKEBOX.currentSong);
		if (time_source_exists(JUKEBOX.timeSource)) {
			time_source_resume(JUKEBOX.timeSource);
		}
	} else {
		audio_pause_sound(JUKEBOX.currentSong);
		if (time_source_exists(JUKEBOX.timeSource)) {
			time_source_pause(JUKEBOX.timeSource);
		}
	}
}

/// @function   jukebox_debug(_songs)
/// @param      {array} _songs       Array of song assets to show in debug view
/// @description                     Creates a debug view for the jukebox with play controls
///                                 for the specified songs. Uses call_later to ensure UI is ready.
function jukebox_debug(_songs) {
	call_later(1, time_source_units_seconds, method({_songs}, function() {
		__jukebox_internal_debug(_songs);
	}), true);
}

/// @function   jukebox_queue_debug()
/// @description                     Creates a debug view showing the current queue with
///                                 playback controls and now-playing indicator.
function jukebox_queue_debug() {
	call_later(
		1,
		time_source_units_seconds,
		function() {
			__jukebox_internal_queue_debug();
		},
		true
	);
}

/// @section Internal Functions

/// @function   __jukebox_internal_update_volume()
/// @description                     Updates the current volume based on master volume and duck state.
///                                 Applies the change to the currently playing song if any.
function __jukebox_internal_update_volume() {
	JUKEBOX.currentVolume =
		JUKEBOX.volume * (JUKEBOX.isDucked ? JUKEBOX.duckVolumeFactor : 1);
	if (!audio_is_playing(JUKEBOX.currentSong)) {
		return;
	}
	audio_sound_gain(JUKEBOX.currentSong, JUKEBOX.currentVolume, 0);
}

/// @function   __jukebox_internal_play(_song, _fadeIn, [_loop])
/// @param      {sound} _song        The song asset to play
/// @param      {real}  _fadeIn      Fade in duration in ms
/// @param      {bool}  [_loop=true] Whether the song should loop
/// @description                     Plays a song with optional fade in. Sets it as the current song.
function __jukebox_internal_play(_song, _fadeIn, _loop = true) {
	// Start with 0 volume if fading in, otherwise use current volume
	var _bgm = audio_play_sound(
		_song,
		JUKEBOX.priority,
		_loop,
		_fadeIn == 0 ? JUKEBOX.currentVolume : 0
	);
	
	// Apply fade in if specified
	if (_fadeIn != 0) {
		audio_sound_gain(_bgm, JUKEBOX.currentVolume, _fadeIn);
	}
	
	JUKEBOX.currentSong = _bgm;
}

/// @function   __jukebox_internal_stop(_fadeOut, [_onStop])
/// @param      {real}   _fadeOut    Fade out duration in ms
/// @param      {method} [_onStop]   Callback to execute after stopping
/// @description                     Stops the current song with optional fade out.
///                                 If fadeOut > 0, uses call_later to stop after the fade completes.
function __jukebox_internal_stop(_fadeOut, _onStop = function() {}) {
	if (!audio_is_playing(JUKEBOX.currentSong)) {
		return;
	}
	
	audio_sound_gain(JUKEBOX.currentSong, 0, _fadeOut);
	
	// If no fade out, stop immediately
	if (_fadeOut <= 0) {
		audio_stop_sound(JUKEBOX.currentSong);
		_onStop();
		return;
	}

	// Schedule stop after fade out completes
	call_later(_fadeOut / 1000, time_source_units_seconds, method({
		oldSong: JUKEBOX.currentSong,
		_onStop,
	}, function() {
		audio_stop_sound(oldSong);
		_onStop();
	}));
}

/// @function   __jukebox_internal_start()
/// @description                     Starts playing the current queue position.
///                                 Handles crossfading and sets up a time source for auto-advance.
function __jukebox_internal_start() {
	if (array_length(JUKEBOX.queue) == 0) {
		return;
	}
	
	// Crossfade out current song if playing
	if (audio_is_playing(JUKEBOX.currentSong)) {
		__jukebox_internal_stop(JUKEBOX.queueCrossfadeLength);
	}

	// Play the current queue song with crossfade
	__jukebox_internal_play(
		JUKEBOX.queue[JUKEBOX.queuePosition],
		JUKEBOX.queueCrossfadeLength
	);
	
	// Set up time source to auto-advance when song ends
	var _length = audio_sound_length(JUKEBOX.currentSong);
	JUKEBOX.timeSource = time_source_create(
		time_source_global,
		_length,
		time_source_units_seconds,
		__jukebox_internal_on_song_end
	);
	time_source_start(JUKEBOX.timeSource);
}

/// @function   __jukebox_internal_on_song_end()
/// @description                     Callback for when a song finishes playing.
///                                 Automatically advances to the next song in the queue.
function __jukebox_internal_on_song_end() {
	jukebox_play_next();
}

/// @function   __jukebox_internal_seconds_to_time(_seconds)
/// @param      {real}   _seconds    Time in seconds
/// @returns    {string}             Formatted time string "M:SS"
/// @description                     Converts seconds to a M:SS formatted string for display.
function __jukebox_internal_seconds_to_time(_seconds) {
	_seconds = round(_seconds);
	var _m = _seconds div 60;
	var _s = _seconds % 60;
	return string("{0}:{1}{2}", _m, _s < 10 ? "0" : "", _s);
}

/// @function   __jukebox_internal_debug_volume_controls()
/// @description                     Draws volume up/down buttons and current volume display
///                                 for the debug view.
function __jukebox_internal_debug_volume_controls() {
	var _size = 20;
	dbg_text("Volume");
	dbg_same_line();
	dbg_button(
		"-",
		function() {
			jukebox_change_settings(JUKEBOX.volume - 0.05);
		},
		_size,
		_size
	);
	dbg_same_line();
	dbg_text(string(round(JUKEBOX.volume * 100)));
	dbg_same_line();
	dbg_button(
		"+",
		function() {
			jukebox_change_settings(JUKEBOX.volume + 0.05);
		},
		_size,
		_size
	);
}

/// @function   __jukebox_internal_debug(_songs)
/// @param      {array} _songs       Array of song assets for the debug view
/// @description                     Creates a debug view with play controls for individual songs,
///                                 including basic play and crossfade options.
function __jukebox_internal_debug(_songs) {
	// Clean up existing debug view
	if (JUKEBOX.debugView != undefined) {
		dbg_view_delete(JUKEBOX.debugView);
	}

	JUKEBOX.debugView = dbg_view("Jukebox", true, 20, 100, 600);
	var _isPlaying = audio_is_playing(JUKEBOX.currentSong);

	// Now playing section with progress
	dbg_section(
		_isPlaying
			? string(
				"Currently Playing: {0}  ---  {1} / {2}",
				audio_get_name(JUKEBOX.currentSong),
				__jukebox_internal_seconds_to_time(
					audio_sound_get_track_position(JUKEBOX.currentSong)
				),
				__jukebox_internal_seconds_to_time(
					audio_sound_length(JUKEBOX.currentSong)
				)
			)
			: "Currently Playing: --- 0:00 / 0:00"
	);
	
	// Volume controls
	__jukebox_internal_debug_volume_controls();
	
	// Transport controls (only show when playing)
	if (_isPlaying) {
		dbg_button(audio_is_paused(JUKEBOX.currentSong) ? "Resume" : "Pause", function() {
			jukebox_toggle_pause();
		});
		dbg_same_line();
		dbg_button("Stop", function() {
			jukebox_stop_song();
		});
		dbg_same_line();
		dbg_button(JUKEBOX.isDucked ? "Unduck" : "Duck", function() {
			jukebox_toggle_duck(500);
		});
	}
	
	// Basic play section
	dbg_section("Basic");
	array_foreach(_songs, method({_songs}, function(_x, _i) {
		dbg_button(audio_get_name(_x), method({_x}, function() {
			jukebox_play_song(_x, 0, 1000);
		}));
		if (_i != array_length(_songs) - 1) {
			dbg_same_line();
		}
	}));

	// Crossfade section
	dbg_section("Cross Fade");
	array_foreach(_songs, method({_songs}, function(_x, _i) {
		dbg_button(audio_get_name(_x), method({_x}, function() {
			jukebox_play_song(_x, 2000, 2000, true);
		}));
		if (_i != array_length(_songs) - 1) {
			dbg_same_line();
		}
	}));
}

/// @function   __jukebox_internal_queue_debug()
/// @description                     Creates a debug view showing the current queue state with
///                                 transport controls and playlist display.
function __jukebox_internal_queue_debug() {
	// Clean up existing debug view
	if (JUKEBOX.debugView != undefined) {
		dbg_view_delete(JUKEBOX.debugView);
	}

	JUKEBOX.debugView = dbg_view("Jukebox", true, 20, 100, 600);

	// Now playing section with progress
	dbg_section(
		string(
			"Currently Playing: {0}  ---  {1} / {2}",
			audio_get_name(JUKEBOX.queue[JUKEBOX.queuePosition]),
			__jukebox_internal_seconds_to_time(
				audio_sound_get_track_position(JUKEBOX.currentSong)
			),
			__jukebox_internal_seconds_to_time(audio_sound_length(JUKEBOX.currentSong))
		)
	);

	// Volume controls
	__jukebox_internal_debug_volume_controls();

	// Transport controls
	dbg_button("Next", function() {
		jukebox_play_next();
	});
	dbg_same_line();
	dbg_button("Prev", function() {
		jukebox_play_previous();
	});
	dbg_same_line();
	dbg_button(audio_is_paused(JUKEBOX.currentSong) ? "Resume" : "Pause", function() {
		jukebox_toggle_pause();
	});
	dbg_same_line();
	dbg_button(JUKEBOX.isDucked ? "Unduck" : "Duck", function() {
		jukebox_toggle_duck(500);
	});

	// Playlist display
	dbg_section("Playlist");
	array_foreach(JUKEBOX.queue, function(_x, _index) {
		dbg_text(
			string(
				"    {0}: {1} {2}",
				_index + 1,
				audio_get_name(_x),
				_index == JUKEBOX.queuePosition ? " < NOW PLAYING" : ""
			)
		);
	});
}