extends Critter


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


# walking grazing scared resting
func pick_action():
	action = "RestingIDLE"
	action_time = 10.0
	$model/AnimationPlayer.play(action)
	return
	
