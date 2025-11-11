# script for generic critter.
extends CharacterBody3D
class_name Critter

@export var species : String

# state and state time.
var action = "Resting"
var action_time = 0.0

var emoticon = preload("res://tscn/emoticon.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# helper
func dist_to_player():
	return global_position.distance_to(get_node("../../Player").global_position)

func get_anim_length(animname):
	return $model/AnimationPlayer.get_animation(animname).length

func get_nearest_bait():
	var best = null
	for v in get_node("../../Baits").get_children():
		if best == null or global_position.distance_to(v.global_position) < global_position.distance_to(best.global_position):
			best = v
	return best
	
func make_emoticon():
	var e = emoticon.instantiate()
	get_node("../../Emoticons").add_child(e)
	e.global_position = global_position
	

# to be overridden:
func pick_action():
	action = "idle"
	action_time = 2.0
func speed():
	return 1.0
func rotspeed():
	return 10.0

func look_at_grad(delta,target_pos):
	var target_vec = global_position - target_pos 

	if not target_vec.length():
		return

	var target_rotation = lerp_angle(
		global_rotation.y,
		atan2(target_vec.x, target_vec.z),
		rotspeed() * delta
	)
	global_rotation.y = target_rotation
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
# handles every behavior for each action. this is a little dirty but it works.
func _physics_process(delta: float) -> void:
	action_time -= delta
		
	if(action_time > 0):
		
		# !! Action Lookup Map
		if(action == "Walking" or action == "Rolling" or action == "Roll Starting" or action == "Roll Ending"):
			
			var dest = $nav.get_next_path_position()
			var local_dest = dest - global_position
			
			if(local_dest.length() < 0.2):
				# close enough, next action.
				pick_action()
				return
			
			# set the speed and move the player + lookdir
			var dir = local_dest.normalized()
			velocity = dir * speed()
			look_at_grad(delta,global_position + velocity)
			move_and_slide()
		
		elif(action == "Eating"):
			if(get_nearest_bait() != null):
				# always turn toward the nearest bait.
				look_at_grad(delta, get_nearest_bait().global_position)
				print(get_nearest_bait().global_position)
			
		
		elif(action == "Turning"):
			look_at_grad(delta, get_node("../../Player").global_position)
			
		# any of the idle actions
		elif(action.contains("IDLE")):
			pass
			
		else:
			print("unknown action " + action)
	else:
		pick_action()
