extends Control


func _on_return_to_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
