extends CharacterBody3D


@export var footstep_sound: Array[AudioStream]

var run_speed = 7
var sprint_speed = 11
var speed = run_speed
var crouch_speed = 2

var jump_velocity = 8
var landing_velocity

var distance = 0
var footstep_distance = 2.1

var action_cooldown = 0
var ads_enabled = false
var double_zoom = false
var whistling = false

var ads_zoom_delay = 0
var putawaytime = 0

var fov_base = 70.0
var fov_zoom = 70.0 / 3
var fov_double_zoom = 70.0 / 6

var tutprog = 0
var tut_timer = 0

const bait = preload("res://tscn/bait.tscn")

var othertuts = [false,false,false]

var got_money = false


func _input(event: InputEvent) -> void:
	if !Global.is_using_puter and event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x / 10
		%Camera3D.rotation_degrees.x -= event.relative.y / 10
		%Camera3D.rotation_degrees.x = clamp( %Camera3D.rotation_degrees.x, -90, 90 )
		

func write_tutorial(targ,strn):
	if(targ == tutprog):
		get_node("../../../UIRender/Tutorial").text = strn
		tutprog += 1

func _physics_process(delta: float) -> void:

	if Global.is_on_title:
		return
	
	action_cooldown -= delta
	putawaytime -= delta
	ads_zoom_delay -= delta
	tut_timer -= delta
	# 8 is the "finished" state
	if(tut_timer < 0):
		write_tutorial(7,"")
		
	
	var speedup = 1
	if(Global.quickscope_unlocked):
		speedup = 4
	
	if(ads_enabled and ads_zoom_delay < 0):
		if(double_zoom):
			%Camera3D.fov = lerp(%Camera3D.fov,fov_double_zoom,3*speedup*delta)
		else:
			%Camera3D.fov = lerp(%Camera3D.fov,fov_zoom,3*speedup*delta)
	else:
		%Camera3D.fov = lerp(%Camera3D.fov,fov_base,3*speedup*delta)
	
	if Global.is_using_puter:
		write_tutorial(4,"")
		%Camera3D.global_position = %Camera3D.global_position.lerp(get_node("../Puter").global_position - Vector3(0,-0.27,0.4), delta*10)
		var target_rot = Vector3(0, deg_to_rad(180), 0)
		%Camera3D.global_rotation = Vector3(
			lerp_angle(%Camera3D.global_rotation.x, target_rot.x, delta * 10),
			lerp_angle(%Camera3D.global_rotation.y, target_rot.y, delta * 10),
			lerp_angle(%Camera3D.global_rotation.z, target_rot.z, delta * 10)
		)
		return
	else:
		if(Global.bests.keys().size() > 0):
			write_tutorial(5,"Press C to Sneak")
			
		# handle other tutsw
		if((not othertuts[0]) and tutprog == 8 and Global.shoes_unlocked):
			write_tutorial(8,"Press Shift to sprint")
			othertuts[0] = true
		if((not othertuts[1]) and tutprog == 8 and Global.bait_unlocked):
			write_tutorial(8,"Press Z to throw bait")
			tutprog = 19
			othertuts[1] = true
		if((not othertuts[2]) and tutprog == 8 and Global.whistle_unlocked):
			write_tutorial(8,"Press X to use whistle")
			tutprog = 29
			othertuts[2] = true
			
			
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
			write_tutorial(6,"Go take some uplifting pictures!")
			tut_timer = 3
			speed = crouch_speed
		else:
			if Input.is_action_pressed("sprint") and Global.shoes_unlocked:
				if(tutprog == 9):
					write_tutorial(9,"")
					tutprog = 8
				speed = sprint_speed
				get_node("../../../ViewModel").cam_hide()
			else:
				get_node("../../../ViewModel").cam_show()
			


	if Input.is_action_pressed("crouch"):
		$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, 1.38, 0.1)

	$MeshInstance3D.mesh.height = $CollisionShape3D.shape.height
	%HeadPosition.position.y = $CollisionShape3D.shape.height - 0.25

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if(direction.length() > 0):
		write_tutorial(0,"Take a Pic with Left Mouse Button")
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
	
	if Input.is_action_just_pressed("action") and action_cooldown < 0 and speed != sprint_speed:
		# if we raycast into the computer, use it
		%CamRayCast.force_raycast_update()
		if %CamRayCast.is_colliding() and %CamRayCast.get_collider().name == "COMPUTER" and (not ads_enabled):
			Global.is_using_puter = true
			# hide the camera
			get_node("../../../ViewModel").cam_hide()
		elif %CamRayCast.is_colliding() and %CamRayCast.get_collider().name == "GRAVE" and (not ads_enabled):
			%CamRayCast.get_collider().get_node("GANIM").play("GANIM")
			for v in get_node("../Critters").get_children():
				if (v.species == "Bugleton"):
					v.bugle = true
		elif %CamRayCast.is_colliding() and %CamRayCast.get_collider().name == "JACKPOT" and (not ads_enabled):
			%CamRayCast.get_collider().get_node("JANIM").play("JANIM")
			%CamRayCast.get_collider().get_node("Jackpot").play()
			%CamRayCast.get_collider().get_node("Money").visible = true

			
			if(not got_money):
				Global.money += 20
				got_money = true
			
		else:
			get_node("../Emoticons").visible = false
			await RenderingServer.frame_post_draw
			take_picture()
			action_cooldown = 0.4
			
	if Input.is_action_just_pressed("ads"):
		if(ads_enabled and Global.zoom_unlocked and not double_zoom):
			double_zoom = true
			return
		else:
			# you may NOT ads if the camera is being putaway
			if((not ads_enabled) and putawaytime > 0):
				return
			ads_enabled = !ads_enabled
			double_zoom = false
		if(ads_enabled):
			get_node("../../../ViewModel").ads_enable()
			write_tutorial(2,"Take a picture of the turtle")
			ads_zoom_delay = 0.4
			if(Global.quickscope_unlocked):
				ads_zoom_delay = 0.3
		else:
			putawaytime = 0.3
			get_node("../../../ViewModel").ads_disable()
	
	if Input.is_action_just_pressed("bait") and Global.bait_unlocked and Global.bait > 0 and not ads_enabled and speed != sprint_speed:
		if(tutprog == 19):
			write_tutorial(19,"")
			tutprog = 8
		Global.bait -= 1
		var b = bait.instantiate()
		b.apply_impulse(velocity + (-$%Camera3D.global_basis.z.normalized() * 10))
		
		get_node("../Baits").add_child(b)
		b.global_position = $%Camera3D/ThrowPos.global_position
		b.angular_velocity = Vector3(randi_range(-3, 3), randi_range(-3, 3), randi_range(-3, 3))
		
	if Input.is_action_pressed("whistle") and Global.whistle_unlocked and not ads_enabled and speed != sprint_speed:
		if(tutprog == 29):
			write_tutorial(29,"")
			tutprog = 8
		whistling = true
		$WhistleSound.volume_db = lerp($WhistleSound.volume_db,0.0,10*delta)
		get_node("../../../UIRender").whistling = true
		get_node("../../../ViewModel").whis_show()
		if(!$WhistleSound.playing):
			$WhistleSound.play()
	else:
		whistling = false
		$WhistleSound.volume_db = lerp($WhistleSound.volume_db,-80.0,10*delta)
		get_node("../../../ViewModel").whis_hide()
		get_node("../../../UIRender").whistling = false
		
	get_node("../../../UIRender").critterprevtext = getcritterprevtext()

func getcritterprevtext():
	if(ads_zoom_delay > 0):
		return ""
	var maincritter = null
	var bestpct = 0
	
	for c in get_node("../Critters").get_children():
		# if it's in front of the camera...
		if c.get_node("vis").is_on_screen():
			# do a raycast to make sure that there's no terrain or anything blocking him
			var space_state = get_world_3d().direct_space_state
			var coll_mask = 1
			var query = PhysicsRayQueryParameters3D.create($%Camera3D.global_position, c.get_node("vis").global_position,coll_mask)
			var result = space_state.intersect_ray(query)
			if result.is_empty():
				var pct = get_screen_coverage_percent(%Camera3D,c.get_node("vis"))
				if(pct > bestpct):
					maincritter = c.species
					bestpct = pct
	if(maincritter == null):
		return ""
	return maincritter
	

func take_picture():
	write_tutorial(1,"Zoom with Right Mouse Button")
	if(Global.pics.size() == Global.picsmax):
		return
	
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
			if result.is_empty():
				# get data
				var critter = {}
				critter["name"] = c.species
				if(c.species == "Olturtle"):
					write_tutorial(3,"Upload your pic to the computer")
				critter["dist"] = get_screen_coverage_percent(%Camera3D,c.get_node("vis"))
				critter["orient"] = abs(global_rotation.y - c.global_rotation.y)
				critter["pose"] = c.action.replace("IDLE","")
				picdata["critters"].push_back(critter)
	
	get_node("../../../UIRender").push_image(image)
	Global.add_pic(picdata)
	get_node("../Emoticons").visible = true
	

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

func get_screen_coverage_percent(camera: Camera3D, visible_node: VisibleOnScreenNotifier3D) -> float:
	var aabb: AABB = visible_node.get_aabb()
	
	# Build 8 corners of the local AABB
	var local_corners = [
		aabb.position,
		aabb.position + Vector3(aabb.size.x, 0, 0),
		aabb.position + Vector3(0, aabb.size.y, 0),
		aabb.position + Vector3(0, 0, aabb.size.z),
		aabb.position + Vector3(aabb.size.x, aabb.size.y, 0),
		aabb.position + Vector3(aabb.size.x, 0, aabb.size.z),
		aabb.position + Vector3(0, aabb.size.y, aabb.size.z),
		aabb.position + aabb.size
	]
	
	# Convert to world space using Transform3D * Vector3
	var world_corners = []
	for lc in local_corners:
		world_corners.append(visible_node.global_transform * lc)
	
	# Project to screen space
	var screen_points = []
	for wc in world_corners:
		screen_points.append(camera.unproject_position(wc))
	
	# Find screen-space bounding box
	var min_x = screen_points[0].x
	var max_x = screen_points[0].x
	var min_y = screen_points[0].y
	var max_y = screen_points[0].y
	
	for p in screen_points:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)
	
	# Clamp within screen bounds
	var viewport_size = camera.get_viewport().get_visible_rect().size
	min_x = clamp(min_x, 0.0, viewport_size.x)
	max_x = clamp(max_x, 0.0, viewport_size.x)
	min_y = clamp(min_y, 0.0, viewport_size.y)
	max_y = clamp(max_y, 0.0, viewport_size.y)
	
	# Calculate area ratio
	var box_area = max(0.0, (max_x - min_x)) * max(0.0, (max_y - min_y))
	var screen_area = viewport_size.x * viewport_size.y
	
	return (box_area / screen_area) * 100.0
