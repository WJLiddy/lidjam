# script for generic critter.
extends CharacterBody3D
class_name Critter

@export var species : String

# state and state time.
var action = "RestingIDLE"
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
	
func player_is_whistling():
	return get_node("../../Player").whistling
	
func player_is_ads():
	return get_node("../../Player").ads_enabled

func get_nearest_bait():
	var best = null
	for v in get_node("../../Baits").get_children():
		if best == null or global_position.distance_to(v.global_position) < global_position.distance_to(best.global_position):
			best = v
	if is_instance_valid(best):
		return best
	return null

func pick_perch_retry(all,cnt):
	for i in range(cnt):
		var v = pick_perch(all)
		if(v != null):
			return v
	return null

func pick_perch(all_perches):
	var possible = get_node("../../Nav/Foliage").find_children("Perch").pick_random()
	if(not all_perches):
		possible = get_node("../../Nav/Foliage").find_children("SpawnPerch").pick_random()
	# first of all, check if this perch is claimed by any other bird.
	for v in get_parent().get_children():
		if((v.species == "Cresbird" or v.species == "Cowbird") and possible == v.perch):
			return null
			# tried to claim a perch but it's someone elses.
			
	# unclaimed perch if we can reach it.
	var space_state = get_world_3d().direct_space_state
	var coll_mask = 1
	var query = PhysicsRayQueryParameters3D.create(global_position + Vector3(0,1,0), possible.global_position,coll_mask)
	var result = space_state.intersect_ray(query)
	if result.is_empty():
		return possible
	return null


@onready var center: Node3D = get_node("../../EscapeHints")

# Project a 3D vector onto the XZ plane and normalize
func flat_dir_to(pos: Vector3) -> Vector3:
	var v = pos - center.global_position
	v.y = 0.0
	var len2 = v.length_squared()
	return Vector3.ZERO if len2 == 0.0 else v.normalized()

# 3D cross product sign for 2D (XZ plane) using the Y component only
func cross_sign(a: Vector3, b: Vector3) -> float:
	return (a.cross(b)).y

# Same-side check relative to player's direction
func is_same_side(player_dir: Vector3, monster_dir: Vector3, hint_dir: Vector3) -> bool:
	var s_mon = cross_sign(player_dir, monster_dir)
	var s_hint = cross_sign(player_dir, hint_dir)
	return s_mon * s_hint >= 0.0

# --- main function ---

func set_nav_flee_from_player():
	# collect only Node3D hints
	var hints = center.get_children()
	var player_dir = flat_dir_to(get_node("../../Player").global_position)
	var monster_dir = flat_dir_to(global_position)

	var best: Node3D = null
	var best_dist := 1e20

	for hint in hints:
		var hint_dir = flat_dir_to(hint.global_position)

		# forbidden if hint is on opposite side of player direction
		if not is_same_side(player_dir, monster_dir, hint_dir):
			continue
			

		var d = global_position.distance_to(hint.global_position)
		if d < best_dist and d > 10:
			best_dist = d
			best = hint

	if(best != null):
		print("Wants " + str(best))
	else:
		print("WARNING! USED FALLBACK!")
		best = center.get_children()[0]
	$nav.set_target_position(best.global_position)
	
func set_nav_meander():
	$nav.set_target_position(global_position + Vector3(randf_range(-5,5),0,randf_range(-5,5)))

func make_emoticon(t):
	var e = emoticon.instantiate()
	e.set_type(t)
	get_node("../../Emoticons").add_child(e)
	e.global_position = global_position
	e.follow = $emote
	
# not great but crunch time
# multiply by player_distance. a high stealth mult makes player seem farther away than actually is.
func stealth_mult():
	var player = get_node("../../Player")
	var to_player = (player.global_position - global_position).normalized()

	var forward = -global_transform.basis.z.normalized()

	var dot = forward.dot(to_player)

	var facing_mult = 1
	if dot > 0.7:
		facing_mult = 1.5
		
	if(player.speed == player.sprint_speed):
		return 1 / (1.5 * facing_mult)
	if(player.speed == player.crouch_speed):
		return 1 / (0.5 * facing_mult)
	
	return 1 / facing_mult


# to be overridden:
func pick_action():
	print("pick action not overridden!")
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
		
		# DEBUG!!!
		if(not(action.replace("IDLE","") in get_node("../../Puter/pc-monitor").pose_score)):
			print("CRITICAL ERROR! CANT SCORE " +  action)
			
		var walk_actions = ["Walking","Rolling","Flying","Scared","Waddling"]
		var look_at_player_actions = ["Turning","Listening","Excited","Judging","Petrified"]
		# !! Action Lookup Map
		if(action in walk_actions):
			
			var dest = $nav.get_next_path_position()
			var local_dest = dest - global_position
			
			if(local_dest.length() < 0.2):
				# close enough, next action.
				pick_action()
				return
			

			# Calculate movement direction and look
			var dir = local_dest.normalized()
			velocity.x = dir.x * speed()
			velocity.z = dir.z * speed()

			look_at_grad(delta, global_position + velocity)

			# Apply gravity if needed
			if not is_on_floor():
				velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
			else:
				velocity.y = 0.0  # reset Y when grounded

			# Slide with floor snapping for smooth contact
				# --- Stick to floor ---
			floor_snap_length = 0.3  # makes the character hug slopes & steps
			move_and_slide()
		
		elif(action == "Eating" or action == "Curious"):
			if(get_nearest_bait() != null):
				# always turn toward the nearest bait.
				look_at_grad(delta, get_nearest_bait().global_position)
			
		elif(action in look_at_player_actions):
			look_at_grad(delta, get_node("../../Player").global_position)
			
		elif(action == "Swimming"):
			#  placeholder
			if(action_time > 10):
				global_position = global_position.move_toward(global_position + Vector3(0,0,1),speed()*delta)
				look_at_grad(delta, global_position + Vector3(0,0,1))
			else:
				global_position = global_position.move_toward(global_position + Vector3(0,0,-1),speed()*delta)
				look_at_grad(delta, global_position + Vector3(0,0,-1))
				
			
		# any of the idle actions
		elif(action.contains("IDLE")):
			if not is_on_floor():
				velocity.y = -1
			else:
				velocity = Vector3(0,0,0)
			
		else:
			print("unknown action " + action + " from " + species)
	else:
		pick_action()
