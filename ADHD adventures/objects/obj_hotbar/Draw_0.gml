// =====================================
// COMPASS ARROW
// =====================================

// Only draw while compass is active
if (compass_arrow_active)
{
    // Check that both objects exist
    if (instance_exists(obj_ship) &&
        instance_exists(obj_portal_space_rocks))
    {
        // Get object instances
        var _ship = instance_find(obj_ship, 0);

        var _portal = instance_find(obj_portal_space_rocks, 0);

        // Calculate direction towards portal
        var _direction = point_direction(
            _ship.x,
            _ship.y,
            _portal.x,
            _portal.y
        );

        // Calculate arrow endpoint
        var _end_x = _ship.x +
            lengthdir_x(compass_arrow_length, _direction);

        var _end_y = _ship.y +
            lengthdir_y(compass_arrow_length, _direction);

        // Arrowhead size
        var _arrowhead_size = 25;

        // Calculate arrowhead endpoints
        var _left_x = _end_x +
            lengthdir_x(_arrowhead_size, _direction + 150);

        var _left_y = _end_y +
            lengthdir_y(_arrowhead_size, _direction + 150);

        var _right_x = _end_x +
            lengthdir_x(_arrowhead_size, _direction - 150);

        var _right_y = _end_y +
            lengthdir_y(_arrowhead_size, _direction - 150);


        // =====================================
        // DRAW ARROW
        // =====================================

        draw_set_color(c_yellow);

        // Main arrow
        draw_line_width(
            _ship.x,
            _ship.y,
            _end_x,
            _end_y,
            5
        );

        // Arrowhead
        draw_line_width(
            _end_x,
            _end_y,
            _left_x,
            _left_y,
            5
        );

        draw_line_width(
            _end_x,
            _end_y,
            _right_x,
            _right_y,
            5
        );

        // Reset drawing colour
        draw_set_color(c_white);
    }
}