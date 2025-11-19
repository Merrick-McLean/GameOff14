extends Node2D
signal wet_wave
#signal heat_wave
#signal storm_wave

var interval = 25

var _timer : Timer

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
	var game = get_parent().get_parent()
	#var shader_layer = game.get_node("shader_layer").get_child(0) #one child so should be fine
	#shader_layer.material.set_shader_parameter("poland", true)
