extends Node2D

signal wet_wave
signal heat_wave
signal storm_wave

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
