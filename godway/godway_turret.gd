extends Node3D
class_name GodwayTurret

@export var cooldown:float = 0.5
@export var projectile:PackedScene
@export var speed:float = 100.0
@export var sound:AudioStream

var _timer:float = 0.0

# Set this to true to fire
var trigger:bool = false
var target:Node3D = null

func _physics_process(delta):
	if _timer > 0:
		_timer -= delta
		trigger = false
	elif trigger:
		fire(target)
		trigger = false
		_timer = cooldown

func fire(target:Node3D = null):
	var stplayer = $AudioStreamPlayer3D
	if stplayer:
		stplayer.stream = sound
		stplayer.play()
	var pr = projectile.instantiate()
	var fm = self
	var dir:Vector3 = Vector3.ZERO
	if is_instance_valid(target):
		dir = (target.global_position - fm.global_position).normalized()
	if dir == Vector3.ZERO:
		pr.transform = fm.global_transform
		pr.linear_velocity = -speed * pr.transform.basis.z
	else:
		pr.position = fm.global_position
		pr.linear_velocity = speed * dir
	get_tree().root.add_child(pr)
