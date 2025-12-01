extends Node

var score := 0
var cash

func _ready(): 
	var weather = get_tree().get_current_scene().get_node("Level/weather_control")
	weather.new_summer.connect(_new_summer)
	cash = 1000
	score += cash
	update()

func _new_summer():
	var pause_menu = get_tree().get_current_scene().get_node("Level/Camera2D/end_of_summer")
	var camps = get_tree().get_current_scene().get_node("Level/Level_generate").camps
	var revenue = 0
	
	var trees = get_tree().get_nodes_in_group("trees")
	if not trees.is_empty():
		for tree in trees:
			if tree.current_state == tree.state.burnt:
				revenue += 0.1
		revenue = round(revenue / 50.0)
	
	for camp in camps: # are we not getting money for trees alive too?
		revenue += int(camp.revenue/12)
		camp.revenue = 0
	var text = $Sprite2D/RichTextLabel
	cash += revenue
	score += revenue
	text.text = "$" + str(int(cash))
	pause_menu.activate(revenue, score)
	
func update():
	var text = $Sprite2D/RichTextLabel
	text.text = "$" + str(int(cash))
