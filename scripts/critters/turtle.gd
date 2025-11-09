extends Critter

func pick_action():
			# pick new action
	action = ["Walking","Resting"].pick_random()
	if(action == "Walking"):
		$nav.set_target_position(global_position + Vector3(randf_range(-5,5),0,randf_range(-5,5)))
	$model/AnimationPlayer.play(action)
	action_time = randf_range(2.0,5.0)
