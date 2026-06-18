if (layer_exists("Ground")) {

	randomize_tiles()
	
	if (!instance_exists(obj_player)) {instance_create_depth(room_width / 2, room_height / 2, 0, obj_player)}

}

jukebox_play_song(mus_musicPlaceholder)
video_open("output.mp4")
jukebox_play_song(mus_musicSubway)