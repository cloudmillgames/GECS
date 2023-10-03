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

# which systems are active (this entity has required comps signature)
var active_gsystems:Array[String] = []
# list of comps names found
var compslist:Array[String] = []

func _ready():
	# Make sure there's a comps node up there
	var ent = get_parent()
	assert(ent != get_tree().root)
	
	ent.add_to_group(GECS.GENTGROUP)
	scan_comps()
	
	GECS.register_gsystems(self)
	if len(compslist) == 0:
		print("GSystems " + name + " didn't find any components in comps, so it'll do nothing: " + ent.name)
	
	tree_exiting.connect(on_tree_exiting)
	if len(active_gsystems) == 0:
		refresh_active_systems()

func on_tree_exiting():
	GECS.deregister_gsystems(self)

func scan_comps():
	# Sniff all defined components, complain about non-components in children
	var ent = get_parent()
	compslist = []
	var report:String = ""
	var bad_children:int = 0
	for c in get_children():
		if c is GComp:
			if c.compname == "unnamed":
				c.compinit(ent)
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
			if c.get_child_count(true) == 0 and not c.name.begins_with("Node"):
				push_warning(name + "(GSystems): child " + c.name + " is a named empty Node, it will be considered a tag.")
				compslist.append(c.name)
			else:
				assert(false, name + "(GSystems): wow child " + c.name + " is not GComp, I need to speak to your manager, extends GComp pls: " + ent.name)
				bad_children += 1
		
	if bad_children > 0:
		push_error(name + "(GSystems): " + str(bad_children) + " <- this many children are bad, such parenting: " + ent.name)
	
	# Tagging (group names)
	for n in compslist:
		ent.add_to_group(GECS.GPREFIX + n)

func refresh_active_systems():
	active_gsystems = []
	for sysname in GECS.get_defined_systems():
		if is_system_active(sysname):
			active_gsystems.append(sysname)

func is_system_active(sysname:String):
	var compnames = GECS.get_system_comps(sysname)
	var active = true
	for c in compnames:
		if not compslist.has(c):
			active = false
			break
	return active

# Where to put the define_system() calls. This func is called by GECS
func sysinit():
	pass

# Define a system as: array of component names (compnames) and system function name (sysname)
func define_system(compnames:Array[String], sysname:String):
	GECS.define_system(self, compnames, sysname)
	var o = "System `" + sysname  + "` defined: "
	for n in compnames:
		o += str(n) + " "
	if is_system_active(sysname):
		active_gsystems.append(sysname)
		o += "(ACTIVE)"
	else:
		o += "(INACTIVE)"
	print(o)

func define_singleton_system(sysname:String):
	GECS.define_singleton_system(sysname)

func _physics_process(delta):
	var ent = get_parent()
	for asys in active_gsystems:
		call(asys, delta, ent)

# components don't need to know which one is entity scene node
func get_ent():
	return get_parent()

# Gets component in this entity
func get_comp(compname:String):
	return get_node(compname)

# Gets component in given entity from the same systems scene (by name)
func ent_get_comp(ent:Node, compname:String)->Node:
	assert(ent_has_comp(ent, compname), "ent_get_comp (GSystems): entity `" + ent.name + "` doesn't have component `" + compname + "`, typo-o-maybe?")
	return ent.get_node(NodePath(name)).get_node(compname)

func ent_has_comp(ent:Node, compname:String)->bool:
	return ent.get_node(NodePath(name)).has_comp(compname)

func has_comp(compname:String):
	return compname in compslist

# Tag comps are supported, but remember we have to refresh active systems after
func add_tag_comp(compname:String):
	if not compslist.has(compname):
		compslist.append(compname)
		var ent = get_parent()
		ent.add_to_group(GECS.GPREFIX + compname)
		refresh_active_systems()

# Instantiates and adds a comp, if replace is true and component is already in entity, replaces existing one with new one
func add_comp(comp_scene:PackedScene, replace:bool = false):
	var comp = comp_scene.instantiate()
	assert(not comp.is_class("GComp"), "Comp has to be GComp to be added here")
	var refresh:bool = false
	if replace and compslist.has(comp.name):
		remove_child(get_comp(comp.name))
		compslist.erase(comp.name)
		refresh = true
	if not compslist.has(comp.name):
		compslist.append(comp.name)
		add_child(comp)
		var ent = get_parent()
		ent.add_to_group(GECS.GPREFIX + comp.name)
		refresh = true
	if refresh:
		refresh_active_systems()
	return comp

func remove_comp(compname:String):
	if compname in compslist:
		compslist.erase(compname)
		refresh_active_systems()
		var ent = get_parent()
		ent.remove_from_group(GECS.GPREFIX + compname)

# Use this from system funcs instead of get_node(), it corrects relative paths to be one up instead of two up
func get_comp_node(path:NodePath):
	assert(not path.is_empty(), "Given path is empty, did you forget to initialize it? " + str(name))
	if not path.is_absolute() and path.get_name_count() > 2:
		# "../../*" to "../*"
		var new_path = path.get_concatenated_names()
		assert(new_path.begins_with("../../"), "get_comp_node() given incorrect relative nodepath: " + str(path))
		return get_node(new_path.substr(3) + path.get_concatenated_subnames())

# Destroys entity scene effectively removing self
func destruct():
	get_parent().queue_free()

# Destroys an entity scene
func destroy(ent:Node):
	ent.queue_free()

func get_first_tagged_ent(compname:String):
	return get_tree().get_first_node_in_group(GECS.GPREFIX + compname)
