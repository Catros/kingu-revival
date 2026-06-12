if (target == noone) exit

var len = point_distance(x1, y1, target.x, target.y);
var dir = point_direction(x1, y1, target.x, target.y);

// Position at the midpoint
x = (x1 + target.x) * 0.5;
y = (y1 + target.y) * 0.5;

// Rotate towards endpoint
image_angle = dir;

// Stretch the mask
image_xscale = len / sprite_get_width(sprite_index);
image_yscale = 1;