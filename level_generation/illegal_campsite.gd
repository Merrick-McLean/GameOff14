extends CampManager
var idx = null
func _ready() -> void:
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)
	z_index = global_position.y
	spawn_camper(Vector2(0,0))
	campers[0].target_point = Vector2(0,0)
	
func set_pos(pos, near_trees):
	global_position = pos
	trees = near_trees 
		
func _on_tick() -> void:
	if campers.size() == 0:
		return  

	var n := randf()

	if n < 0.001 * campers.size():
		light_tree()

	elif n > 0.999 * (1.0 / campers.size()):
		despawn_camper()

	elif n < 0.1 and campers.size() < max_campers:
		spawn_camper()
	
	n = randf()
	if n < 0.001:
			despawn_illegal_campsite()
			
func despawn_illegal_campsite():
	self.hide()
	self.set_process(false)
	get_parent().remove_illegal_camp(self)
