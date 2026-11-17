// Drawing is done by obj_world in Y-sort order (User Event 0); only draw here when there is no obj_world.
if (!instance_exists(obj_world)) event_user(0);
