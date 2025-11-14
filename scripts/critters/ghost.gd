extends Critter

func speed():
	return 5.0

var spooked = false
var baited = false

func pick_action():
	if(action == "SpookedIDLE"):
		action = "Scared"
		set_nav_flee_from_player()
	elif(spooked):
		spooked = false
		action = "SpookedIDLE"
		make_emoticon("Anger")
	elif(player_is_whistling()):
		action = "Scared"
		make_emoticon("Anger")
		$nav.set_target_position(global_position + 5 * (global_position - get_node("../../Player").global_position).normalized())
	elif (baited):
		baited = false
		action = "ConfusedIDLE"
		make_emoticon("Alert")
	elif(get_node("vis").is_on_screen() and player_is_ads()):
		action = "Excited"
		make_emoticon("Love")
	else:
		action = "RestingIDLE"
	action_time = get_anim_length(action)
	$model/AnimationPlayer.play(action)


func _on_bait_detect_body_entered(_body: Node3D) -> void:
	baited = true
	action_time = 0
