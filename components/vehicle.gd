extends GComp

@export var speed:float = 5.0
@export var angular_speed:float = 2.5
@export var hp:int = 100
@export var tint_color:Color = Color.WHITE
@export var apply_color_to:NodePath = ""

func compinit():
	compname = "Vehicle".to_lower()
	enttype = "PhysicsBody3D"
