extends Critter

func speed():
	if fleeing:
		return 12
	return 5

var fleeing = false
var alerted = false

# walking grazing petrified resting
func pick_action():
	# check if we can stop fleeing
	if(dist_to_player() > 50):
		fleeing = false
		alerted = false
		
	if((not fleeing) and (not alerted) and dist_to_player() * stealth_mult() < 45 and dist_to_player() * stealth_mult() > 30):
		make_emoticon("Alert")
		alerted = true
		
	# used the whistle.
	if((not fleeing) and player_is_whistling() and dist_to_player() < 50):
		action = "Petrified"
		make_emoticon("Anger")
		fleeing = true 
	elif(fleeing):
		action = "Walking"
		set_nav_flee_from_player()
	elif(dist_to_player() * stealth_mult() < 30):
		action = "Walking"
		make_emoticon("Scared")
		fleeing = true
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
