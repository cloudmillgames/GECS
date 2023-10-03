# GECS Framework

Weird, crude, and properly terrible Godot ECS framework.

## Start a new project

- You need to copy the GECS folder and the script_templates folder to your project.

Make 1 scene:
	
- a scene with a script that extends GSystems, or inherit GSystems.tscn and detach/attach a new script for systems

Example: MainSystems node with "mainsystems.gd" extends "GSystems" saved as "mainsystems.tscn"

- mainsystems.tscn is a manager of its components children, thats where you add components
- mainsystems.tscn/gd is where all the main systems will be written and registered (yes one gd file for all!) but you can make other *systems.tscn for other things (UI? or different gamemode? etc)

Now whenever you make a Node that you want to use GECS in:
	
	- add instance of "mainsystems.tscn" to the scene

You create components by creating a new Node that extends GComp (`extends GComp`), you may use `New Comp` template defined in script_templates.

Save the component scene and its script using the component name. Example: `components/vehicle.tscn/gd`

To initialize name you must use `func compinit()` to set string: compname, this must be done otherwise component won't register and GECS will complain. No need to call super compinit()

You may now instance this new component inside your mainsystems node in any entity scene.

You create systems in mainsystems.gd by:
	- registering the system and its compslist in: `func sysinit()` using: `define_system({"comp1", "comp2", ..}, "my_whatever_system")`
	- writing the systems func using this signature: `func my_whatever_system(tdelta, ent)` wherever you want in the file

Voila! mainsystems should now run on their respective components. You get the entity (Node) passed to system to do what you want with.

Scene structure should look something like this:

	- Player (player.tscn)
		- collider etc.
		- model etc.
		- mainsystems (GSystems)
			- vehicle (GComp)
			- playercontrol (GComp)
			- directctrl (GComp)

Suggested file structure should reflect ECS:

	- components
		- mycompname.gd
		- mycompname.tscn
	- entities
		- player.tscn
		- enemy.tscn
	- systems
		- mainsystems.gd
		- mainsystems.tscn

## How about Godot events like collision?

You setup signal listener inside components by overriding and implementing `func post_compinit(ent)`, given entity scene node you can now setup signal listeners to call a local function in component.

Example for collision:

```py
# Make sure that the parent PhysicsBody3D collider has `Contact Monitoring` ON and `Max Contacts` >= 1, otherwise collision won't work
var collision:bool = false
var with:Node3D = null

func post_compinit(ent):
	ent.body_entered.connect(on_body_entered)

# Note that this doesn't clear the collision flag but leaves that to whoever processes the event (which not ideal)
func on_body_entered(body:Node):
	collision = true
	with = body
```


## Inside Systems

- Use: `var compname = get_comp("compname")` to retreive components, ent is the entity scene (which is mainsystems.get_parent())
- Use: `var node = get_comp_node("some_nodepath")` to retrieve node from nodepath defined inside a component (this changes "../../" paths to "../")

## Hacky McHackson

It might be faster to implement single component systems directly inside the component's `_physics_update`. I don't see why not lol

Example: vehicle_shake component needs vehicle, faster to just write that code inside vehicle component's _physics_update. Code should be SAME (TM)

## Dreams of Terrible Code

### Collection Time

Peggy-backing on Godot's groups should be a straightforward solution, basically each component adds its entity node (parent) to a group named `"G_"+compname`, now I can retrieve all entities that have `compname` by calling `SceneTree.get_nodes_in_group()` and then doing a union between all the compnames arrays to arrive at final collection. This sounds slow but it's done mostly in C++ and honestly from LovECS experience I mostly collect by single compname and only grab the first entity, lots of opportunities for optimization here

Also can use cached filters, where the collection happens only once per frame. (flecs uses that for its collection)

### But is it flexible?

- Dynamic systems are NO.
- Dynamic components are YES, but I haven't written the rescan components code yet which should live in GSystems.
- Spawn entities? I don't see why not. Scene + comps + systems = <BAM>, all easy to wrap in a single func call from GSystems

### Musings of a retired F1 driver

Can it fast?

Yes it may be can. Should be straight forward to throw that bad boy into a C++ GDExtension and have an optimization-trip there.

### Troubleshooting

Error: get_node("...") in systems gdscript returning a null object? -> use get_comp_node() instead
