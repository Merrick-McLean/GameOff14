extends  Camp

var idx
var interval = 100
var range_timer = 25
var _timer : Timer

func set_pos(pos, near_trees):
	position = pos
	z_index = global_position.y
	trees = near_trees 

func _ready():
	_timer = Timer.new()
	_timer.wait_time = interval + randf_range(-range_timer,range_timer)
	_timer.one_shot = false
	_timer.autostart = true
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	for i in range(randi_range(7,10)):
		spawn_camper()
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)

func _on_tick() -> void:
	var n = randf()
	if n < 0.0001 * campers.size():
		light_tree()

func close_illegal_camp():
	for camper in campers:
		camper.queue_free()
	get_parent().illegal_camps.erase(self)
	queue_free()

func _on_timer_timeout():
	close_illegal_camp()
