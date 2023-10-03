extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.animation_finished.connect(on_anim_finished)

func on_anim_finished(animname):
	queue_free()
