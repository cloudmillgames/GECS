extends GComp

# Calls a function after a particular delay
var delay:float = 1.0
var object:Object
var func_name:String
var func_arg

func compinit():
	compname = "delayedfunc"
	# expected enttype for error checking (optional)
	enttype = ""

func post_compinit(ent):
	assert(object and func_name != "")

func _physics_process(delta):
	if delay > 0:
		delay = max(delay - delta, 0)
	else:
		if func_arg:
			object.call(func_name, func_arg)
		else:
			object.call(func_name)
