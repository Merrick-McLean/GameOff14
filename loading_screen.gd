extends Control

var progress_arr := []
var target_scene_path := "res://Game.tscn"
var is_loading := true

func _ready():
	ResourceLoader.load_threaded_request(target_scene_path)
	set_process(true)

func _process(_delta):
	if not is_loading:
		return
	var status = ResourceLoader.load_threaded_get_status(target_scene_path, progress_arr)
	$Label.text = "Generating World ..." 
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene_res = ResourceLoader.load_threaded_get(target_scene_path)
		if scene_res:
			get_tree().change_scene_to_packed(scene_res)
		else:
			push_error("Failed to get loaded scene resource")
		is_loading = false
		set_process(false)

	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		push_error("Loading failed for " + target_scene_path)
		is_loading = false
		set_process(false)
