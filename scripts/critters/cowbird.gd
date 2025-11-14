extends Critter

# special bird stuff
var perch = null
var ascending = true

func speed():
	return 7.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Birds do not use any of the same state junk from critter.
func _physics_process(delta: float) -> void:
	action_time -= delta
	#if(name == "Cowbird"):
	#	print(action)
	# check if our perchtarg is stale.
	if((not ascending) and not is_instance_valid(perch)):
		# someone ate our bait..
		action = "Perched"
		action_time = 0
	
	if(action_time <= 0):
		if(action == "Eating"):
			get_nearest_bait().queue_free()

		if action == "Perched" or action == "RestingIDLE" or action == "Eating":
			# time 2 go
			ascending = true
			perch = null

		# change the perchtarg
		if(ascending and get_nearest_bait() != null and global_position.distance_to(get_nearest_bait().global_position) < 100):
			# Get the bait?
			var space_state = get_world_3d().direct_space_state
			var coll_mask = 1
			var query = PhysicsRayQueryParameters3D.create(global_position + Vector3(0,1,0), get_nearest_bait().global_position,coll_mask)
			var result = space_state.intersect_ray(query)
			if(result.is_empty()):
				perch = get_nearest_bait()
				ascending = false

		# if we're ascending, keep flying up
		if ascending:
			perch = pick_perch_retry(true,5)
			if(perch != null):
				ascending = false
			else:
				# did not find perch. sad.
				velocity = Vector3(randf_range(-0.4,0.4),0.2,randf_range(-0.4,0.4)).normalized() * speed()
				action = "Flying"
				action_time = get_anim_length(action)
		if not ascending:
			velocity = (perch.global_position - global_position).normalized() * speed()
			action = "Flying"
			action_time = get_anim_length(action)
			# made it

		$model/AnimationPlayer.play(action)
	else:
		if not ascending and action == "Flying":
			velocity = (perch.global_position - global_position).normalized() * speed()
			# abort early if goal reached.
			if((perch.global_position - global_position).length() < 0.2):
				if(get_nearest_bait() != null and get_nearest_bait().global_position.distance_to(global_position) < 0.2):
					action = "Eating"
					action_time = get_anim_length(action)
					make_emoticon("Love")
					velocity = Vector3.ZERO
				else:
					action = "Perched"
					action_time = 10
					velocity = Vector3.ZERO
				$model/AnimationPlayer.play(action)
	
	if(velocity != Vector3(0,0,0)):
		look_at_grad(delta,global_position + velocity)
	move_and_slide()
