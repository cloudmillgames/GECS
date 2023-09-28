extends GComp

# Defines an AABB that this node is bound by (can't leave)
@export var bounds:AABB = AABB(Vector3(-10, -10, -10), Vector3(20, 20, 20))

func compinit():
	compname = "Movebounds".to_lower()
	# expected enttype for error checking (optional)
	enttype = "Node3D"

