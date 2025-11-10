extends Critter

# special bird stuff
var perchtarg = null
var ascending = true

func speed():
	return 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# Birds do not use any of the same state junk from critter.
func _physics_process(delta: float) -> void:
	action_time -= delta
	if(action_time > 0):
		
		if action == "Perching" or action == "Resting":
			# time 2 go
			ascending = true
			perchtarg = get_node("../../Nav/Foliage").find_children("Perch").pick_random()
			
		# if we're ascending, keep flying up
		if ascending:
			if(global_position.y < 150):
				velocity = Vector3(randf_range(-0.4,0.4),1,randf_range(-0.4,0.4)).normalized() * speed()
				action = "Flying"
				action_time = get_anim_length(action)
				move_and_slide()
			else:
				ascending = false
		if not ascending:
			velocity = (perchtarg.global_position - global_position).normalized() * speed()
			# made it
			if((perchtarg.global_position - global_position).length() < 0.5):
				action = "Perching"
				action_time = 20
				velocity = Vector3.ZERO
			else:
				move_and_slide()
	
		$model/AnimationPlayer.play(action)
