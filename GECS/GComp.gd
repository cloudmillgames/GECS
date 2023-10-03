extends Node
class_name GComp

# IF THIS IS AN INSTANCE, DETACH ME AND ATTACH A NEW GDSCRIPT THAT INHERITS GComp

# This is a single component which is nothing more than a data container
# Can export properties to allow them to be modifiable in editor

var compname:String = "unnamed"
# if set, GComps scan checks entity node type to make sure it's what's expected
var enttype:String = ""

# duplicate def from GSystems, maybe should be in a GECS autoload?
const ENTGROUP = "_Gent"

func _ready():
	var ent = get_parent().get_ent()
	# this is a duplicate check, GComps calls compinit() if name is unnamed but allows adding pre-instantiated components
	if compname == "unnamed":
		compinit()
		assert(compname != "unnamed", "This component didn't set its compname: " + name)
		if enttype != "":
			assert(ent.is_class(enttype), name + "(GComp): entity `" + str(ent) + "` is not valid for `" + compname + "` component: " + ent.name + " (expected type `" + enttype + "`)")
	post_compinit(ent)

func compinit():
	pass

func post_compinit(ent):
	pass

# Returns true if given node is an entity
func is_ent(node)->bool:
	return node.is_in_group(ENTGROUP)

func get_ent()->Node:
	return get_parent().get_ent()
