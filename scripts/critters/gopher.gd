extends Critter

# Turning, Dancing, Diving, Eating, Judging
func pick_action():
	if(action == "Resting"):
		action = "DancingIDLE"
		action_time = get_anim_length(action)
		
	elif(action == "DancingIDLE" and dist_to_player() < 10):
		action = "Turning"
		action_time = get_anim_length(action)
	
	elif(action == "Turning"):
		action = "JudgingIDLE"
		action_time = get_anim_length(action)
	# burying
	elif(action == "JudgingIDLE"):
		action = "DivingIDLE"
		action_time = 30.0
	elif(action == "DivingIDLE"):
		# later, only if player can't see us.
		if(dist_to_player() > 20):
			action = "DancingIDLE"
			action_time = get_anim_length(action)
	
	$model/AnimationPlayer.play(action)
