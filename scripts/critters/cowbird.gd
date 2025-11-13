extends Critter

# special bird stuff
var perch = null
var ascending = true

func speed():
	return 7.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var last_perch = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Birds do not use any of the same state junk from critter.
func _physics_process(delta: float) -> void:
	action_time -= delta
	
	# if the perchtarg EVER gets stale, check that first.
	if(not is_instance_valid(perch)):
		# someone ate our bait..
		action = "Perched"
		action_time = 0
	
	if(action_time <= 0):
		if(action == "Eating"):
			get_nearest_bait().queue_free()

		# change the perchtarg
		if(ascending and get_nearest_bait() != null and global_position.distance_to(get_nearest_bait().global_position) < 100):
			perch = get_nearest_bait()

		if action == "Perched" or action == "RestingIDLE" or action == "Eating":
			# time 2 go
			ascending = true
			perch = null

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
					action_time = 20
					velocity = Vector3.ZERO
				$model/AnimationPlayer.play(action)
	
	if(velocity != Vector3(0,0,0)):
		look_at_grad(delta,global_position + velocity)
	move_and_slide()
