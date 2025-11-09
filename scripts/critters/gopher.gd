extends Critter

# Walking, Dancing, Diving, Eating, Judging
func pick_action():
	
	# burying
	if(action == "judging_idle"):
		action = "burying_idle"
		action_time = 30.0
		# play animation "bury"
		
	# looking at player if player is close. next action is immediately buried
	if(dist_to_player() < 10):
		action = "judging_idle"
		look_at(get_node("../../Player").global_position)
		# play animation "glare"
		action_time = 1.0
		
	else:
		action = "idle"
		action_time = 0.5
	
