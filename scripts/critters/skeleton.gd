extends Critter

var bugle = false

# bugling, hiding, peeking
func pick_action():
	if(bugle):
		action = "BuglingIDLE"
		make_emoticon("Love")
		bugle = false
	elif(dist_to_player() * stealth_mult() < 35):
		action = "HidingIDLE"
	else:
		if(action != "PeekingIDLE"):
			make_emoticon("Alert")
		action = "PeekingIDLE"

	action_time = get_anim_length(action)
	$model/AnimationPlayer.play(action)
	


func _on_spook_zone_body_entered(body: Node3D) -> void:
	bugle = true
	action_time = 0
	if "species" in body and body.species == "Leghost":
		body.spooked = true
		body.action_time = 1
		body.action = "RestingIDLE"
