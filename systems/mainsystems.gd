extends GSystems

func sysinit():
	define_system(["vehicle", "shake"], "vehicle_shake")
	define_system(["vehicle"], "vehicle_tint")
	define_system(["player_controls", "directctrl"], "player_controls")
	define_system(["directctrl", "vehicle"], "vehicle_direct_control")

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
	pass

# compslist: directctrl, vehicle
func vehicle_direct_control(tdelta, ent):
	pass
