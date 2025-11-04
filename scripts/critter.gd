extends Node3D
@export var species : String

var action_time = 0.0
var action = "idle"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$rigmodel/AnimationPlayer.play("walking")
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(action_time > 0):
		# we should do the present action
		if(action == "move"):
			pass
			#move_and_slide()
		
	if(action_time < 0):
		action_time = 2
	pass
