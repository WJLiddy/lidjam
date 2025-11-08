extends Critter
@export var follow : PathFollow3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(species == "fishguy"):
		follow.progress += delta * 60
		global_position = follow.global_position
		return
