extends Critter

func rotspeed():
	return 3.0
	
func pick_action():
	if(player_is_whistling()):
		action = "Listening"
	else:
		if(randf_range(0,10) > 1):
			action = "Flying"
			set_nav_meander()
			action_time = 3 * get_anim_length(action)
		else:
			action = "RestingIDLE"
			action_time = get_anim_length(action)
		
	$model/AnimationPlayer.play(action)
