class_name ActionState
extends Node2D

var controller : Node = null  # reference to player controller

func enter() -> void: #previous_state: ActionState arg?
	# Called when this state becomes active
	pass

func exit() -> void:
	# Called when this state is replaced
	pass

func handle_input(event: InputEvent) -> void:
	# Override in subclasses
	pass

func update(delta: float) -> void:
	# Optional per-frame updates
	pass
