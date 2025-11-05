extends Node2D
@onready var tree_scene: PackedScene = preload("res://tree.tscn")
var num_of_trees = 1000
var fire = true

func _ready() -> void:
	var x = 0
	while(x<num_of_trees):
		spawn_tree_in_forest_polygon()
		x = x+1
	var trees = get_children()
	for tree in trees:
		if tree is not Polygon2D:
			tree.setup()

func spawn_tree_in_forest_polygon() -> void:
	var tree = tree_scene.instantiate()
	
	var polygon_node = $ForestPolygon  # replace with your actual node path
	var polygon_points = polygon_node.polygon
	
	var random_point = Vector2()
	var max_attempts = 100
	var attempts = 0
	
	# Get bounding box of the polygon
	var min_x = polygon_points[0].x
	var max_x = polygon_points[0].x
	var min_y = polygon_points[0].y
	var max_y = polygon_points[0].y
	
	for p in polygon_points:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)
	
	# Generate random points until one is inside the polygon
	while attempts < max_attempts:
		var random_x = randf_range(min_x, max_x)
		var random_y = randf_range(min_y, max_y)
		random_point = Vector2(random_x, random_y)
		
		if Geometry2D.is_point_in_polygon(random_point, polygon_points):
			break
		attempts += 1
	
		if attempts == max_attempts:
			print("Failed to find a valid point in polygon")
			return
	
	tree.position = random_point
	add_child(tree)
	
