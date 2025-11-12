extends Critter
# Easting, Resting, Runnig, Walking?

func pick_action():
	if(player_is_whistling()):
		action = "Scared"
		set_nav_flee_from_player()
	if(get_nearest_bait() != null and global_position.distance_to(get_nearest_bait().global_position) < 1):
		action = "Eating"
	else:
		action = ["Walking","RestingIDLE"].pick_random()
		if(action == "Walking"):
			set_nav_meander()
	action_time = get_anim_length(action)
	$model/AnimationPlayer.play(action)
