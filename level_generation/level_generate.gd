extends Node2D

@onready var tree_scene: PackedScene = preload("res://level_generation/tree.tscn")
@onready var camp_scene: PackedScene = preload("res://level_generation/campsite.tscn")

var grass_tile := Image.load_from_file("res://assets/Biome/TextureGrassland.png")
var water_tile := Image.load_from_file("res://assets/Biome/TextureWater.png")

var noise := FastNoiseLite.new()
@export var num_points: int = 25 #how many different groups
@export var show_points: bool = true
@export var point_size: float = 5.0
@export var num_trees: int = 5000
@export var num_campsites: int = 2
@export var campsite_clearing: int = 2*1000
var lakes: Array = []
var rivers: Array = []
var border_tol = 0.05
var screen_size: Vector2
var seed_points: Array = []
var seed_tree_groups: Array = []
var trees: Array = []
var camps: Array = []
var voronoi_image: Image
var voronoi_texture: ImageTexture
var polygon_nodes: Array = []

func _ready():
	screen_size = get_viewport_rect().size
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.3
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
	var i = 0
	var min_x = 0.0
	var max_x = screen_size.x
	var min_y = 0.0
	var max_y = screen_size.y
	while (i<num_campsites):
		spawn_campsite(i)
		i = i+1	
	i = 0
	
	spawn_lakes()
	generate_river_network(2)
	generate_river_network(3)
	
	while(i<num_trees):
		i = i+1
		spawn_tree(min_x, max_x, min_y, max_y)
	for tree_group in seed_tree_groups:
		for tree in tree_group:
			tree.other_trees = tree.other_trees + tree_group
	for tree in trees:
		tree.setup()
	# trees[0].ignite() # debug
	# Create the Voronoi diagram for debugging ---------
	voronoi_image = Image.create(int(screen_size.x), int(screen_size.y), false, Image.FORMAT_RGB8)
	
	# For each pixel, find the closest seed point 
	for x in range(int(screen_size.x)):
		for y in range(int(screen_size.y)):
			var pixel_pos = Vector2(x, y)
			var closest_idx = find_closest_point(pixel_pos)
			
			# This is non-permanent, does not deal with transition between different ground textures
			# Mainly a temporary implementation jsut to se what it looks like
			var tile = get_tile_for_index(closest_idx) 
			var tx = x % tile.get_width()
			var ty = y % tile.get_height()
			var tile_color = tile.get_pixel(tx, ty)
			
			# Assign a color based on the closest seed point
			voronoi_image.set_pixel(x, y, tile_color)
	
	# Create texture from image
	voronoi_texture = ImageTexture.create_from_image(voronoi_image)
	
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
	
func find_closest_point_tree(pos: Vector2, tolerance: float = border_tol) -> Array:
	var min_dist = INF
	var closest_idx = -1
	var close_indices = []

	# First pass — find the minimum distance
	for i in range(seed_points.size()):
		var dist = pos.distance_squared_to(seed_points[i])
		if dist < min_dist:
			min_dist = dist
			closest_idx = i
	close_indices.append(closest_idx)

	# Second pass — find all indices within the tolerance range
	for i in range(seed_points.size()):
		var dist = pos.distance_squared_to(seed_points[i])
		if dist <= min_dist * (1+tolerance):
			close_indices.append(i)
			

	return close_indices

func too_close_to_camp_lake(pos: Vector2):
	for camp in camps:
		var dist = pos.distance_squared_to(camp.position)
		if dist < campsite_clearing:
			return true
	var idx = find_closest_point(pos)
	for lake in lakes: # this will need to be replaced soon
		if lake == idx:
			return true
	return false

func get_color_for_index(idx: int) -> Color:
	# Generate a unique color for each region
	var hue = float(idx) / float(num_points)
	return Color.from_hsv(hue, 0.7, 0.9)

func get_tile_for_index(idx: int) -> Image:
	if idx in lakes:
		return water_tile
	else:
		return grass_tile

func spawn_lakes():
	lakes.append(2) #stupid but good for now
	lakes.append(3)

# Settings for rivers
const MAIN_LENGTH := 200
const BRANCH_COUNT := 2
const MAIN_STEP := 5
const BRANCH_STEP := 2.5
func generate_river_network(start: int):
	var main_points = generate_river_points(
		seed_points[start],
		MAIN_LENGTH,
		MAIN_STEP,
		0
	)

	create_line2d(main_points, 10)
	# Create branches
	for i in range(BRANCH_COUNT):
		var idx = randi_range(0, MAIN_LENGTH) #WHAT POINT TO MAKE RIVER
		var branch_start = main_points[idx]
		var branch_points = generate_river_points(
			branch_start,
			MAIN_LENGTH / 2,
			BRANCH_STEP,
			0
		) # random crash occured here!!! something about array index 200 idk

		create_line2d(branch_points,  6)

func generate_river_points(start: Vector2, length: int, step: float, noise_offset: int) -> Array:
	var points: Array = []
	var pos = start
	var angel_const = randf_range(-100, 100)
	var directionf = get_flow_direction(-start)
	for i in range(length):
		var t = float(i) * 0.03

		var angle = noise.get_noise_1d(t + noise_offset) * 1.5
		var direction = directionf.rotated(angle + angel_const)

		pos += direction * step
		points.append(pos)
	return points

func create_line2d(points: Array, width := 8):
	var line := Line2D.new()
	line.width = 10
	line.default_color = Color.STEEL_BLUE
	line.z_index = 1000
	for p in points:
		line.add_point(p)
	add_child(line)
	rivers.append(line)
	
func spawn_campsite(idx : int):
	var point = seed_points[idx]
	var camp = camp_scene.instantiate()
	camp.position = point
	camp.z_index = point[1]
	add_child(camp)
	camps.append(camp)

func set_camptree(tree):
	for camp in camps:
		var dist = tree.position.distance_squared_to(camp.position)
		if dist < (campsite_clearing + 1000): # may need to review this
			tree.camp_tree  = true

func spawn_tree(min_x, max_x, min_y, max_y):
	#spawn each tree and add to seed group
	var random_point = Vector2()
	var random_x = randf_range(min_x, max_x)
	var random_y = randf_range(min_y, max_y)
	random_point = Vector2(random_x, random_y)
	if too_close_to_camp_lake(random_point):
		return
	if point_too_close_to_river(random_point):
		return
	var tree = tree_scene.instantiate()
	tree.position = random_point
	var idxes = find_closest_point_tree(random_point)
	if idxes.size() > 0:
		for idx in idxes:
			seed_tree_groups[idx].append(tree)
	trees.append(tree)
	tree.z_index = random_y
	
	tree.set_texture(idxes[0]) #main idx
	add_child(tree)
	tree.modulate = get_color_for_index(idxes[0])
	set_camptree(tree)

func _draw():
	if voronoi_texture:
		draw_texture(voronoi_texture, Vector2.ZERO)
	# Draw seed points if enabled
	if show_points:
		for point in seed_points:
			draw_circle(point, point_size, Color.BLACK)
			draw_circle(point, point_size - 1, Color.WHITE)
			
func get_flow_direction(pos: Vector2) -> Vector2:
	return pos.normalized()

func is_point_too_close(p: Vector2, a: Vector2, b: Vector2, threshold: float) -> bool:
	var ab = b - a
	var t = (p - a).dot(ab) / ab.length_squared()
	t = clamp(t, 0, 1)  # restrict to segment
	var closest = a + ab * t
	return p.distance_to(closest) < threshold

func point_too_close_to_river(p: Vector2) -> bool:
	for line in rivers:
		for i in range(line.points.size() - 1):
			var a = line.points[i]
			var b = line.points[i + 1]
			if is_point_too_close(p, a, b, 15): #cahnge last nmber for river threshold
				return true
	return false
