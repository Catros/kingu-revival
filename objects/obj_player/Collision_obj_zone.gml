if (zoneCurrent == other.id) exit

with (other) {
    var fully_inside = (other.bbox_left   >= bbox_left)
                     && (other.bbox_right  <= bbox_right)
                     && (other.bbox_top    >= bbox_top)
                     && (other.bbox_bottom <= bbox_bottom);

    if (fully_inside) {
        global.camera.set_target(id, false)
		other.zoneCurrent = id
    }
}