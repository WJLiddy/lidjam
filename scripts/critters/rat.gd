extends Critter

func fleespeed():
	return 8

func speed():
	return 3


func pick_action():
	# check if should run from player.
	if(dist_to_player() < 10):
		$nav.set_target_position(global_position + ((global_position - get_node("../../Player").global_position).normalized() * 5))
		if(not $nav.is_target_reachable()):
			# pick a random spot in a 5x5 grid for now
			$nav.set_target_position(global_position + Vector3(randf_range(-5,5),0,randf_range(-5,5)))
			
		action = "fleeing"
		$rigmodel/AnimationPlayer.play("walking")
		action_time = randf_range(0.5,1.0)
		return
	else:
		# look for any baits.
		for v in get_node("../../Baits").get_children():
			if(global_position.distance_to(v.global_position) < 1):
				# eat it
				action = "eating_idle"
				action_time = 1.0
				v.queue_free()
				return
			action_time = randf_range(1.0,2.0)
			$nav.set_target_position(v.global_position)
			$rigmodel/AnimationPlayer.play("walking")
			return
			
	# fallback
	action = "walking"
	$nav.set_target_position(global_position + Vector3(randf_range(-5,5),0,randf_range(-5,5)))
	$rigmodel/AnimationPlayer.play(action)
	action_time = randf_range(1.0,2.0)
			
			
