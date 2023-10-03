extends Node3D

func _ready():
	$AnimationPlayer.animation_finished.connect(on_anim_finish)
	$AnimationPlayer.play("impact")

func on_anim_finish(animname:String):
	queue_free()
