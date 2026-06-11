var len = point_distance(x1, y1, x2, y2);
var dir = point_direction(x1, y1, x2, y2);

// Position at the midpoint
x = (x1 + x2) * 0.5;
y = (y1 + y2) * 0.5;

// Rotate towards endpoint
image_angle = dir;

// Stretch the mask
image_xscale = len / sprite_width;
image_yscale = 1;

alarm[0] = destroyAfterXFrames