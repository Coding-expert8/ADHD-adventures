// =====================================
// HOTBAR DRAWING
// =====================================

// GUI dimensions
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// Calculate total hotbar width
var _total_width =
    hotbar_slots * slot_size
    + (hotbar_slots - 1) * slot_gap;

// Starting position
var _start_x = (_gui_w - _total_width) / 2;
var _start_y = _gui_h - slot_size - hotbar_margin_bottom;


// =====================================
// DRAW HOTBAR SLOTS
// =====================================

for (var i = 0; i < hotbar_slots; i++)
{
    var _slot_x = _start_x + i * (slot_size + slot_gap);
    var _slot_y = _start_y;

    var _slot_x2 = _slot_x + slot_size;
    var _slot_y2 = _slot_y + slot_size;

    // Selected slot background
    if (selected_slot == i + 1)
    {
        draw_set_color(make_color_rgb(180, 85, 15));
    }
    else
    {
        draw_set_color(make_color_rgb(35, 35, 35));
    }

    draw_set_alpha(1);

    draw_rectangle(
        _slot_x,
        _slot_y,
        _slot_x2,
        _slot_y2,
        false
    );


    // =================================
    // SLOT BORDER
    // =================================

    if (selected_slot == i + 1)
    {
        draw_set_color(make_color_rgb(255, 145, 35));
    }
    else
    {
        draw_set_color(make_color_rgb(130, 130, 130));
    }

    draw_rectangle(
        _slot_x,
        _slot_y,
        _slot_x2,
        _slot_y2,
        true
    );


    // =================================
    // DRAW ITEM SPRITE
    // =================================

    var _sprite = hotbar_items[i].sprite;

    if (_sprite != -1)
    {
        draw_sprite_stretched(
            _sprite,
            0,
            _slot_x + 7,
            _slot_y + 7,
            slot_size - 14,
            slot_size - 14
        );
    }
	
	// =====================================
	// INDIVIDUAL COOLDOWN OVERLAY
	// =====================================

	var _remaining = hotbar_items[i].cooldown_remaining;
	var _duration = hotbar_items[i].cooldown;

	if (_remaining > 0)	
	{
		var _cooldown_percent = _remaining / _duration;

		var _overlay_height = slot_size * _cooldown_percent;

		draw_set_alpha(0.65);
		draw_set_color(c_black);

		draw_rectangle(
		    _slot_x,
		    _slot_y,
		    _slot_x2,
		    _slot_y + _overlay_height,
		    false
		);

		draw_set_alpha(1);
	}


    // =================================
    // NUMBER LABEL
    // =================================

    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
	
	draw_set_colour(c_green);
    draw_text(
        _slot_x + 4,
        _slot_y + 3,
        string(i + 1)
    );
	draw_set_colour(c_white);
}


// Reset drawing settings
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);



// =====================================
// FULLSCREEN MAP
// =====================================

if (map_open)
{
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();

    // Dark background
    draw_set_alpha(1);
    draw_set_color(c_black);

    draw_rectangle(
        0, 0,
        _gui_w, _gui_h,
        false
    );

    // Draw map across the screen
    draw_set_color(c_white);

    draw_sprite_stretched(
        spr_map_maze,
        0,
        0,
        0,
        _gui_w,
        _gui_h
    );

    // Map instructions
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);

    draw_text(
        _gui_w / 2,
        _gui_h - 20,
        "Press Q to close map"
    );
}

// Reset drawing settings
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);