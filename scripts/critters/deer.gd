extends Critter

func speed():
	if fleeing:
		return 12
	return 6

var fleeing = false

# walking grazing petrified resting
func pick_action():
	# check if we can stop fleeing
	if(dist_to_player() > 50):
		fleeing = false
	
	if(not fleeing and (action == "Walking" or action == "Grazing" or action == "RestingIDLE") and player_is_whistling()):
		action = "Petrified"
		fleeing = true
	elif(dist_to_player() < 30 or fleeing):
		action = "Walking"
		set_nav_flee_from_player()
	else:
		var rand = randi_range(0,4)
		if(rand == 1):
			action = "GrazingIDLE"
		elif(rand == 2):
			action = "RestingIDLE"
		else:
			action = "Walking"
			set_nav_meander()
	action_time = get_anim_length(action)
	$model/AnimationPlayer.play(action)
