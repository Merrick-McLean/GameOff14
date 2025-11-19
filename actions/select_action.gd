extends ActionState
class_name SelectAction

# TODO: Restructure UI scene to work with this
@onready var ui := get_tree().get_current_scene().get_node("UI")

var slide_duration: float = 0.3
var slide_offset: Vector2 = Vector2(0, 200)

var onscreen_position: Vector2
var offscreen_position: Vector2

func _ready():
	onscreen_position = ui.position
	offscreen_position = onscreen_position - slide_offset
	ui.show()

func enter() -> void:
	print("entering select")
	ui.position = offscreen_position
	ui.show()
	var tween = ui.create_tween()
	tween.tween_property(ui, "position", onscreen_position, slide_duration) \
			 .set_trans(Tween.TransitionType.TRANS_SINE) \
			 .set_ease(Tween.EaseType.EASE_OUT)
	
func exit():
	print("exiting select")
	var tween = ui.create_tween()
	tween.tween_property(ui, "position", offscreen_position, slide_duration) \
		 .set_trans(Tween.TransitionType.TRANS_SINE) \
		 .set_ease(Tween.EaseType.EASE_IN)
	tween.tween_callback(Callable(ui, "hide"))
	return
