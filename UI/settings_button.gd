extends Button

func _ready():
	pressed.connect(_on_button_pressed)
	tooltip_text = "Settings"
	get_node("VBoxContainer/ReturnToGame").visible = false
	get_node("VBoxContainer/QuitToMenu").visible = false
	get_node("VBoxContainer/QuitGame").visible = false

func _on_button_pressed():
	get_node("VBoxContainer/ReturnToGame").visible = !get_node("VBoxContainer/ReturnToGame").visible
	get_node("VBoxContainer/QuitToMenu").visible = !get_node("VBoxContainer/QuitToMenu").visible
	get_node("VBoxContainer/QuitGame").visible = !get_node("VBoxContainer/QuitGame").visible

func _on_return_to_game_pressed() -> void:
	get_node("VBoxContainer/ReturnToGame").visible = false
	get_node("VBoxContainer/QuitToMenu").visible = false
	get_node("VBoxContainer/QuitGame").visible = false

func _on_quit_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_quit_game_pressed() -> void:
	get_tree().quit()
