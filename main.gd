extends Control


func _on_gecs_btn_pressed():
	get_tree().change_scene_to_file("res://start.tscn")


func _on_godway_btn_pressed():
	get_tree().change_scene_to_file("res://godway/godway.tscn")
