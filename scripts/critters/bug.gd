extends Critter

func pick_action():
	if(player_is_whistling()):
		action = "ListeningIDLE"
	else:
		if(randf_range(0,3) == 1):
			action = "Flying"
			set_nav_meander()
		else:
			action = "RestingIDLE"
		
	action_time = get_anim_length(action)
	$model/AnimationPlayer.play(action)
