extends Critter

# special bird stuff
var perchtarg = null
func speed():
	return 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	action_time -= delta
	if(action_time > 0):
		if action == "ascending":
			velocity = Vector3.UP * speed()
			move_and_slide()
			return
		if action == "flying":
			velocity = (perchtarg.global_position - global_position).normalized() * speed()
			# made it
			if((perchtarg.global_position - global_position).length() < 0.5):
				action = "idle"
				velocity = Vector3.ZERO
				return
			else:
				move_and_slide()
	else:
		if action == "ascending":
			action = "flying"
			action_time = 20
		elif(randi_range(0,1) == 1 and action == "idle"):
			perchtarg = get_node("../../Nav/Foliage").find_children("Perch").pick_random()
			action_time = 10
			action = "ascending"
		else:
			action = "idle"
			action_time = 5
