extends Critter

# Turning, Dancing, Diving, Eating, Judging
func pick_action():
	if(action == "Resting"):
		action = "DancingIDLE"
		action_time = 1.0
		
	elif(action == "DancingIDLE" and dist_to_player() < 10):
		action = "Turning"
		action_time = 0.5
	
	elif(action == "Turning"):
		action = "JudgingIDLE"
		action_time = 1.0
	# burying
	elif(action == "JudgingIDLE"):
		action = "DivingIDLE"
		action_time = 30.0
		# play animation "bury"
	elif(action == "DivingIDLE"):
		if(dist_to_player() > 20):
			action = "DancingIDLE"
			action_time = 1.0
	
	$model/AnimationPlayer.play(action)
