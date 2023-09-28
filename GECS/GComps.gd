extends Node
class_name GComps

# Parent for components attached to this entity
# Responsible for:

# - initializing components
# - tracking components added to it by name
# - dispatching a signal when a component change is detected

var compslist:Array[String] = []

# Will be called by GSystems and in response to components modification events
func scan_comps():
	# Sniff all defined components, complain about non-components in children
	compslist = []
	var report:String = ""
	var bad_children:int = 0
	for c in get_children():
		if c is GComp:
			if c.compname == "unnamed":
				c.compinit()
			if c.compname == "unnamed":
				push_error("GComps: wow this child " + c.name + " is unnamed, what's wrong with you? func compname(): compname=\"snowflake\"")
				bad_children += 1
			elif c.compname in compslist:
				push_error("GComps: child " + c.compname + " uses a name that of another child I have, lazy copy-paste? tsk tsk")
				bad_children += 1
			else:
				compslist.append(c.compname)
		else:
			push_error("GComps: wow child " + c.name + " is not GComp, I need to speak to your manager, extends GComp pls")
			bad_children += 1
	if bad_children > 0:
		push_error("GComps: " + str(bad_children) + " <- this many children are bad, such parenting")
