# GECS

Godot ECS in the vain of LovECS.

## Inner Implementation

For now the easiest I can do is using groups and `SceneTree.get_nodes_in_group()`

The call in C++ builds a new list of Node pointers everytime it's called.

Some form of caching can be employed here: Systems register their buckets, GECS fetches and categorizes Node references
to match buckets and then call systems on each list of entities.

Not necessary to cache at this point

GECS should probably be a global api


## Implementation

Nodes are treated as entities registered by their id. Node.get_instance_id() returns a unique int id, @GlobalScope.instance_from_id() can retrieve instance.


If and only if I need to refer to entities by id: inside GComponent id is passed to GECS and initialized with the component.

From this perspective, Godot Nodes act as a prefab as they specify which Components it has (at least to start with).

* Should GECS be able to spawn a new Node using a components list? I don't see why it should..
* Should GECS be able to add/remove components? this is necessary as it's a direct pattern in practical ECS


GSystem registers its interested buckets, it's not gonna be run by GECS otherwise.

Callback: `GSystem.init()`, use to register bucket `register({"pos", "velocity"})` and phase `phase(GECS_UPDATE)` 

Phases: GECS_PREUPDATE, GECS_UPDATE, GECS_POSTUPDATE
All phases are: _physics_update.

Callback: `Gsystem.run(ents)` will be called by GECS to run the system.

GComponent is meant to be a data class.

Callback: `GComponent.init()`, use to register group name `register("pos")`, otherwise component is not added.

Components are added manually to Godot Nodes. Set name and properties in Node as normal.

GECS runs all populated systems once a frame. There is no threading as of now to allow direct manipulation of Godot objs

## Design Challenges

* Collecting entities by comps: direct collection is probably gonna be slow, remember this is pythonic. However registering a "filter" and then collecting those entities can be sped up by caching. this is EXACTLY what flecs uses.
* For extra speeding up, a special caching pass grabs the first entity of each filter so it can return it immediately when calling: `get_first_entity()`


## Classes

* GECS global object	
* GSystem
* GComponent

## User Story

Let's take a simple vehicle.

You create Node3D and initialize it with model, physics, and any other components it needs (particle effects, sound etc)

You attach a component called: GVehicle to mark this Node as a vehicle, a GVehicleSystem will execute all that's needed for a vehicle
You attach a component called: GDestructible to mark this Node as destructible, now it has health and can be damaged and will explode and delete itself when dead
You attach a component called: GPlayerControl to mark this Node as player controllabel, now it can be controlled by player inputs implemented via systems

From this example,  what benefit do I get from implementing this as an ECS and not just a hybrid Components system?

I say implement it using hybrid Components as that feels less overheady and should give you the same abilities. If you hit limitations and complications due to treating components and systems as a single package, then maybe start thinking about mixins.
