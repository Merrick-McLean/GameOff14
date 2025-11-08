extends Node2D

@onready var tree_scene: PackedScene = preload("res://tree.tscn")

# Number of seed points for the Voronoi diagram
@export var num_points: int = 20
@export var show_points: bool = true
@export var point_size: float = 5.0
@export var num_trees: int = 10000


var screen_size: Vector2
var seed_points: Array = []
var seed_tree_groups: Array = []
var voronoi_image: Image
var voronoi_texture: ImageTexture
var polygon_nodes: Array = []


func _ready():
	screen_size = get_viewport_rect().size
	generate_voronoi()

func generate_voronoi():
	# Generate random seed points
	seed_points.clear()
	seed_tree_groups.clear()
	for i in range(num_points):
		var point = Vector2(
			randf() * screen_size.x,
			randf() * screen_size.y
		)
		seed_points.append(point)
		seed_tree_groups.append([])
	# Create the Voronoi diagram
	voronoi_image = Image.create(int(screen_size.x), int(screen_size.y), false, Image.FORMAT_RGB8)
	
	# For each pixel, find the closest seed point
	for x in range(int(screen_size.x)):
		for y in range(int(screen_size.y)):
			var pixel_pos = Vector2(x, y)
			var closest_idx = find_closest_point(pixel_pos)
			
			# Assign a color based on the closest seed point
			var color = get_color_for_index(closest_idx)
			voronoi_image.set_pixel(x, y, color)
	
	# Create texture from image
	voronoi_texture = ImageTexture.create_from_image(voronoi_image)
	var x = 0
	var min_x = 0.0
	var max_x = screen_size.x
	var min_y = 0.0
	var max_y = screen_size.y
	while(x<num_trees):
		x = x+1
		spawn_tree(min_x, max_x, min_y, max_y)
	
	for tree_group in seed_tree_groups:
		for tree in tree_group:
			tree.setup(tree_group)
	queue_redraw()

func find_closest_point(pos: Vector2) -> int:
	var min_dist = INF
	var closest_idx = 0
	
	for i in range(seed_points.size()):
		var dist = pos.distance_squared_to(seed_points[i])
		if dist < min_dist:
			min_dist = dist
			closest_idx = i
	
	return closest_idx

func get_color_for_index(idx: int) -> Color:
	# Generate a unique color for each region
	var hue = float(idx) / float(num_points)
	return Color.from_hsv(hue, 0.7, 0.9)

func spawn_tree(min_x, max_x, min_y, max_y):
	var tree = tree_scene.instantiate()
	var random_point = Vector2()
	var random_x = randf_range(min_x, max_x)
	var random_y = randf_range(min_y, max_y)
	random_point = Vector2(random_x, random_y)
	tree.position = random_point
	var idx = find_closest_point(random_point)
	seed_tree_groups[idx-1].append(tree)
	add_child(tree)
	
	tree.modulate = get_color_for_index(idx)
	
	
func _draw():
	if voronoi_texture:
		draw_texture(voronoi_texture, Vector2.ZERO)
	
	# Draw seed points if enabled
	if show_points:
		for point in seed_points:
			draw_circle(point, point_size, Color.BLACK)
			draw_circle(point, point_size - 1, Color.WHITE)
