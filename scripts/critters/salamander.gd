extends Critter
# Confused Resting Swimming Using Magic Waddling
func pick_action():
	action = "RestingIDLE"
	action_time = 10.0
	$model/AnimationPlayer.play(action)
	return
