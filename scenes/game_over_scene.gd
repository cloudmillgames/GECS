extends Control

var PSGame:PackedScene = preload("res://start.tscn")

func _ready():
	%ScoreLbl.text = "SCORE " + str(GameSession.score)

func _on_restart_btn_pressed():
	get_tree().change_scene_to_packed(PSGame)


func _on_exit_btn_pressed():
	get_tree().quit()
