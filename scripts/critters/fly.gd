extends Critter

var home 
var targ
func _ready() -> void:
	home = global_position
	targ = global_position
	$model/AnimationPlayer.play("Flying")
	
func _physics_process(delta: float) -> void:
	if(global_position.distance_to(targ) < 1):
		targ = home + Vector3(randf_range(-5,5),0,randf_range(-5,5))
	global_position = global_position.move_toward(targ,delta * speed())
	look_at_grad(delta,targ)
	
