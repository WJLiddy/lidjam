extends Critter

func speed():
	return 0.3
	
func rotspeed():
	return 3

func pick_action():
	action = ["Walking","RestingIDLE"].pick_random()
	if(action == "Walking"):
		$nav.set_target_position(global_position + Vector3(randf_range(-5,5),0,randf_range(-5,5)))
	action_time = get_anim_length(action)
	$model/AnimationPlayer.play(action)
