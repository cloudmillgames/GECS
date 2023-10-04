extends GodwayVehicle

func _physics_process(delta):
	movement = Vector3.ZERO
	turn = 0.0
	if Input.is_action_pressed("move_up"):
		movement.z -= 1
	if Input.is_action_pressed("move_down"):
		movement.z += 1
	if Input.is_action_pressed("move_right"):
		movement.x = 1.0
	if Input.is_action_pressed("move_left"):
		movement.x = -1.0
	if Input.is_action_pressed("turn_right"):
		turn = 1.0
	if Input.is_action_pressed("turn_left"):
		turn = -1.0
	if Input.is_action_pressed("trigger"):
		if get_node_or_null("turret"):
			$turret.trigger = true
	
	var pos = global_position
	if not bounds.has_point(pos):
		# modify control to prevent leaving area, we have 4 directions vehicle can leave +X, -X, +Z, -Z
		var control_filter:Vector3 = Vector3(1, 1, 1)
		if movement.x > 0:
			control_filter.x = 0 if pos.x > bounds.end.x else 1
		elif movement.x < 0:
			control_filter.x = 0 if pos.x < bounds.position.x else 1
		if movement.z > 0:
			control_filter.z = 0 if pos.z > bounds.end.z else 1
		elif movement.z < 0:
			control_filter.z = 0 if pos.z < bounds.position.z else 1
		movement *= control_filter
	
	super._physics_process(delta)
