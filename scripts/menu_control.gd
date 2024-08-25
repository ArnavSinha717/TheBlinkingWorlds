extends Control

func _ready() -> void:
	$MarginContainer/VBoxContainer/PlayButton.grab_focus()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/test_level.tscn")

func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_tutorial.tscn")

func _on_options_button_pressed() -> void:
	print("Option button pressed")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
