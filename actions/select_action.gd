extends ActionState
class_name SelectAction

# TODO: Restructure UI scene to work with this
@onready var ui_buttons := get_tree().get_current_scene().get_node("UIContainer/UIButtons")
@onready var ui_economy := get_tree().get_current_scene().get_node("UIContainer/UIEconomy")
@onready var ui_wave := get_tree().get_current_scene().get_node("UIContainer/UIWave")

# if you click too quick it goes out of out of sync and possibly continues moving before reset
# need to hard code values and add handling to skip animation in some cases perhaps?

var slide_duration: float = 0.3

var button_onscreen_position: Vector2 = Vector2(0, 0)
var button_offscreen_position: Vector2 = Vector2(-300, 0)

var economy_onscreen_position: Vector2 = Vector2(0, 25)
var economy_offscreen_position: Vector2 = Vector2(0, -100)

var wave_onscreen_position: Vector2 = Vector2(100, 900)
var wave_offscreen_position: Vector2 = Vector2(100, 1100)

func enter() -> void: # need to fix quick clicks hiding the overlay...
	#buttons_enter()
	#economy_enter()
	#wave_enter()
	return

func buttons_enter():
	ui_buttons.position = button_offscreen_position
	ui_buttons.show()
	
	var tween = ui_buttons.create_tween()
	tween.tween_property(ui_buttons, "position", button_onscreen_position, slide_duration) \
			 .set_trans(Tween.TransitionType.TRANS_SINE) \
			 .set_ease(Tween.EaseType.EASE_OUT)

func economy_enter():
	ui_economy.position = economy_offscreen_position
	ui_economy.show()
	
	var tween = ui_economy.create_tween()
	tween.tween_property(ui_economy, "position", economy_onscreen_position, slide_duration) \
			 .set_trans(Tween.TransitionType.TRANS_SINE) \
			 .set_ease(Tween.EaseType.EASE_OUT)

func wave_enter():
	ui_wave.position = wave_offscreen_position
	ui_wave.show()
	
	var tween = ui_wave.create_tween()
	tween.tween_property(ui_wave, "position", wave_onscreen_position, slide_duration) \
			 .set_trans(Tween.TransitionType.TRANS_SINE) \
			 .set_ease(Tween.EaseType.EASE_OUT)

func exit():
	#button_exit()
	#economy_exit()
	#wave_exit()
	return

func button_exit():
	var tween = ui_buttons.create_tween()
	tween.tween_property(ui_buttons, "position", button_offscreen_position, slide_duration) \
		 .set_trans(Tween.TransitionType.TRANS_SINE) \
		 .set_ease(Tween.EaseType.EASE_IN)
	tween.tween_callback(Callable(ui_buttons, "hide"))

func economy_exit():
	var tween = ui_economy.create_tween()
	tween.tween_property(ui_economy, "position", economy_offscreen_position, slide_duration) \
		 .set_trans(Tween.TransitionType.TRANS_SINE) \
		 .set_ease(Tween.EaseType.EASE_IN)
	tween.tween_callback(Callable(ui_economy, "hide"))
	
func wave_exit():
	var tween = ui_wave.create_tween()
	tween.tween_property(ui_wave, "position", wave_offscreen_position, slide_duration) \
		 .set_trans(Tween.TransitionType.TRANS_SINE) \
		 .set_ease(Tween.EaseType.EASE_IN)
	tween.tween_callback(Callable(ui_wave, "hide"))
