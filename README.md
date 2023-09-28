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
	- writing the systems func using this signature: `func my_whatever_system(tdelta, ent)` wherever you want in the file

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

## Inside System

- Relative path matches that of components ("../.." to entity node) so a NodePath inside component works in systems
- Use: `var compname = ent.get_node("comps/compname")` to retreive components, ent is the entity node (parent of scene)

## Hacky McHackson

It might be faster to implement single component systems directly inside the component's `_physics_update`. I don't see why not lol

Example: vehicle_shake component needs vehicle, faster to just write that code inside vehicle component's _physics_update. Code should be SAME (TM)

## Dreams of Terrible Code

### Collection Time

Collecting by component is impossible from within current structure as each entity is completely isolated from the rest of the game. However peggy-backing on Godot's groups should be a straightforward shortcut, basically each component adds its entity node (parent) to a group named `"G_"+compname`, now I can retrieve all entities that have `compname` by calling `SceneTree.get_nodes_in_group()` and then doing a union between all the compnames arrays to arrive at final collection. This sounds slow but it's done mostly in C++ and honestly from LovECS experience I mostly collect by single compname and only grab the first entity, lots of opportunities for optimization here

Also can use cached filters, where the collection happens only once per frame. (I think flecs uses that for its collection)

### But is it flexible?

- Dynamic systems are NO.
- Dynamic components are YES, but I haven't written the rescan components code yet which should live in GComps.
- Spawn entities? I don't see why not. Scene + comps + systems = <BAM>, all easy to wrap in a single func call from GSystems

### Musings of a retired F1 driver

Can it fast?

Yes it may be can. It's so far completely third-party without any need for Godot modifications. I don't see why I need any Engine changes, I can just ship that bad boy to C++ GDExtension and have an optimization-trip there.
