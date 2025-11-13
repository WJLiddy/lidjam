extends Critter
# Eating, RestingIDLE, Using Magic, Walking
func pick_action():
	
	if(action == "Eating" and get_nearest_bait() != null):
		get_nearest_bait().queue_free()
		action = "RestingIDLE"
	elif(get_nearest_bait() != null and global_position.distance_to(get_nearest_bait().global_position) < 20):
		if (global_position.distance_to(get_nearest_bait().global_position) < 1):
			action = "Eating"
			make_emoticon("Love")
		else:
			action = "Walking"
			$nav.set_target_position(get_nearest_bait().global_position)
	else:
		action = ["Walking","RestingIDLE","Using MagicIDLE"].pick_random()
		if(action == "Walking"):
			set_nav_meander()
		if(action == "Using MagicIDLE"):
			make_emoticon("Anger")
	action_time = get_anim_length(action)
	$model/AnimationPlayer.play(action)
