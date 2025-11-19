extends Camera2D

@export var pan_speed := 1.0                # how fast to pan
@export var zoom_speed := 0.1               # how fast to zoom in/out
@export var min_zoom := Vector2(0.5, 0.5)   # minimum zoom in
@export var max_zoom := Vector2(3.0, 3.0)   # maximum zoom out

var panning := false                        # if we are currently panning
var last_mouse_pos := Vector2.ZERO          # position of mouse
var pan_velocity := Vector2.ZERO            # to track current drag velocity
var pan_momentum := Vector2.ZERO            # momentum after release of panning
var pan_momentum_decay := 4.0             # how quickly momentum fades
var pan_momentum_intensity := 3.0          # strength of momentum

func _process(delta):
	if not panning:
		if pan_momentum.length() > 0.01:
			position += pan_momentum * delta * pan_momentum_intensity
			pan_momentum = pan_momentum.lerp(Vector2.ZERO, pan_momentum_decay * delta)
	else:
		pan_velocity = Vector2.ZERO

func _unhandled_input(event):
	# Handle zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				panning = true
				pan_velocity = Vector2.ZERO
				pan_momentum = Vector2.ZERO
				last_mouse_pos = event.position
			else:
				panning = false
				if pan_velocity.length() > 1.0:
					pan_momentum = pan_velocity
				else:
					pan_momentum = Vector2.ZERO
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom = (zoom - Vector2(zoom_speed, zoom_speed)).clamp(min_zoom, max_zoom)
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom = (zoom + Vector2(zoom_speed, zoom_speed)).clamp(min_zoom, max_zoom)
		
	elif event is InputEventMouseMotion and panning:
		var delta = event.position - last_mouse_pos
		if delta.length() > 0:
			position -= delta * pan_speed / zoom.x
			pan_velocity = pan_momentum_intensity * -delta * pan_speed / zoom.x
			last_mouse_pos = event.position
