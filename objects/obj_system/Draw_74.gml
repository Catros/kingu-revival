var _data = video_draw();
var _status = _data[0];
var _video_status = video_get_status();

if (_status == 0 && _video_status == video_status_playing)
{
    var _surface = _data[1];

    draw_surface_ext(_surface, 0, 0, 0.5, 0.5, 0, c_white, 1);
}