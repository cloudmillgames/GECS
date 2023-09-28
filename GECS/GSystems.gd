extends Node
class_name GSystems

# Systems runs all systems available in this systems instance
# It's meant to be used as a systems base-class
# Example: mainsystems.tscn instance which attaches to mainsystems.gd that extends GSystems
# mainsystems can then be instanced per entity, so each entity has a script with all systems in mainsystems
# This is a sort of distributed systems/components peggy-backing on Godot's nodes

# Reponsibile for:
# - collecting components names attached to this entity
# - determine which registered systems should run on this entity
# - updating components names attached to this entity and rebuild systems list
