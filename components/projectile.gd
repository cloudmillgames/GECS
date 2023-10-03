extends GComp

@export var damage:int = 35

func compinit():
	compname = "projectile"
	# expected enttype for error checking (optional)
	enttype = "PhysicsBody3D"
