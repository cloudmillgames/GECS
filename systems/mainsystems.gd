extends GSystems

var PSDelayedFunc:PackedScene = preload("res://components/delayedfunc.tscn")
var PSTurretTarget:PackedScene = preload("res://components/turret_target.tscn")
var PSProjectileImpact:PackedScene = preload("res://entities/projectile_impact.tscn")
var PSVehicleExplode:PackedScene = preload("res://entities/vehicle_explode.tscn")

func sysinit():
	define_system(["shake"], 								"thing_shake")
	define_system(["vehicle"], 								"vehicle_tint")
	define_system(["playercontrol", "directctrl"], 			"player_controls")
	define_system(["directctrl", "vehicle", "movebounds"], 	"vehicle_direct_control")
	define_system(["turret", "directctrl", "audio"], 		"turret_direct_control")
	define_system(["killbounds"], 							"kill_bounds")
	define_system(["enemy_spawner"],						"spawn_enemy")
	define_system(["cmdctrl", "vehicle"],					"vehicle_command_control")
	define_system(["turret", "turret_trigger"],				"turret_cmdctrl")
	define_system(["escapequiter"],							"run_escape_quitter")
	define_system(["health", "killable"],					"health_killable")
	define_system(["projectile", "collisionevent"],			"projectile_collision")
	define_singleton_system("lose_condition")

func lose_condition(tdelta):
	var player = get_first_tagged_ent("player")
	if player == null and not GameSession.gameover:
		GameSession.gameover = true
		print("GAMEOVER")
		var delayedfunc = PSDelayedFunc.instantiate()
		delayedfunc.delay = 2
		delayedfunc.object = GECS
		delayedfunc.func_name = "change_scene_to"
		delayedfunc.func_arg = "res://scenes/game_over_scene.tscn"
		GECS.spawn_ent_comp("res://systems/mainsystems.tscn", delayedfunc)

func run_escape_quitter(tdelta, ent):
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()

# Shake thing
# compslist: shake
func thing_shake(tdelta, ent):
	var shake = get_comp("shake")
	if shake.what:
		var r = [randf() * shake.strength, randf() * shake.strength, randf() * shake.strength]
		var what:Node3D = get_node(shake.what) as Node3D
		what.transform = shake.origin
		what.translate(Vector3(randf() * shake.strength, randf() * shake.strength, randf() * shake.strength))
	
# Mchackson says, since this is a single component system you can just move it to _process_physics() of vehicle
# compslist: vehicle
func vehicle_tint(tdelta, ent):
	var vehicle = get_comp("vehicle")
	var apply_to = vehicle.apply_color_to
	if apply_to and vehicle.tint_color != Color.WHITE:
		# comps/vehicle is two levels in, apply_to starts with "../../" which means we could refs it from here (hacky I know)
		var obj = get_node(apply_to)
		if obj:
			obj.material.albedo_color = vehicle.tint_color

# compslist: playercontrol, directctrl
func player_controls(tdelta, ent):
	var directctrl = get_comp("directctrl")
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
	var directctrl = get_comp("directctrl")
	var vehicle = get_comp("vehicle")
	var bounds = get_comp("movebounds").bounds as AABB
	
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
	ent.velocity.y = 0
	
	ent.move_and_slide()

# compslist: directctrl, turret, audio
func turret_direct_control(tdelta, ent):
	var turret = get_comp("turret")
	var directctrl = get_comp("directctrl")
	if turret._timer > 0:
		if directctrl.trigger:
			directctrl.trigger = false
		turret._timer -= tdelta
	elif directctrl.trigger:
		turret.fire()

# compslist: killbounds
func kill_bounds(tdelta, ent):
	var bounds = get_comp("killbounds")
	var pos = ent.global_position
	if pos.x > bounds.max_corner.x or pos.y > bounds.max_corner.y or pos.z > bounds.max_corner.z or pos.x < bounds.min_corner.x or pos.y < bounds.min_corner.y or pos.z < bounds.min_corner.z:
		ent.queue_free()

# compslist: enemy_spawner
func spawn_enemy(tdelta, ent):
	var es = get_comp("enemy_spawner")
	if es._timer > 0:
		es._timer = max(es._timer - tdelta, 0)
	else:
		var path_follow = get_comp_node(es.spawn_follow_path) as PathFollow3D
		path_follow.progress_ratio = randf()
		
		var pos_start = path_follow.position
		path_follow.progress_ratio = fmod(path_follow.progress_ratio + 0.5, 1.0)
		var pos_end = path_follow.position
		
		var enemy = es.enemy_scene.instantiate() as Node3D
		enemy.position = pos_start
		get_parent().get_parent().add_child(enemy)
		
		var cmd = ent_get_comp(enemy, "cmdctrl")
		var chance = randf()
		if chance <= es.chance_attack or true:
			var halfway = pos_end - pos_start
			var alpha = 0.2 + 0.6 * randf() # between 20% and 80% of the way
			halfway = pos_start + (halfway.normalized() * halfway.length() * alpha)
			cmd.queue_moveto(halfway)
			cmd.queue_halt(0.5)
			cmd.queue_fire("player")
		cmd.queue_moveto(pos_end)
		cmd.queue_destruct()
		
		es._timer = es.spawn_duration_range.x + ((es.spawn_duration_range.y - es.spawn_duration_range.x) * randf())

# compslist: command_control, vehicle
func vehicle_command_control(tdelta, ent):
	var cc = get_comp("cmdctrl")
	if cc._halt_timer > 0:
		cc._halt_timer = max(cc._halt_timer - tdelta, 0)
	else:
		if cc._current_cmd == cc.CMD_TYPE.NONE:
			if len(cc.cmd_queue) > 0:
				cc._current_cmd = cc.cmd_queue.pop_front()
				cc._current_data = cc.data_queue.pop_front()
		else:
			match cc._current_cmd:
				cc.CMD_TYPE.MOVE_TO:
					var vehicle = get_comp("vehicle")
					var pos_cur = ent.position
					var pos_end = cc._current_data
					var dir = pos_end - pos_cur
					var dist = dir.length()
					dir = dir / dist
					#if dir:
					if dist > 0.2:
						ent.velocity.x = dir.x * vehicle.speed
						ent.velocity.z = dir.z * vehicle.speed
					else:
						ent.velocity.x = move_toward(ent.velocity.x, 0, vehicle.speed)
						ent.velocity.z = move_toward(ent.velocity.z, 0, vehicle.speed)
						if ent.velocity.x < 0.01:
							cc._current_cmd = cc.CMD_TYPE.NONE
					ent.move_and_slide()
				cc.CMD_TYPE.HALT:
					cc._halt_timer = cc._current_data
					assert(cc._halt_timer > 0.0)
					cc._current_cmd = cc.CMD_TYPE.NONE
				cc.CMD_TYPE.FIRE:
					if has_comp("turret"):
						add_tag_comp("turret_trigger")
						if not cc._current_data.is_empty():
							var tgt = get_first_tagged_ent(cc._current_data)
							var tt = add_comp(PSTurretTarget, true)
							tt.target = tgt
					cc._current_cmd = cc.CMD_TYPE.NONE
				cc.CMD_TYPE.DESTRUCT:
					destruct()
					cc._current_cmd = cc.CMD_TYPE.NONE

# compslist: turret, turret_trigger (optional: turret_target)
func turret_cmdctrl(tdelta, ent):
	var turret = get_comp("turret")
	if turret._timer > 0:
		turret._timer -= tdelta
	else:
		var tgt = null
		if has_comp("turret_target"):
			var tt = get_comp("turret_target")
			tgt = tt.target
			remove_comp("turret_target")
		turret.fire(tgt)
		remove_comp("turret_trigger")
		
# compslist: health, killable
func health_killable(tdelta, ent):
	var health = get_comp("health")
	if health.hp <= 0:
		if has_comp("vehicle"):
			var ve = PSVehicleExplode.instantiate()
			ve.position = ent.global_position
			get_tree().root.add_child(ve)
		destruct()

# compslist: projectile, collisionevent
func projectile_collision(tdelta, ent):
	var collisionevent = get_comp("collisionevent")
	if collisionevent.collided:
		var other = collisionevent.with
		if ent_has_comp(other, "health"):
			var health = ent_get_comp(other, "health")
			var proj = get_comp("projectile")
			health.hp -= proj.damage
			if ent_has_comp(other, "vehicle") and ent_has_comp(other, "enemy"):
				var vehicle = ent_get_comp(other, "vehicle")
				GameSession.score += vehicle.value
		else:
			print("projectile_collision (mainsystems): killed `%s` cause it has no health comp" % other.name)
			destroy(other)
		# impact effect
		var projimp = PSProjectileImpact.instantiate()
		projimp.position = ent.global_position
		get_tree().root.add_child(projimp)
		destruct()
