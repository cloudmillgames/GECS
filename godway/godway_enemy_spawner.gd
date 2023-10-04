extends Node3D

var enemy_scene:PackedScene = preload("res://godway/godway_enemy.tscn")

# PathFollow3D to use for random spawn location
@export var spawn_follow_path:PathFollow3D
# What's the percentage this enemy will attack player?
@export var chance_attack:float = 0.1
# What's the min and max time between spawns?
@export var spawn_duration_range:Vector2 = Vector2(0.5, 2.0)

# Time til next spawn
var _timer:float = 0.0

func _physics_process(delta):
	if _timer > 0:
		_timer = max(_timer - delta, 0)
	else:
		spawn_enemy(delta)

func spawn_enemy(delta):
	spawn_follow_path.progress_ratio = randf()
	
	var pos_start = spawn_follow_path.position
	spawn_follow_path.progress_ratio = fmod(spawn_follow_path.progress_ratio + 0.5, 1.0)
	var pos_end = spawn_follow_path.position
	
	var enemy = enemy_scene.instantiate()
	enemy.position = pos_start
	get_parent().add_child(enemy)
	
	var cmd = enemy
	var chance = randf()
	if chance <= chance_attack or true:
		var halfway = pos_end - pos_start
		var alpha = 0.2 + 0.6 * randf() # between 20% and 80% of the way
		halfway = pos_start + (halfway.normalized() * halfway.length() * alpha)
		cmd.queue_moveto(halfway)
		cmd.queue_halt(0.5)
		cmd.queue_fire("player")
	cmd.queue_moveto(pos_end)
	cmd.queue_destruct()
	
	_timer = spawn_duration_range.x + ((spawn_duration_range.y - spawn_duration_range.x) * randf())
