// Draw the sortable instances in view from back (highest base) to front (lowest base).
var _view = world_view_rect();
ds_list_clear(sort_list);
var _count = collision_rectangle_list(
    _view[0] - YSORT_MARGIN_X, _view[1],
    _view[0] + _view[2] + YSORT_MARGIN_X, _view[1] + _view[3] + YSORT_MARGIN_DOWN,
    par_ysort, false, false, sort_list, false);

for (var _i = 0; _i < _count; _i++) {
    var _inst = sort_list[| _i];
    if (_inst.visible) ds_priority_add(sort_queue, _inst, _inst.bbox_bottom);
}
while (!ds_priority_empty(sort_queue)) {
    with (ds_priority_delete_min(sort_queue)) event_user(0);
}
