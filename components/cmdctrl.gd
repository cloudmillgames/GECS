extends GComp

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

func compinit():
	compname = "cmdctrl"
	enttype = "CharacterBody3D"

# This is not trying to be pure ECS, it's ok to write initializer functions in components
func queue_command(cmd:CMD_TYPE, data = null):
	cmd_queue.append(cmd)
	data_queue.append(data)

func queue_moveto(pos:Vector3):
	queue_command(CMD_TYPE.MOVE_TO, pos)

func queue_halt(time:float):
	queue_command(CMD_TYPE.HALT, time)

func queue_fire():
	queue_command(CMD_TYPE.FIRE)

func queue_destruct():
	queue_command(CMD_TYPE.DESTRUCT)
