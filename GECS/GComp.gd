extends Node
class_name GComp

# IF THIS IS AN INSTANCE, DETACH ME AND ATTACH A NEW GDSCRIPT THAT INHERITS GComp

# This is a single component which is nothing more than a data container
# Can export properties to allow them to be modifiable in editor

var compname:String = "unnamed"
# if set, GComps scan checks entity node type to make sure it's what's expected
var enttype:String = ""

func _ready():
	# this is a duplicate call, GComps calls compinit() if name is unnamed
	if compname == "unnamed":
		compinit()

func compinit():
	pass
