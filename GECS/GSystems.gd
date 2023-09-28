extends Node
class_name GSystems

# IF THIS IS AN INSTANCE, DETACH ME AND CREATE A NEW GDSCRIPT FOR SYSTEMS THAT INHERITS GSystems

# Systems runs all systems available in this systems instance
# It's meant to be used as a systems base-class
# Example: mainsystems.tscn scene which attaches to mainsystems.gd that extends GSystems
# mainsystems can then be instanced per entity, so each entity has a script with all systems in mainsystems
# This is a sort of distributed systems/components peggy-backing on Godot's nodes

# Reponsibile for:
# - collecting components names attached to this entity
# - determine which registered systems should run on this entity
# - updating components names attached to this entity and rebuild systems list

# Future work:
# Would be great if I can annotate systems with their compslist like this: @gsystem("vehicle", "vehicle_shake")

# Systemname = [compslist]
var gsystems:Dictionary = {}
# [systemnames] that are active and should be called cause their compslist are all available
var active_gsystems:Array[String] = []

func _ready():
	# Make sure there's a comps node up there
	var comps = get_parent().get_node("../comps")
	if not comps:
		push_error("GSystems: you have a gsystems " + self.name + " that couldn't find its comps node, create that comps node ok")
	comps.scan_comps()
	if len(comps.compslist) == 0:
		print("GSystems " + self.name + " didn't find any components in comps, so it'll do nothing")
	else:
		sysinit()

# Where define_system() should be called by systems
func sysinit():
	pass

func define_system(compslist, sysname):
	var comps = get_parent().get_node("../comps")
	if sysname in gsystems:
		push_error("GSystems: define_system() given a sysname `" + sysname + "` that's already defined, what's r we doin here?")
	elif len(compslist) == 0:
		push_error("GSystems: define_system() for `" + sysname + "` given compslist empty.. hollow.. void..")
	else:
		gsystems[sysname] = compslist
		# Simply iterate on all compslist, findout if we have them all from comps, add system to active list if we do
		var include = true
		for c in compslist:
			if not comps.compslist.has(c):
				include = false
				break
		if include:
			active_gsystems.append(sysname)

func _physics_process(delta):
	var ent = get_parent().get_parent()
	for asys in active_gsystems:
		call(asys, delta, ent)
