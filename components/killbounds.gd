extends GComp

# Kills entity if it left defined geometric boundary, center on origin, perhaps using AABB and has_point() is better?
# Defines max x, y, z
@export var max_corner:Vector3 = Vector3(100, 100, 100)
# Defines min x, y, z
@export var min_corner:Vector3 = Vector3(-100, -100, -100)

func compinit():
	compname = "killbounds"
	# expected enttype for error checking (optional)
	enttype = "Node3D"

