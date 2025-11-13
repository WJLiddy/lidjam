extends Critter
var digging = false
var orig_rot

func _ready():
	orig_rot = global_rotation
# Turning, Dancing, Diving, Eating, Judging
func pick_action():
	
	if(dist_to_player() * stealth_mult() < 20 and dist_to_player() * stealth_mult() > 15):
		make_emoticon("Alert")
	
	if(action == "RestingIDLE"):
		action = "PartyingIDLE"
		action_time = get_anim_length(action)
		
	elif(action == "PartyingIDLE"):
		if(dist_to_player() * stealth_mult() < 15):
			action = "Turning"
		action_time = get_anim_length(action)
	
	elif(action == "Turning"):
		action = "Judging"
		make_emoticon("Anger")
		action_time = get_anim_length(action)
	# burying
	elif(action == "Judging"):
		action = "DiggingIDLE"
		digging = true
		action_time = get_anim_length(action)
	elif(action == "DiggingIDLE" and digging):
		$vis.position = Vector3(0,-1,0)
		digging = false
		action_time = 5
	elif(action == "DiggingIDLE" and not digging):
		# move the visbox underground
		# later, only if player can't see us.
		if(dist_to_player() > 30 and not get_node("vis").is_on_screen()):
			action = "PartyingIDLE"
			$vis.position = Vector3(0,0.8,0)
			global_rotation = orig_rot
			action_time = get_anim_length(action)
		else:
			action_time = 10
			# don't animate again
			return
	
	$model/AnimationPlayer.play(action)
