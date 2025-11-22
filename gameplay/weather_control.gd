extends Node2D

signal wet_wave
signal heat_wave
signal relax
signal camper_wave
signal illegal_camper_wave

var interval = 10000
var _timer : Timer

# ENUM of effects
enum wave  {
	wet_wave  = 0,
	heat_wave = 1,
	camper_wave = 2,
	illegal_camper_wave = 3,
	relax = 4
}

var next = randi_range(0,1)

# Fade values
var fade := 0.0            # Current fade
var fade_target := 0.0     # Where fade should go (0 or 1)
var fade_speed := 1.0		#seconds for fade
# Cached reference to shader material
var shader_layer
var shader_material


func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = interval
	_timer.one_shot = false
	_timer.autostart = true
	
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

	# material ref
	var level = get_parent()
	shader_layer = level.get_node("shader_layer").get_child(0)
	shader_material = shader_layer.material


func _process(delta: float) -> void:
	# fade update
	fade = lerp(fade, fade_target, fade_speed*delta)
	shader_material.set_shader_parameter("fade", fade)
	
	if fade == 0: # this allows for fade out
		shader_material.set_shader_parameter("wetwave", false)
		shader_material.set_shader_parameter("heatwave", false)


func _on_timer_timeout() -> void:
	match next:

		0: # WET WAVE
			emit_signal("wet_wave")
			shader_material.set_shader_parameter("wetwave", true)
			shader_material.set_shader_parameter("heatwave", false)
			fade_target = 1.0   # fade IN wetwave

		1: # HEAT WAVE
			emit_signal("heat_wave")
			shader_material.set_shader_parameter("wetwave", false)
			shader_material.set_shader_parameter("heatwave", true)
			fade_target = 1.0   # fade IN heatwave

		4: # RELAX (fade everything out)
			emit_signal("relax")
			fade_target = 0.0   # fade OUT all waves
			
			

	# Cycle between wave → relax → wave → relax
	if next != 4:
		next = 4
	else:
		next = randi_range(0,1)
	_timer.wait_time = interval
	_timer.start()
	
