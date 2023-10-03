extends GComp

# If entity has health component, this tag means it'll die on hp = 0

func compinit():
	compname = "killable"
	# expected enttype for error checking (optional)
	enttype = ""

