extends Critter
@export var follow : PathFollow3D
@export var is_lead : bool

var vel = 0
var pos = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$model/AnimationPlayer.play("Swim")
	
func _physics_process(delta: float) -> void:
	if(is_lead):
		follow.progress += delta * 6
	if(randf_range(0,3) < delta and pos == 0 and follow.progress < 80):
		vel = 0.3
	vel = vel-(0.5 * delta)
	pos = max(0,pos + vel)
	global_position = follow.global_position + Vector3(0,pos,0)
	if(global_position.y > 1.2):
		$vis.position = Vector3(0,0,0)
	else:
		$vis.position = Vector3(0,-10,0)
	return
