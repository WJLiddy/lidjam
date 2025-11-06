extends CharacterBody3D


@export var footstep_sound: Array[AudioStream]

var run_speed = 5.5
var speed = run_speed
var crouch_speed = 1.8

var jump_velocity = 10
var landing_velocity

var distance = 0
var footstep_distance = 2.1

var action_cooldown = 0
var ads_enabled = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if !Global.is_using_puter and event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x / 10
		%Camera3D.rotation_degrees.x -= event.relative.y / 10
		%Camera3D.rotation_degrees.x = clamp( %Camera3D.rotation_degrees.x, -90, 90 )
		

func _physics_process(delta: float) -> void:
	action_cooldown -= delta
	
	if(ads_enabled):
		%Camera3D.fov = lerp(%Camera3D.fov,35.0,7*delta)
	else:
		%Camera3D.fov = lerp(%Camera3D.fov,70.0,7*delta)
	
	if Global.is_using_puter:
		%Camera3D.global_position = %Camera3D.global_position.lerp(get_node("../Puter").global_position - Vector3(0,-0.2,-0.5), delta*10)
		%Camera3D.global_rotation = %Camera3D.global_rotation.lerp(Vector3(0,0,0), delta*10)
		return
	else:
		%Camera3D.position = %Camera3D.position.lerp(Vector3(0,0,0), delta*10)
		%Camera3D.rotation.y = lerp(%Camera3D.rotation.y, 0.0, delta*10)
		%Camera3D.rotation.z = lerp(%Camera3D.rotation.z, 0.0, delta*10)
		
	
	
	if not is_on_floor():
		velocity += get_gravity() * 2 * delta
		landing_velocity = -velocity.y
		distance = 0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		play_random_footstep_sound()

	if not $CeilingDetector.is_colliding():
		$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, 1.85, 0.1)
	else:
		$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, 1.38, 0.1)

	if is_on_floor():
		if landing_velocity != 0:
			landing_animation()
			landing_velocity = 0

		speed = run_speed
		if Input.is_action_pressed("crouch") or ads_enabled:
			speed = crouch_speed

	if Input.is_action_pressed("crouch"):
		$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, 1.38, 0.1)

	$MeshInstance3D.mesh.height = $CollisionShape3D.shape.height
	%HeadPosition.position.y = $CollisionShape3D.shape.height - 0.25

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	distance += get_real_velocity().length() * delta

	if distance >= footstep_distance:
		distance = 0
		if speed > crouch_speed:
			play_random_footstep_sound()

	move_and_slide()
	
	if Input.is_action_just_pressed("action") and action_cooldown < 0:
		# if we raycast into the computer, use it
		%CamRayCast.force_raycast_update()
		if %CamRayCast.is_colliding() and %CamRayCast.get_collider().name == "COMPUTER":
			Global.is_using_puter = true
		else:
			await RenderingServer.frame_post_draw
			take_picture()
			action_cooldown = 0.4
			
	if Input.is_action_just_pressed("ads"):
		ads_enabled = !ads_enabled
		if(ads_enabled):
			get_node("../../../ViewModel").ads_enable()
		else:
			get_node("../../../ViewModel").ads_disable()

func camera_dist_sort(a: Dictionary, b: Dictionary):
	return a["dist"] < b["dist"];

func take_picture():
	$Shutter.play()
	var picdata = {}
	
	# Get the image data from the viewport's texture
	var image = get_node("../").get_texture().get_image()
	picdata["image"] = image
	picdata["critters"] = []
	
	# now, grade the image. for each animalmm
	for c in get_node("../Critters").get_children():
		# if it's in front of the camera...
		if c.get_node("vis").is_on_screen():
			# do a raycast to make sure that there's no terrain or anything blocking him
			var space_state = get_world_3d().direct_space_state
			var coll_mask = 1
			var query = PhysicsRayQueryParameters3D.create($%Camera3D.global_position, c.get_node("vis").global_position,coll_mask)
			var result = space_state.intersect_ray(query)
			print(result)
			if result.is_empty():
				# get data
				var critter = {}
				critter["name"] = c.species
				critter["dist"] = c.global_position.distance_to(global_position)
				critter["orient"] = abs(global_rotation.y - c.global_rotation.y)
				critter["pose"] = c.get_node("rigmodel/AnimationPlayer").current_animation
				picdata["critters"].push_back(critter)
				print(critter)
	
	# sort all the critters by distance.
	picdata["critters"].sort_custom(camera_dist_sort)
	
	get_node("../../../UIRender").push_image(image)
	Global.add_pic(picdata)
	

func landing_animation():
	if landing_velocity >= 2:
		play_random_footstep_sound()

	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	var amplitude = clamp( landing_velocity / 100, 0.0, 0.3)

	tween.tween_property(%LandingAnimation, "position:y", -amplitude, amplitude)
	tween.tween_property(%LandingAnimation, "position:y", 0, amplitude)


func play_random_footstep_sound() -> void:
	if footstep_sound.size() > 0:
		$FootstepSound.stream = footstep_sound.pick_random()
		$FootstepSound.play()
