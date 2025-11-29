extends Node2D

var cash = 5000

func _ready():
	cash = 5000
	
func _on_end_summer():
	for camp in get_parent().get_node("Level_generate").camps:
		cash += camp.revenue
		camp.revenue = 0
