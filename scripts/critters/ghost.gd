extends Critter
# Confused (baited)
# Excited (in pic)
# Resting, Scared, Spooked
func pick_action():
	action = "RestingIDLE"
	action_time = 10.0
	$model/AnimationPlayer.play(action)
	return
	
	
