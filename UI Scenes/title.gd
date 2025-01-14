extends Control

func _on_play_button_button_up():
	$AnimationPlayer.play("intro")

func _on_okay_button_up():
	get_tree().change_scene_to_file("res://UI Scenes/main.tscn")
	
