extends GComp

# Takes a property from GameSession, and plugs it into a label as text

@export var dest_label:Label
@export var property:String
@export var prefix:String = ""

func compinit():
	compname = "replicatestring"
	enttype  = ""

func _physics_process(delta):
	dest_label.text = prefix + str(GameSession.get(property))
