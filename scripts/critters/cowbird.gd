extends Critter

# special bird stuff
var perchtarg = null
var ascending = true

func speed():
	return 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# Birds do not use any of the same state junk from critter.
func _physics_process(delta: float) -> void:
	action_time -= delta
	
	if(action_time < 0):
		if(action == "Eating"):
			get_nearest_bait().queue_free()

		# change the perchtarg
		if(ascending and get_nearest_bait() != null and global_position.distance_to(get_nearest_bait().global_position) < 100):
			perchtarg = get_nearest_bait()

		if action == "Perched" or action == "RestingIDLE" or action == "Eating":
			# time 2 go
			ascending = true
			perchtarg = get_node("../../Nav/Foliage").find_children("Perch").pick_random()

		# if we're ascending, keep flying up
		if ascending:
			var space_state = get_world_3d().direct_space_state
			var coll_mask = 1
			var query = PhysicsRayQueryParameters3D.create(global_position + Vector3(0,1,0), perchtarg.global_position,coll_mask)
			var result = space_state.intersect_ray(query)
			if result.is_empty():
				ascending = false
			else:
				velocity = Vector3(randf_range(-0.4,0.4),1,randf_range(-0.4,0.4)).normalized() * speed()
				action = "Flying"
				action_time = get_anim_length(action)
		if not ascending:
			velocity = (perchtarg.global_position - global_position).normalized() * speed()
			action = "Flying"
			action_time = get_anim_length(action)
			# made it

		$model/AnimationPlayer.play(action)
	else:
		if not ascending and action == "Flying":
			velocity = (perchtarg.global_position - global_position).normalized() * speed()
			# abort early if goal reached.
			if((perchtarg.global_position - global_position).length() < 0.5):
				if(get_nearest_bait() != null and get_nearest_bait().global_position.distance_to(global_position) < 0.5):
					action = "Eating"
					action_time = get_anim_length(action)
					velocity = Vector3.ZERO
				else:
					action = "Perched"
					action_time = 20
					velocity = Vector3.ZERO
				$model/AnimationPlayer.play(action)
	
	move_and_slide()
