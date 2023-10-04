extends CharacterBody3D
class_name GodwayVehicle

# Vehicle class provides movement facilities
# health and life management

@export var speed = 5.0
@export var angular_speed = 2.5
@export var bounds:AABB = AABB(Vector3(-10, -10, -10), Vector3(20, 20, 20))

var movement:Vector3 = Vector3.ZERO
var turn:float = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	if turn != 0:
		rotate_y(-turn * angular_speed * delta)
	
	var direction = (Transform3D.IDENTITY * movement.normalized())
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	velocity.y = 0
	move_and_slide()
