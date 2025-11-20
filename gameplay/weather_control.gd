extends Node2D
signal wet_wave
signal heat_wave
signal camper_wave
signal illegal_camper_wave

var interval = 5	
var _timer : Timer
var wave = {
	wet_wave : "wet_wave",
	heat_wave : "heat_wave",
	camper_wave : "camper_wave",
	illegal_camper_wave : "illegal_camper_wave"
}

func _ready() -> void:
	
	_timer = Timer.new()
	_timer.wait_time = interval
	_timer.one_shot = false
	_timer.autostart = true

	# connect the timer's timeout signal to tick signal
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

func _on_timer_timeout() -> void:
	emit_signal("wet_wave")
	var level = get_parent()
	var shader_layer = level.get_node("shader_layer").get_child(0)
	shader_layer.material.set_shader_parameter("heatwave", true)
