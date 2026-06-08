global.controller = noone

stanncam_init(1920, 1080, 1920, 1080)
global.camera_main = new stanncam(0, 0, global.game_w, global.game_h)
global.camera_main.follow = global.controller






