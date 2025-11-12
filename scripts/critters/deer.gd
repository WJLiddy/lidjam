extends Critter

func speed():
	if fleeing:
		return 8
	return 5

var fleeing = false

# walking grazing petrified resting
func pick_action():
	if((action == "Walking" or action == "Grazing" or action == "RestingIDLE") and player_is_whistling()):
		action = "Petrified"
	elif(dist_to_player() < 20 or action == "Petrified"):
		action = "Walking"
		set_nav_flee_from_player()
	else:
		var rand = randi_range(0,3)
		if(rand == 1):
			action = "Grazing"
		elif(rand == 2):
			action = "Walking"
			set_nav_meander()
		else:
			action = "RestingIDLE"
	action_time = get_anim_length(action)
	$model/AnimationPlayer.play(action)
