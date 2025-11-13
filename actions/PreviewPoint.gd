extends Node2D

@export var radius: float = 1.0
@export var color: Color = Color(0.1, 0.3, 0.6, 1.0)

func _draw():
	draw_circle(Vector2.ZERO, radius, color)
