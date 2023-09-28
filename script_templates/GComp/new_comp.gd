# meta-name: New Comp
# meta-description: Use me if you're making a new GECS component
extends _BASE_

func compinit():
	compname = "_CLASS_".to_lower()
	# expected enttype for error checking (optional)
	enttype = ""
