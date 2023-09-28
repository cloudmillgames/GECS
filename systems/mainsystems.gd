extends GSystems

func sysinit():
	define_system(["vehicle", "shake"], "vehicle_shake")
	define_system(["vehicle"], "vehicle_tint")
	define_system(["playercontrol", "directctrl"], "player_controls")
	define_system(["directctrl", "vehicle", "movebounds"], "vehicle_direct_control")
	define_system(["turret", "directctrl", "audio"], "turret_direct_control")
	define_system(["killbounds"], "kill_bounds")

# Shake vehicle to indicate it's a vehicle
# compslist: vehicle, shake
func vehicle_shake(tdelta, ent):
	# Shake the cube
	var shake = ent.get_node("comps/shake")
	if shake.what:
		var r = [randf() * shake.strength, randf() * shake.strength, randf() * shake.strength]
		var what:Node3D = get_node(shake.what) as Node3D
		what.transform = shake.origin
		what.translate(Vector3(randf() * shake.strength, randf() * shake.strength, randf() * shake.strength))
	
# Mchackson says, since this is a single component system you can just move it to _process_physics() of vehicle
# compslist: vehicle
func vehicle_tint(tdelta, ent):
	var vehicle = ent.get_node("comps/vehicle")
	var apply_to = vehicle.apply_color_to
	if apply_to and vehicle.tint_color != Color.WHITE:
		# comps/vehicle is two levels in, apply_to starts with "../../" which means we could refs it from here (hacky I know)
		var obj = get_node(apply_to)
		if obj:
			obj.material.albedo_color = vehicle.tint_color

# compslist: playercontrol, directctrl
func player_controls(tdelta, ent):
	var directctrl = get_component(ent, "directctrl")
	directctrl.movement = Vector3.ZERO
	directctrl.turn = 0.0
	if Input.is_action_pressed("move_up"):
		directctrl.movement.z -= 1
	if Input.is_action_pressed("move_down"):
		directctrl.movement.z += 1
	if Input.is_action_pressed("move_right"):
		directctrl.movement.x = 1.0
	if Input.is_action_pressed("move_left"):
		directctrl.movement.x = -1.0
	if Input.is_action_pressed("turn_right"):
		directctrl.turn = 1.0
	if Input.is_action_pressed("turn_left"):
		directctrl.turn = -1.0
	if Input.is_action_pressed("trigger"):
		directctrl.trigger = true

# compslist: directctrl, vehicle, movebounds
func vehicle_direct_control(tdelta, ent):
	var directctrl = get_component(ent, "directctrl")
	var vehicle = get_component(ent, "vehicle")
	var bounds = get_component(ent, "movebounds").bounds as AABB
	
	if directctrl.turn != 0:
		ent.rotate_y(-directctrl.turn * vehicle.angular_speed * tdelta)
	
	var pos = ent.global_position
	if not bounds.has_point(pos):
		# modify control to prevent leaving area, we have 4 directions vehicle can leave +X, -X, +Z, -Z
		var control_filter:Vector3 = Vector3(1, 1, 1)
		if directctrl.movement.x > 0:
			control_filter.x = 0 if pos.x > bounds.end.x else 1
		elif directctrl.movement.x < 0:
			control_filter.x = 0 if pos.x < bounds.position.x else 1
		if directctrl.movement.z > 0:
			control_filter.z = 0 if pos.z > bounds.end.z else 1
		elif directctrl.movement.z < 0:
			control_filter.z = 0 if pos.z < bounds.position.z else 1
		directctrl.movement *= control_filter
	
	var direction = (Transform3D.IDENTITY * directctrl.movement.normalized())
	if direction:
		ent.velocity.x = direction.x * vehicle.speed
		ent.velocity.z = direction.z * vehicle.speed
	else:
		ent.velocity.x = move_toward(ent.velocity.x, 0, vehicle.speed)
		ent.velocity.z = move_toward(ent.velocity.z, 0, vehicle.speed)
	
	ent.move_and_slide()

# compslist: directctrl, turret, audio
func turret_direct_control(tdelta, ent):
	var turret = get_component(ent, "turret")
	var directctrl = get_component(ent, "directctrl")
	if turret._timer > 0:
		if directctrl.trigger:
			directctrl.trigger = false
		turret._timer -= tdelta
	elif directctrl.trigger:
		var audio = get_component(ent, "audio")
		var player = get_node(audio.stream_player) as AudioStreamPlayer3D
		player.stream = audio.sounds[0]
		player.play()
		var pr:Node3D = turret.projectile.instantiate()
		var fm:Marker3D = get_node(turret.fire_marker) as Marker3D
		pr.transform = fm.global_transform
		pr.linear_velocity = -turret.speed * pr.transform.basis.z 
		get_tree().root.add_child(pr)
		turret._timer = turret.cooldown

# compslist: killbounds
func kill_bounds(tdelta, ent):
	var bounds = get_component(ent, "killbounds")
	var pos = ent.global_position
	if pos.x > bounds.max_corner.x or pos.y > bounds.max_corner.y or pos.z > bounds.max_corner.z or pos.x < bounds.min_corner.x or pos.y < bounds.min_corner.y or pos.z < bounds.min_corner.z:
		ent.queue_free()
