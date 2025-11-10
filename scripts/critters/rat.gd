extends Critter

func speed():
	if fleeing:
		return 8
	return 5

var target_bait = null
var fleeing = false
# Eating, Rolling, Roll Starting, Roll Ending

func pick_action():
	if(action == "Roll Ending"):
		action = "Eating"
		action_time = get_anim_length(action)
	elif(action == "Eating"):
		action = "Roll Starting"
		action_time = get_anim_length(action)
	
	# check if should run from player.
	elif(dist_to_player() < 10):
		fleeing = true
		$nav.set_target_position(global_position + ((global_position - get_node("../../Player").global_position).normalized() * 5))
		if(not $nav.is_target_reachable()):
			# pick a random spot in a 5x5 grid for now
			$nav.set_target_position(global_position + Vector3(randf_range(-5,5),0,randf_range(-5,5)))
		action = "Rolling"
		action_time = get_anim_length(action)
		return
		
	# check if i should go towards or eat bait
	elif(get_node("../../Baits").get_children().size() > 0):
		fleeing = false
		# look for any baits.
		var bait = get_node("../../Baits").get_children().pick_random()
		if(global_position.distance_to(bait.global_position) < 1):
			# eat it
			action = "Roll Ending"
			action_time = 1.25
			target_bait = bait
		action = "Rolling"
		action_time = get_anim_length(action)
		$nav.set_target_position(target_bait.global_position)

	else:
	# fallback
		fleeing = false
		action = "Rolling"
		$nav.set_target_position(global_position + Vector3(randf_range(-5,5),0,randf_range(-5,5)))
		action_time = get_anim_length(action)
		
	$model/AnimationPlayer.play(action)
