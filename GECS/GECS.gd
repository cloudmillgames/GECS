extends Node

# Global GECS framework

const GPREFIX = "G_"
# all GECS entities are added to this group
const GENTGROUP = "_Gent"

# TODO: implement multi-GSystems support: gsystem[gsystems_name] = {system_name: [compslist], ..}

# This is used to enforce only one GSystems policy for now
var gsysname:String = ""

# List of defined systems and their corresponding compslist
# gsystems[sysname] = [compslist]
var gsystems:Dictionary = {}

# Singleton systems to be called
var single_systems:Array[String] = []

# GSystems instances that are alive
var instances:Array[GSystems] = []

func _ready():
	print("GECS: start")

# these will be affected when we convert to multi-GSystems
func get_defined_systems():
	return gsystems
func get_system_comps(compname):
	return gsystems[compname]

# call from _ready by every GSystems for every entity, for now only 1 GSystems instance is supported
func register_gsystems(gsys:GSystems):
	if gsysname == "":
		gsysname = gsys.name
		print("GECS: register GSystems " + gsys.name)
		gsys.sysinit()
	assert(gsysname == gsys.name, "GECS: only one GSystems is supported for now, " + gsysname + " is already registered so cannot register " + gsys.name + " as well")
	instances.append(gsys)

# call on tree_exiting signal in GSystems to notify it's no longer alive
func deregister_gsystems(gsys:GSystems):
	instances.erase(gsys)

# Define a system as: array of component names (compnames) and system function name (sysname)
func define_system(gsys:GSystems, compnames:Array[String], sysname:String):
	var ent = gsys.get_parent()
	
	if sysname in gsystems:
		assert(false,  name + "(GSystems): define_system() given a sysname `" + sysname + "` that's already defined, what's r we doin here? " + ent.name)
	elif len(compnames) == 0:
		assert(false,  name + "(GSystems): define_system() for `" + sysname + "` given compslist empty.. hollow.. void.." + ent.name)
	else:
		gsystems[sysname] = compnames

func define_singleton_system(sysname:String):
	single_systems.append(sysname)

func _physics_process(delta):
	# Clean any dead instances
	var invalids:Array[GSystems] = []
	# Call singleton systems using first valid instance we find
	var first_valid:bool = true
	for i in instances:
		if is_instance_valid(i):
			if first_valid:
				for s in single_systems:
					i.call(s, delta)
				first_valid = false
		else:
			invalids.append(i)
	for i in invalids:
		instances.erase(i)

func change_scene_to(scene_file:String):
	get_tree().change_scene_to_file(scene_file)
	clear_all()

# Spawns a Node3D entity in root then adds given component to it
# - gsystems_path is the path to tscn of the gsystems to use, this is required to avoid cyclic dependency
# - comp is the instantiated GComp
# Retrusn the entity that was instantiated
func spawn_ent_comp(gsystems_path:String, comp:GComp)->Node3D:
	var ent = Node3D.new()
	var gsys_ps:PackedScene = load(gsystems_path)
	var gsys = gsys_ps.instantiate()
	gsys.add_child(comp)
	ent.add_child(gsys)
	get_tree().root.add_child(ent)
	return ent

# Call when scene is unloaded and you don't want any data left over
func clear_all():
	gsysname = ""
	gsystems = {}
	single_systems = []
	instances = []
