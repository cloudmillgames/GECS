extends GComp

@export var stream_player:NodePath
@export var sounds:Array[AudioStream]

func compinit():
	compname = "audio"
	# expected enttype for error checking (optional)
	enttype = ""

