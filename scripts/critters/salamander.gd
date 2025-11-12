extends Critter

var to_shore = false

# Resting
func pick_action():
	var entry_position = get_node("../../SalamanderEntryPoint").global_position
	
	if(action == "Swimming"):
		# go to shore eventually
		if(randi_range(0,7) == 1):
			to_shore = true
		
		if(to_shore):
			if(entry_position.distance_to(global_position) < 1):
				action = "Waddling"
				to_shore = false
			$nav.set_target_position(get_node("../../SalamaderEntryPoint"))
		else:
			set_nav_meander()
			
			
	if(action == "Waddling" or action == "RestingIDLE"):
		if(to_shore):
			if(entry_position.distance_to(global_position) < 1):
				action = "Swimming"
				to_shore = false
			# go to the shore.
			$nav.set_target_position(get_node("../../SalamanderEntryPoint").global_position)
		else:
			# check for confusion w/bait
			if(get_nearest_bait() != null and global_position.distance_to(get_nearest_bait().global_position) < 1):
				action = "ConfusedIDLE"
			
			var rand = randi_range(0,7)
			# go to shore eventually
			if(rand == 1):
				to_shore = true
			if(rand == 2):
				action = "Using MagicIDLE"
			if(rand > 5):
				action = "RestingIDLE"
				
			if(action == "Waddling"):
				set_nav_meander()
		
	
	action_time = get_anim_length(action)
	$model/AnimationPlayer.play(action)
	
