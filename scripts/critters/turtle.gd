extends Critter

func speed():
	return 0.3
	
func rotspeed():
	return 3

#confused, resting, swimming, using nagic, waddling
func pick_action():
	action = ["Walking","RestingIDLE"].pick_random()
	if(action == "Walking"):
		set_nav_meander()
	action_time = get_anim_length(action)
	$model/AnimationPlayer.play(action)
