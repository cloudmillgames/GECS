extends GodwayVehicle
class_name GodwayEnemy

# Should be called: CmdCtrl

# Movement control using a command queue
enum CMD_TYPE {
	NONE,
	MOVE_TO,
	HALT,
	FIRE,
	DESTRUCT,
}
# One command = one action til completion
@export var cmd_queue:Array[CMD_TYPE]
# Each command is paired with one data here, any type. Ex: MOVE_TO should have target position data
@export var data_queue:Array

var _current_cmd:CMD_TYPE = CMD_TYPE.NONE
var _current_data
var _halt_timer:float = 0.0

func queue_command(cmd:CMD_TYPE, data = null):
	cmd_queue.append(cmd)
	data_queue.append(data)

func queue_moveto(pos:Vector3):
	queue_command(CMD_TYPE.MOVE_TO, pos)

func queue_halt(time:float):
	queue_command(CMD_TYPE.HALT, time)

# Can fire at a specific group, it'll grab first entity it finds in target_group and shoot at it
func queue_fire(target_group:String = ""):
	queue_command(CMD_TYPE.FIRE, target_group)

func queue_destruct():
	queue_command(CMD_TYPE.DESTRUCT)

func _physics_process(delta):
	vehicle_command_control(delta)

func vehicle_command_control(delta):
	if _halt_timer > 0:
		_halt_timer = max(_halt_timer - delta, 0)
	else:
		if _current_cmd == CMD_TYPE.NONE:
			if len(cmd_queue) > 0:
				_current_cmd = cmd_queue.pop_front()
				_current_data = data_queue.pop_front()
		else:
			match _current_cmd:
				CMD_TYPE.MOVE_TO:
					var vehicle = self
					var pos_cur = position
					var pos_end = _current_data
					var dir = pos_end - pos_cur
					var dist = dir.length()
					dir = dir / dist
					#if dir:
					if dist > 0.2:
						velocity.x = dir.x * vehicle.speed
						velocity.z = dir.z * vehicle.speed
					else:
						velocity.x = move_toward(velocity.x, 0, vehicle.speed)
						velocity.z = move_toward(velocity.z, 0, vehicle.speed)
						if velocity.x < 0.01:
							_current_cmd = CMD_TYPE.NONE
					move_and_slide()
				CMD_TYPE.HALT:
					_halt_timer = _current_data
					assert(_halt_timer > 0.0)
					_current_cmd = CMD_TYPE.NONE
				CMD_TYPE.FIRE:
					var turret = get_node_or_null("turret")
					if turret:
						turret.trigger = true
						if not _current_data.is_empty():
							var tgt = get_tree().get_first_node_in_group("player")
							turret.target = tgt
					_current_cmd = CMD_TYPE.NONE
				CMD_TYPE.DESTRUCT:
					queue_free()
					_current_cmd = CMD_TYPE.NONE
