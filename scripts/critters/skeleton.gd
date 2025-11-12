extends Critter

var bugle = false

# bugling, hiding, peeking
func pick_action():
	if(bugle):
		action = "BuglingIDLE"
		bugle = false
	elif(dist_to_player() < 10):
		action = "HidingIDLE"
	else:
		action = "PeekingIDLE"
	action_time = get_anim_length(action)
	$model/AnimationPlayer.play(action)
	


func _on_spook_zone_body_entered(body: Node3D) -> void:
	bugle = true
	if "species" in body and body.species == "Leghost":
		body.spooked = true
