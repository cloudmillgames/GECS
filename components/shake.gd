extends GComp

# Shakes whatever you give it, does not twerk
@export var what:NodePath
@export var strength:float = 0.05
var origin:Transform3D

func compinit():
	compname = "shake"
	if what:
		origin = get_node(what).transform
