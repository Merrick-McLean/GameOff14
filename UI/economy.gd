extends Node

var cash

func _ready(): 
	var weather = get_tree().get_current_scene().get_node("Level/weather_control")
	weather.new_summer.connect(_new_summer)
	cash = 1000
	update()

func _new_summer():
	var pause_menu = get_tree().get_current_scene().get_node("Level/Camera2D/end_of_summer")
	var camps = get_tree().get_current_scene().get_node("Level/Level_generate").camps
	var revenue = 0
	for camp in camps:
		revenue += int(camp.revenue/10)
		camp.revenue = 0
	var text = $Sprite2D/RichTextLabel
	cash += revenue
	text.text = str(cash)
	pause_menu.activate(revenue)
	
func update():
	var text = $Sprite2D/RichTextLabel
	text.text = str(cash)
	
	
