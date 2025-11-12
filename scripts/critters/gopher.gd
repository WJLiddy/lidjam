extends Critter

# Turning, Dancing, Diving, Eating, Judging
func pick_action():
	if(action == "RestingIDLE"):
		action = "PartyingIDLE"
		action_time = get_anim_length(action)
		
	elif(action == "PartyingIDLE" and dist_to_player() < 10):
		action = "Turning"
		action_time = get_anim_length(action)
	
	elif(action == "Turning"):
		action = "Judging"
		action_time = get_anim_length(action)
	# burying
	elif(action == "Judging"):
		action = "DiggingIDLE"
		action_time = 30.0
	elif(action == "DiggingIDLE"):
		# later, only if player can't see us.
		if(dist_to_player() > 30 and not get_node("vis").is_on_screen()):
			action = "PartyingIDLE"
			action_time = get_anim_length(action)
	
	$model/AnimationPlayer.play(action)
