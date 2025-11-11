extends Critter

# Turning, Dancing, Diving, Eating, Judging
func pick_action():
	if(action == "Resting"):
		action = "PartyingIDLE"
		action_time = get_anim_length(action)
		
	elif(action == "PartyingIDLE" and dist_to_player() < 10):
		action = "Turning"
		action_time = get_anim_length(action)
	
	elif(action == "Turning"):
		action = "JudgingIDLE"
		action_time = get_anim_length(action)
	# burying
	elif(action == "JudgingIDLE"):
		action = "DiggingIDLE"
		action_time = 30.0
	elif(action == "DiggingwwIDLE"):
		# later, only if player can't see us.
		if(dist_to_player() > 20):
			action = "DancingIDLE"
			action_time = get_anim_length(action)
	
	$model/AnimationPlayer.play(action)
