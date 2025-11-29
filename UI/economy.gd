extends Node

func _ready(): 
	var weather = get_tree().get_current_scene().get_node("Level/weather_control")
	weather.new_summer.connect(_new_summer)
	

func _new_summer():
	pass
