extends Control

func _on_easy_difficulty_button_pressed() -> void:
	pass # Replace with function body.

func _on_medium_difficulty_button_pressed() -> void:
	pass # Replace with function body.

func _on_hard_difficulty_button_pressed() -> void:
	pass # Replace with function body.


func _on_small_map_size_button_pressed() -> void:
	pass # Replace with function body.

func _on_medium_map_size_button_pressed() -> void:
	pass # Replace with function body.

func _on_large_map_size_button_pressed() -> void:
	pass # Replace with function body.


func _on_start_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://loading_screen.tscn")

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
