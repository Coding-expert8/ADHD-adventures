// =====================================
// HOTBAR SLOT SELECTION
// =====================================

if (keyboard_check_pressed(ord("1"))) selected_slot = 1;
if (keyboard_check_pressed(ord("2"))) selected_slot = 2;
if (keyboard_check_pressed(ord("3"))) selected_slot = 3;
if (keyboard_check_pressed(ord("4"))) selected_slot = 4;
if (keyboard_check_pressed(ord("5"))) selected_slot = 5;
if (keyboard_check_pressed(ord("6"))) selected_slot = 6;


// =====================================
// ITEM USAGE
// =====================================

if (keyboard_check_pressed(ord("Q")))
{
    var _index = selected_slot - 1;

    var _item = hotbar_items[_index];

    // Check item exists
    if (_item.sprite != -1)
    {
        // Check individual cooldown
        if (_item.cooldown_remaining <= 0)
        {
            // Start this item's cooldown
            hotbar_items[_index].cooldown_remaining =
                _item.cooldown;

            // ITEM USAGE CODE GOES HERE
        }
    }
}


// =====================================
// UPDATE INDIVIDUAL ITEM COOLDOWNS
// =====================================

var _dt = delta_time / 1000000;

for (var i = 0; i < hotbar_slots; i++)
{
    if (hotbar_items[i].cooldown_remaining > 0)
    {
        hotbar_items[i].cooldown_remaining -= _dt;

        hotbar_items[i].cooldown_remaining =
            max(0, hotbar_items[i].cooldown_remaining);
    }
}

if selected_slot = 2 {
	global.can_fire = true;
}
else {
	global.can_fire = false;
}

