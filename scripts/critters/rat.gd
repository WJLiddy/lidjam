extends Critter

func speed():
	if fleeing:
		return 8
	return 5

var fleeing = false
# Eating, Rolling, Roll Starting, Roll Ending

func pick_action():
	if(species == "Gold Burglerat"):
		action = "Resting"
		$model/AnimationPlayer.play(action)
		return
		
	if(action == "Roll Ending"):
		action = "Eating"
		make_emoticon()
		action_time = get_anim_length(action)
	elif(action == "Eating"):
		# bug prone
		if(get_nearest_bait() != null):
			get_nearest_bait().queue_free()
		action = "Roll Starting"
		action_time = get_anim_length(action)
	
	# check if should run from player.
	elif(dist_to_player() < 10):
		fleeing = true
		set_nav_flee_from_player()
		action = "Rolling"
		action_time = get_anim_length(action)
		return
		
	# check if i should go towards or eat bait
	elif(get_node("../../Baits").get_children().size() > 0):
		fleeing = false
		# look for any baits.
		var bait = get_nearest_bait()
		if(global_position.distance_to(bait.global_position) < 1):
			# eat it
			action = "Roll Ending"
			action_time = get_anim_length("Roll Ending")
		else:
			action = "Rolling"
			action_time = get_anim_length(action)
			$nav.set_target_position(bait.global_position)
		

	else:
	# fallback
		fleeing = false
		action = "Rolling"
		$nav.set_target_position(global_position + Vector3(randf_range(-5,5),0,randf_range(-5,5)))
		action_time = get_anim_length(action)

	$model/AnimationPlayer.play(action)
