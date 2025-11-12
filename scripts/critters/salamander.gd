extends Critter

var to_shore = false

func speed():
	if(action == "Swimming"):
		return 5
	return 2

# Resting
func pick_action():
	var entry_position = get_node("../../SalamanderEntryPoint").global_position
	var exit_position = get_node("../../SalamanderExitPoint").global_position
	
	if(action == "Swimming"):
		action = "Waddling"
		to_shore = false
		global_position = exit_position
			
			
	if(action == "Waddling" or action == "RestingIDLE" or action == "Using MagicIDLE"):
		if(to_shore):
			if(entry_position.distance_to(global_position) < 4):
				action = "Swimming"
				global_position = entry_position
				to_shore = false
			# go to the shore.
			$nav.set_target_position(get_node("../../SalamanderEntryPoint").global_position)
		else:
			# check for confusion w/bait
			if(get_nearest_bait() != null and global_position.distance_to(get_nearest_bait().global_position) < 1):
				action = "Curious"
			else:
				var rand = randi_range(1,6)
				# go to shore eventually
				if(rand == 1):
					to_shore = true
					action = "Waddling"
				if(rand == 2):
					action = "Using MagicIDLE"
				if(rand == 3):
					action = "RestingIDLE"
				if(rand > 3):
					action = "Waddling"
					set_nav_meander()
					
	action_time = get_anim_length(action)
	if(action == "Swimming"):
		action_time = 20
	$model/AnimationPlayer.play(action)
	
