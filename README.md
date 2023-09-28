# GECS Framework

Weird, crude, and properly terrible Godot ECS framework.

## Start a new project

- You need to copy the GECS folder and the script_templates folder to your project.
- You may need to define `GECS/GECS.gd` as an autoload class, however I haven't used it as of writing this so when I use it

Make 2 scenes:
	
	- "comps" extends "GComps"
	- "mainsystems" extends "GSystems"

Detach (and re-attach for your GSystems-inherited script) (example: comps.gd, mainsystems.gd)

- comps.tscn is a manager of its components children, thats where you add components
- mainsystems.tscn/gd is where all the main systems will be written and registered (yes one gd file for all!) but you can make other *systems.gd for other things (UI? or different gamemode?)

Now whenever you make a Node that you want to use GECS in:
	
	- add instance of "comps.tscn" to the scene "comps"
	- create new node "systems" and add instance of "mainsystems.tscn" to scene "systems"

You create components by creating a new Node as a new scene inside a folder like "components" that extends GComp: `extends GComp` (use `New Comp` template defined in script_templates)
To initialize name you must use `func compinit()` to set string: compname, this must be done otherwise component won't register and GECS will complain. I don't trust exports as they do get lost sometimes incrashes or engine updates, so it has to be a hard function. Also no need to call super compinit()
You may then instance this new component inside your comps node in entity.

You create systems by:
	- registering the system and its compslist in: `func sysinit()` using: `define_system({"comp1", "comp2", ..}, "my_whatever_system")`
	- writing the systems func using this signature: `func my_whatever_system(ent)` wherever you want in the file

Voila! systems should now run on their respective components. You get the entity (Node) passed to system to do what you want with.

Scene structure should be:
	- components
		- mycompname.gd
		- mycompname.tscn
	- entities
		- player.tscn
		- enemy.tscn
	- systems (just a node)
		- mainsystems.gd
		- mainsystems.tscn
	systems.tscn
	comps.tscn

The reason why `mainsystems.tscn` must be inside a `systems` node has to do with relative NodePath. Given a component with a NodePath to something that's under the entity node, its NodePath will start with "../../" which is two levels up to reach parent context. When a system reads this NodePath it reads the "../../" with it and unless it's 2 levels down inside entity node, it won't find the referenced object.
A bit hacky, but go back to the description of GECS ;)

