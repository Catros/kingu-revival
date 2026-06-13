if (target == noone || !instance_exists(target)) exit

var _tar_x = target.x - VIEW_W / 2
var _tar_y = target.y - VIEW_H / 2

_tar_x = lerp(VIEW_X, _tar_x, damping)
_tar_y = lerp(VIEW_Y, _tar_y, damping)

var _left =		zoneCurrent != undefined ? zoneCurrent.bbox_left : 0
var _right =	(zoneCurrent != undefined ? zoneCurrent.bbox_right : room_width) - VIEW_W
var _top =		zoneCurrent != undefined ? zoneCurrent.bbox_top : 0
var _bottom =	(zoneCurrent != undefined ? zoneCurrent.bbox_bottom : room_height) - VIEW_H

_tar_x = clamp(_tar_x, _left, _right)
_tar_y = clamp(_tar_y, _top, _bottom)

_tar_x += shake.x
_tar_y += shake.y

camera_set_view_pos(VIEW, _tar_x, _tar_y)


/*

 1. Camera dépendante d'une zone à tout moment
 2. au changement de zone, la caméra est déplacée (au besoin, room editor)
 
 Dans la zone:
 clamp la camera à la bbox de la zone!!! genius
 
 Attention aux edge case des bords de la room?
*/