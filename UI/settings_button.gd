extends Button

func _ready():
	pressed.connect(_on_button_pressed)
	tooltip_text = "Settings"
	$ReturnToGame.visible = false
	$QuitToMenu.visible = false
	$QuitGame.visible = false

func _on_button_pressed():
	$ReturnToGame.visible = !$ReturnToGame.visible
	$QuitToMenu.visible = !$QuitToMenu.visible
	$QuitGame.visible = !$QuitGame.visible

func _on_return_to_game_pressed() -> void:
	$ReturnToGame.visible = false
	$QuitToMenu.visible = false
	$QuitGame.visible = false

func _on_quit_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_quit_game_pressed() -> void:
	get_tree().quit()
