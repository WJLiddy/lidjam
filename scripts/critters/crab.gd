extends Critter

func pick_action():
	action = "RestingIDLE"
	action_time = get_anim_length(action)
	$model/AnimationPlayer.play(action)
