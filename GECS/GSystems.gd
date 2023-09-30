extends Node
class_name GSystems

# IF THIS IS AN INSTANCE, DETACH ME AND CREATE A NEW GDSCRIPT FOR SYSTEMS THAT INHERITS GSystems

# Systems runs all systems available in this systems instance
# Systems are parent node for components instances
# It's meant to be used as a systems base-class
# Example: mainsystems.tscn scene which attaches to mainsystems.gd that extends GSystems
# mainsystems can then be instanced per entity, so each entity has a script with all systems in mainsystems
# This is a sort of distributed systems/components peggy-backing on Godot's nodes

# Reponsibile for:
# - initializing components and collecting their names
# - tracking components added to it by name
# - react to and update internal data when needed if a component change is detected (add new comp or remove comp)
# - determine which registered systems should run on this entity based on comps list

# Future work:
# Would be great if I can annotate systems with their compslist like this: @gsystem("vehicle", "vehicle_shake")

# system_name = [compslist]
var gsystems:Dictionary = {}
# system names that are active and should be called cause their compslist are all available
var active_gsystems:Array[String] = []
# list of comps names found
var compslist:Array[String] = []

func _ready():
	# Make sure there's a comps node up there
	var ent = get_parent()
	assert(ent != get_tree().root)

	scan_comps()

	if len(compslist) == 0:
		push_warning("GSystems " + name + " didn't find any components in comps, so it'll do nothing: " + ent.name)
	else:
		sysinit()

func scan_comps():
	# Sniff all defined components, complain about non-components in children
	var ent = get_parent()
	compslist = []
	var report:String = ""
	var bad_children:int = 0
	for c in get_children():
		if c is GComp:
			if c.compname == "unnamed":
				c.compinit()
			if c.compname == "unnamed":
				assert(false, name + "(GSystems): wow this child " + c.name + " is unnamed, what's wrong with you? func compname(): compname=\"snowflake\": " + ent.name)
				bad_children += 1
			elif c.compname in compslist:
				assert(false, name + "(GSystems): child " + c.compname + " uses a name that of another child I have, lazy copy-paste? tsk tsk: " + ent.name)
				bad_children += 1
			else:
				if c.enttype != "":
					assert(ent.is_class(c.enttype), name + "(GSystems): entity `" + str(ent) + "` is not valid for `" + c.compname + "` component: " + ent.name + " (expected type `" + c.enttype + "`)")
				compslist.append(c.compname)
		else:
			assert(false, name + "(GSystems): wow child " + c.name + " is not GComp, I need to speak to your manager, extends GComp pls: " + ent.name)
			bad_children += 1
		
	if bad_children > 0:
		push_error(name + "(GSystems): " + str(bad_children) + " <- this many children are bad, such parenting: " + ent.name)

# Where define_system() should be called by systems
func sysinit():
	pass

# Define a system as: array of component names (compnames) and system function name (sysname)
func define_system(compnames, sysname):
	var ent = get_parent()
	if sysname in gsystems:
		assert(false,  name + "(GSystems): define_system() given a sysname `" + sysname + "` that's already defined, what's r we doin here? " + ent.name)
	elif len(compnames) == 0:
		assert(false,  name + "(GSystems): define_system() for `" + sysname + "` given compslist empty.. hollow.. void.." + ent.name)
	else:
		gsystems[sysname] = compnames
		# Simply iterate on all compslist, findout if we have them all from comps, add system to active list if we do
		var include = true
		for c in compnames:
			if not compslist.has(c):
				include = false
				break
		if include:
			active_gsystems.append(sysname)

func _physics_process(delta):
	var ent = get_parent()
	for asys in active_gsystems:
		call(asys, delta, ent)

func get_comp(compname:String):
	return get_node(compname)

# Use this from system funcs instead of get_node(), it corrects relative paths to be one up instead of two up
func get_comp_node(path:NodePath):
	assert(not path.is_empty())
	if not path.is_absolute() and path.get_name_count() > 2:
		# "../../*" to "../*"
		var new_path = path.get_concatenated_names()
		assert(new_path.begins_with("../../"), "get_comp_node() given incorrect relative nodepath: " + str(path))
		return get_node(new_path.substr(3) + path.get_concatenated_subnames())
