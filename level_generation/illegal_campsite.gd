extends CampManager


func _ready() -> void:
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)
	z_index = global_position.y
	
	
	spawn_camper(Vector2(0,0))
	campers[0].target_point = Vector2(0,0)
	
func set_pos(pos, near_trees):
	global_position = pos
	trees = near_trees 
		
