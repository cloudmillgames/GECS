extends GComp

# Detects collision between entity PhysicsBody3D and another body, only reports collision with entity scene nodes
# Processor of this event should reset collided to false
var collided:bool = false
var with:Node3D = null

func compinit():
	compname = "collisionevent"
	enttype = "PhysicsBody3D"

func post_compinit(ent:PhysicsBody3D):
	ent.body_entered.connect(on_body_entered)

func _physics_process(delta):
	# Does _physics_process run after or before collision event signals are dispatched? don't know
	if collided:
		#if not is_instance_valid(with):
		collided = false
		with = null

func on_body_entered(body:Node):
	# body is probably an entity scene node
	# TODO: destroy self if projectile? or maybe another component does that
	# TODO: play a sound of impact, or maybe another comp does that
	# TODO: damage other entity (if its an entity?) or maybe another comp does that
	if is_instance_valid(body) and is_ent(body):
		collided = true
		with = body
