extends GComp

# Set Z to forward(-1) or backward (1), and X to right (+1) or left (-1)
var movement:Vector3 = Vector3.ZERO
# set to try to fire, will be reset to false when its processed
var trigger:bool = false

func compinit():
	compname = "Directctrl".to_lower()
