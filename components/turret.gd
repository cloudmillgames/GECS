extends GComp

@export var fire_marker:NodePath	# Marker3D
@export var cooldown:float = 0.5
@export var projectile:PackedScene
@export var speed:float = 100.0
@export var sound:AudioStream
var _timer:float = 0.0

func compinit():
	compname = "turret"
	# expected enttype for error checking (optional)
	enttype = "PhysicsBody3D"

# target is a Node3D target entity to fire at
func fire(target:Node3D = null):
	var ecs = get_parent()
	if ecs.has_comp("audio") and sound:
		var audio = ecs.get_comp("audio")
		var stplayer = ecs.get_comp_node(audio.stream_player) as AudioStreamPlayer3D
		if stplayer:
			stplayer.stream = sound
			stplayer.play()
	var pr:Node3D = projectile.instantiate() as Node3D
	var fm:Marker3D = get_node(fire_marker)
	var dir:Vector3 = Vector3.ZERO
	if target:
		dir = (target.global_position - fm.global_position).normalized()
	if dir == Vector3.ZERO:
		pr.transform = fm.global_transform
		pr.linear_velocity = -speed * pr.transform.basis.z
	else:
		pr.position = fm.global_position
		pr.linear_velocity = speed * dir
	get_tree().root.add_child(pr)
	_timer = cooldown
