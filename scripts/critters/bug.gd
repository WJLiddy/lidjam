extends Critter

func pick_action():
	if(player_is_whistling()):
		action = "Listening"
	else:
		if(randf_range(0,3) == 1):
			action = "Flying"
			$nav.set_target_position(global_position + Vector3(randf_range(-5,5),0,randf_range(-5,5)))
		else:
			action = "Resting"
		
	action_time = get_anim_length(action)
