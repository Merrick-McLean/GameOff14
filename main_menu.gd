extends Control

func _on_play_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://GameDifficultySettingsPage.tscn")


func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
	
	
func _on_settings_button_pressed() -> void:
	pass 
