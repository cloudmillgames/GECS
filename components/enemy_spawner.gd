extends GComp

var enemy_scene:PackedScene = preload("res://entities/enemy.tscn")

# PathFollow3D to use for random spawn location
@export var spawn_follow_path:NodePath
# What's the percentage this enemy will attack player?
@export var chance_attack:float = 0.1
# What's the min and max time between spawns?
@export var spawn_duration_range:Vector2 = Vector2(0.5, 2.0)

# Time til next spawn
var _timer:float = 0.0

func compinit():
	compname = "enemy_spawner".to_lower()
	# expected enttype for error checking (optional)
	enttype = ""
