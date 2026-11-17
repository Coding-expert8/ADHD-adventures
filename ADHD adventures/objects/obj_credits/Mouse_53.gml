var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var gw = display_get_gui_width();
var gh = display_get_gui_height();

if (!credits_open)
{
    var button_x = gw - 140;
    var button_y = 20;

    if (mx >= button_x && mx <= button_x + button_width &&
        my >= button_y && my <= button_y + button_height)
    {
        credits_open = true;
    }
}
else
{
    var board_w = 420;
    var board_h = 340;

    var left = (gw - board_w) / 2;
    var top = (gh - board_h) / 2;

    if (mx >= left + board_w - 38 && mx <= left + board_w - 12 &&
        my >= top + 10 && my <= top + 36)
    {
        credits_open = false;
    }
}