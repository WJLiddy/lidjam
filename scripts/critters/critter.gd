# script for generic critter.
extends CharacterBody3D
class_name Critter

@export var species : String

# state and state time.
var action = "idle"
var action_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# helper
func dist_to_player():
	return global_position.distance_to(get_node("../../Player").global_position)

# to be overridden:
func pick_action():
	action = "idle"
	action_time = 2.0
func speed():
	return 1.0
func fleespeed():
	return 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
# handles every behavior for each action. this is a little dirty but it works.
func _physics_process(delta: float) -> void:
	action_time -= delta
	
	if(action_time > 0):
		
		# !! Action Lookup Map
		if(action == "walking" or action == "fleeing" or action == "baiting"):
			var dest = $nav.get_next_path_position()
			var local_dest = dest - global_position
			if(local_dest.length() < 0.1):
				# can't get there, try something else
				pick_action()
				return
			
			var dir = local_dest.normalized()
			velocity = dir * speed()
			if(action == "fleeing"):
				velocity = dir * fleespeed()
			look_at(transform.origin + Vector3(-1,0,-1)*velocity)
			move_and_slide()
			
		elif(action == "tpose"):
			rotate_y(delta)
			
		# any of the idle actions
		elif(action.contains("idle")):
			velocity = Vector3(0,0,0)
			
		else:
			print("unknown action " + action)
	else:
		pick_action()
