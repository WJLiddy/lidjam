extends Critter
# Easting, Resting, Runnig, Walking?
var fleeing = false

func speed():
	if(fleeing):
		return 9
	else:
		return 3

func pick_action():
	if(dist_to_player() > 50):
		fleeing = false
	
	if(action == "Eating" and get_nearest_bait() != null):
		get_nearest_bait().queue_free()
		action = "RestingIDLE"
	elif((dist_to_player() < 50 and player_is_whistling()) or fleeing ):
		action = "Scared"
		fleeing = true
		set_nav_flee_from_player()
	elif(get_nearest_bait() != null and global_position.distance_to(get_nearest_bait().global_position) < 20):
		if (global_position.distance_to(get_nearest_bait().global_position) < 1):
			action = "Eating"
		else:
			action = "Walking"
			$nav.set_target_position(get_nearest_bait().global_position)
	else:
		action = ["Walking","RestingIDLE"].pick_random()
		if(action == "Walking"):
			set_nav_meander()
	action_time = get_anim_length(action)
	$model/AnimationPlayer.play(action)
