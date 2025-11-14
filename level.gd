extends Node2D

func get_level_rect() -> Rect2:
	var bounds = get_tree().get_current_scene().get_node("Level/Bounds/CollisionShape2D")
	var shape = bounds.shape as RectangleShape2D
	var size = shape.size
	var pos = bounds.global_position - size * 0.5
	return Rect2(pos, size)
