# GECS Framework

## Start a new project

Make 2 scenes:
	
	- "comps" extends "GComps"
	- "systems" extends "GSystems"

Detach and re-attach each to your own comps and systems scripts (example: comps.gd, mainsystems.gd)

- comps.gd is a manager of its components children, thats where you add components
- mainsystems.gd is where all the main systems will be written and registered (yes one gd file for all!) but you can make other *systems.gd for other things (UI? or different gamemode?)

Now whenever you make a Node that you want to use GECS in:
	
	- add instance of "comps.tscn" to the scene "comps"
	- add instance of "systems.tscn" to the scene "systems"

You create components by creating a new Node inside "comps" and extending GComp.
Then you just define properties there as usual with default values and optional exports.

To initialize name you must use `func ginit()` to set string: compname, this must be done otherwise component won't register and GECS will complain. I don't trust exports as they do get lost sometimes incrashes or engine updates, so it has to be a hard function.

You create systems by:
	- registering the system and its compslist in: `func ginit()` using: `DefineSystem({"comp1", "comp2", ..}, "my_whatever_system")`
	- writing the systems func using this signature: `func my_whatever_system(ent)` wherever you want in the file

Voila! systems should now run on their respective components. You get the entity (Node) passed to system to do what you want with.
