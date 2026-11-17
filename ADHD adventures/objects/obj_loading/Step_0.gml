if sprite_width < room_width - 200 {
	image_xscale += 0.005
	image_yscale += 0.005
}
if penis = false and  sprite_width >= room_width - 200 {
	instance_create_layer(530, 450, "Instances_1", obj_gamegoing)
	penis = true
}
