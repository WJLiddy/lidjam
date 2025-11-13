extends Critter

# special bird stuff
var perch = null
var ascending = true

@export var general_only : bool

func speed():
	return 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
# Birds do not use any of the same state junk from critter.
func _physics_process(delta: float) -> void:
	action_time -= delta
	
	if(action_time < 0):
		if action == "Perched" or action == "RestingIDLE":
			# time 2 go
			ascending = true
			
		# if we're ascending, keep flying up
		if ascending:
			perch = pick_perch_retry(general_only,5)
			if(perch != null):
				ascending = false
			else:
				velocity = Vector3(randf_range(-0.4,0.4),1,randf_range(-0.4,0.4)).normalized() * speed()
				action = "Flying"
				action_time = get_anim_length(action)
		if not ascending:
			velocity = (perch.global_position - global_position).normalized() * speed()
			action = "Flying"
			action_time = get_anim_length(action)
			# made it
			if((perch.global_position - global_position).length() < 0.1):
				action = "Perched"
				action_time =  get_anim_length(action)
				velocity = Vector3.ZERO
		$model/AnimationPlayer.play(action)
	else:
		if not ascending and action != "Perched":
			velocity = (perch.global_position - global_position).normalized() * speed()
			if((perch.global_position - global_position).length() < 0.1):
				action_time = 0
		if(velocity != Vector3(0,0,0)):
			look_at_grad(delta,global_position + velocity)
		move_and_slide()
