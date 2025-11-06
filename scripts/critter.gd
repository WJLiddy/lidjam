extends CharacterBody3D
@export var species : String

var action_time = 0.0
var action = "idle"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	action_time -= delta
	if(action_time > 0):
		# we should do the present action
		if(action == "walking"):
			velocity = basis.z
			move_and_slide()
		if(action == "tpose"):
			rotate_y(delta)
		else:
			velocity = Vector3(0,0,0)
	else:
		# pick new action
		action = ["idle","walking","tpose"].pick_random()
		$rigmodel/AnimationPlayer.play(action)
		action_time = randf_range(2.0,5.0)
