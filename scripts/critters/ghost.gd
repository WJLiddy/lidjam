extends Critter

func speed():
	return 5.0

var spooked = false
var baited = false

func pick_action():
	if(baited):
		baited = false
		action = "Confused"
	elif(spooked):
		spooked = false
		action = "Spooked"
	elif(player_is_whistling()):
		action = "Scared"
		set_nav_flee_from_player()
	elif(get_node("vis").is_on_screen() and player_is_ads()):
		action = "Excited"
	else:
		action = "Resting"
	action_time = get_anim_length(action)
	$model/AnimationPlayer.play(action)


func _on_bait_detect_body_entered(_body: Node3D) -> void:
	baited = true
