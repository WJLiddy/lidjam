extends CharacterBody3D
@export var species : String
@export var follow : PathFollow3D
var action_time = 0.0
var action = "idle"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if(species == "fishguy"):
		follow.progress += delta * 60
		global_position = follow.global_position
		return
	
	action_time -= delta
	if(action_time > 0):
		# we should do the present action
		if(action == "walking" or action == "fleeing"):
			var dest = $nav.get_next_path_position()
			var local_dest = dest - global_position
			var dir = local_dest.normalized()
			velocity = dir
			if(action == "fleeing"):
				velocity = dir * 3
			look_at(transform.origin + Vector3(1,0,1)*velocity)
			move_and_slide()
		if(action == "tpose"):
			rotate_y(delta)
			
		else:
			velocity = Vector3(0,0,0)
	else:
		# pick new action
		action = ["idle","walking","tpose"].pick_random()
		if(action == "walking"):
			$nav.set_target_position(global_position + Vector3(randf_range(-5,5),0,randf_range(-5,5)))
		$rigmodel/AnimationPlayer.play(action)
		action_time = randf_range(2.0,5.0)
		
	# check if should run from player.
	if(species == "smalltest" && global_position.distance_to(get_node("../../Player").global_position) < 10):
		$nav.set_target_position(global_position + ((global_position - get_node("../../Player").global_position).normalized() * 10))
		action = "fleeing"
		$rigmodel/AnimationPlayer.play("walking")
		action_time = 5
		
	
