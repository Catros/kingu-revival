randomise()

global.controller = noone
global.camera = instance_create(obj_camera)
global.console = instance_create(obj_shell)

audio_group_load(audiogroup_music)
audio_group_load(audiogroup_effect)

jukebox_change_settings(0.2)
audio_group_set_gain(audiogroup_effect, 0.5)




