extends ActionState
class_name SelectAction

# TODO: Restructure UI scene to work with this
@onready var ui := get_tree().get_current_scene().get_node("UIContainer/UI")

var slide_duration: float = 0.3
var slide_offset: Vector2 = Vector2(200, 0)

var onscreen_position: Vector2
var offscreen_position: Vector2

func enter() -> void:
	offscreen_position = ui.position
	onscreen_position = offscreen_position + slide_offset
	
	ui.position = offscreen_position
	ui.show()
	
	var tween = ui.create_tween()
	tween.tween_property(ui, "position", onscreen_position, slide_duration) \
			 .set_trans(Tween.TransitionType.TRANS_SINE) \
			 .set_ease(Tween.EaseType.EASE_OUT)
	
func exit():
	var tween = ui.create_tween()
	tween.tween_property(ui, "position", offscreen_position, slide_duration) \
		 .set_trans(Tween.TransitionType.TRANS_SINE) \
		 .set_ease(Tween.EaseType.EASE_IN)
	tween.tween_callback(Callable(ui, "hide"))
