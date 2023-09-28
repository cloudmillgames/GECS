extends GSystems

func sysinit():
	define_system(["vehicle"], "vehicle_shake")
	define_system(["vehicle"], "vehicle_tint")
	define_system(["player_controls", "directctrl"], "player_controls")
	define_system(["directctrl", "vehicle"], "vehicle_direct_control")

# Shake vehicle to indicate it's a vehicle
# compslist: vehicle
func vehicle_shake(ent):
	pass

func vehicle_tint(ent):
	var vehicle = ent.get_node("comps/vehicle")
	var apply_to = vehicle.apply_color_to
	if apply_to:
		# comps/vehicle is two levels in, apply_to starts with "../../" which means we could refs it from here (hacky I know)
		var obj = get_node(apply_to)
		if obj:
			obj.material.albedo_color = vehicle.tint_color

# compslist: playercontrol, directctrl
func player_controls(ent):
	pass

# compslist: directctrl, vehicle
func vehicle_direct_control(ent):
	pass
