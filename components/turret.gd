extends GComp

@export var fire_marker:NodePath	# Marker3D
@export var cooldown:float = 0.5
@export var projectile:PackedScene
@export var speed:float = 100.0
var _timer:float = 0.0

func compinit():
	compname = "turret"
	# expected enttype for error checking (optional)
	enttype = "PhysicsBody3D"
