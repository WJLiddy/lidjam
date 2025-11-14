extends Critter

func speed():
	if fleeing:
		return 10
	return 5

var fleeing = false
# Eating, Rolling, Roll Starting, Roll Ending
func _ready() -> void:
	if(species == "Gold Burglerat"):
		get_node("model/rat armature/Skeleton3D/rat").visible = false
		get_node("model/rat armature/Skeleton3D/goldrat").visible = true

func pick_action():

	# check if we should stop fleeing
	if(dist_to_player() > 20):
		fleeing = false
	
	# special - ignore this one
	if(species == "Gold Burglerat"):
		action = "Resting"
		$model/AnimationPlayer.play(action)
		return
		
	# state stuff, always play this
	if(action == "Roll EndingIDLE"):
		action = "Eating"
		make_emoticon("Love")
		action_time = get_anim_length(action)
	elif(action == "Eating"):
		
		# bug prone
		if(get_nearest_bait() != null):
			get_nearest_bait().queue_free()
		action = "Roll StartingIDLE"
		action_time = get_anim_length(action)
	
	# check if should run from player.
	elif(dist_to_player() * stealth_mult() < 10 or fleeing):
		if(!fleeing):
			make_emoticon("Scared")
		fleeing = true
		set_nav_flee_from_player()
		action = "Rolling"
		action_time = get_anim_length(action)
		
	# check if i should go towards or eat bait
	elif(get_nearest_bait() != null and global_position.distance_to(get_nearest_bait().global_position) < 50):
		# look for any baits.
		var bait = get_nearest_bait()
		if(global_position.distance_to(bait.global_position) < 1 and bait.global_position.distance_to(get_node("../../Player").global_position) > 10):
			# the bait is left alone, eat it
			action = "Roll EndingIDLE"
			action_time = get_anim_length(action)
		else:
			action = "Rolling"
			action_time = get_anim_length(action)
			# go to the bait
			$nav.set_target_position(bait.global_position)
		

	else:
	# fallback
		fleeing = false
		action = "Rolling"
		set_nav_meander()
		action_time = get_anim_length(action)

	$model/AnimationPlayer.play(action)
