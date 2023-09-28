extends GComp

# Movement control using a command queue
enum CMD_TYPE {
	MOVE_TO,
	FIRE,
	DESTRUCT,
}
# One command = one action til completion
@export var cmd_queue:Array[CMD_TYPE]
# Each command is paired with one data here, any type. Ex: MOVE_TO should have target position data
@export var data_queue:Array

func compinit():
	compname = "Directctrl".to_lower()
