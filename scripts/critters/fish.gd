extends Critter
@export var follow : PathFollow3D
@export var is_lead : bool

var vel = 0
var pos = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _physics_process(delta: float) -> void:
	if(is_lead):
		follow.progress += delta * 10
	if(randf_range(0,1.5) < delta and pos == 0):
		vel = 0.5
	vel = vel-delta
	pos = max(0,pos + vel)
	global_position = follow.global_position + Vector3(0,pos,0)
	return
