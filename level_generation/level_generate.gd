extends Node2D

@onready var tree_scene: PackedScene = preload("res://level_generation/tree.tscn") 
@onready var camp_control_scene: PackedScene = preload("res://level_generation/campsite_control.tscn")
@onready var lookout_scene : PackedScene = preload("res://level_generation/lookout.tscn")

var grass_tile := Image.load_from_file("res://assets/Biome/TextureGrassland.png")
var water_tile := Image.load_from_file("res://assets/Biome/TextureWater.png")
var water_Texture := preload("res://assets/Biome/TextureWater.png") # for rivers

var grass_w = grass_tile.get_width()
var grass_h = grass_tile.get_height()
var water_w = water_tile.get_width()
var water_h = water_tile.get_height()

var noise := FastNoiseLite.new() # for river movement
@export var num_points: int = 25 #how many different groups
@export var show_points: bool = false  #for testing
@export var point_size: float = 5.0 #for testing
@export var num_trees: int = 5000 
@export var num_campsites: int = 2
@export var campsite_clearing: int = 2*1000 #for adjusting

var lakes: Array = []
var rivers: Array = []
var border_tol = 0.15 # to help trees burn between groups

var screen_size: Vector2

var seed_points: Array = []
var seed_tree_groups: Array = []

#camps are always 0,1 and lakes are always 2,3,
var trees: Array = []
var camps: Array = []
var lookout

var voronoi_image: Image
var voronoi_texture: ImageTexture
var polygon_nodes: Array = []

# Settings for rivers
const MAIN_LENGTH := 500
const BRANCH_COUNT := 2
const MAIN_STEP := 1
const BRANCH_STEP := 0.5

const CAMP_REACH := 1500

# LAKE PARAMETERS
var wobble_freq := 0.01 # set to 0 if no smoothening wanted
var wobble_amp  := 20000 # set to 0 if no smoothening wanted
var grass_shore_thickness := 1000.0
var rocky_shore_thickness := 2200.0 # adjust this, or adjust the function that calculates with this
var rocky_color := Color(0.85, 0.82, 0.65)

var lookout_pos = null

func _ready():
	screen_size = get_viewport_rect().size 
	noise.noise_type = FastNoiseLite.TYPE_PERLIN # for rivers
	noise.frequency = 0.3
	generate_voronoi() # this should generate everythin

func _draw():
	if voronoi_texture:
		draw_texture(voronoi_texture, Vector2.ZERO)
	# Draw seed points if enabled for debugging
	if show_points:
		for point in seed_points:
			draw_circle(point, point_size, Color.BLACK)
			draw_circle(point, point_size - 1, Color.WHITE)

func generate_voronoi():
	# Generate random seed points
	seed_points.clear()
	seed_tree_groups.clear()
	seed_points.resize(num_points)
	seed_tree_groups.resize(num_points)

	for i in num_points:
		seed_points[i] = Vector2(randf() * screen_size.x, randf() * screen_size.y)
		seed_tree_groups[i] = []
		
	#  spawn campsites, lakes, rivers 
	
	
	spawn_campsite_control()
	spawn_lakes()
	spawn_rivers()
	spawn_look_out()
	#  spawn trees 
	for i in num_trees:
		spawn_tree(0.0, screen_size.x, 0.0, screen_size.y)

	# Build tree adjacency (might wanna tink bout using kd)
	for tree_group in seed_tree_groups:
		for tree in tree_group:
			tree.other_trees += tree_group  

	#  tree setup  
	for tree in trees:
		tree.setup()
	trees[0].ignite() #test

	# Create Voronoi image
	var width := int(screen_size.x)
	var height := int(screen_size.y)
	
	var thread_count := 4  # avrg num of cores on bad pc
	var slice_width :=  width / thread_count #need this to be int, no parital pixels
	#all the diffrent threads
	var threads = []
	#start making threads
	for i in range(thread_count):
		var x_start := i * slice_width
		var x_end: int
		if i == thread_count - 1:
			x_end = width
		else:
			x_end = x_start + slice_width

		var thread := Thread.new()
		threads.append(thread)

		var args = [x_start, x_end, width, height]
		var callable = Callable(self, "_generate_voronoi_slice").bindv(args)
		thread.start(callable)
		
	var slices: Array[Image] = []
	for i in range(thread_count):
		var slice_img: Image = threads[i].wait_to_finish() #collect image parts after threads are done
		slices.append(slice_img)
		
	var final_img := Image.create(width, height, false, Image.FORMAT_RGB8)
	
	for i in range(thread_count):
		var slice_img := slices[i]

		var x_start := i * slice_width
		var x_end: int
		if i == thread_count - 1:
			x_end = width
		else:
			x_end = x_start + slice_width
		var region_width := x_end - x_start

		final_img.blit_rect(
			slice_img, 
			Rect2i(Vector2i(x_start, 0), Vector2i(region_width, height)), 
			Vector2i(x_start, 0)
	) #concatinate image parts
	
	voronoi_texture = ImageTexture.create_from_image(final_img) #draw!!!!!
	queue_redraw()


func _generate_voronoi_slice(x_start: int, x_end: int, width: int, height: int) -> Image: #thread function
	var img := Image.create(width, height, false, Image.FORMAT_RGB8)

	for x in range(x_start, x_end):
		for y in range(height):
			var pos := Vector2(x, y)
			var info = find_two_closest(pos)
			var delta: float = info.second_dist - info.closest_dist

			var color: Color

			if info.closest_idx in lakes:
				if delta < grass_shore_thickness:
					color = sample_grass_tile(x, y)
				elif delta < rocky_shore_thickness:
					color = rocky_color
				else:
					color = sample_water_tile(x, y)
			else:
				color = sample_grass_tile(x, y)

			img.set_pixelv(Vector2i(x, y), color)

	return img
	

func sample_water_tile(x, y): #for cleanup
	var tx = x % water_w
	var ty = y % water_h
	return water_tile.get_pixel(tx, ty)
	
func sample_grass_tile(x, y): #for cleanup
	var tx = x % water_w
	var ty = y % water_h
	return grass_tile.get_pixel(tx, ty)

func find_closest_point(pos: Vector2) -> int: #legacy for before textures
	var min_dist = INF
	var closest_idx = 0
	for i in range(seed_points.size()):
		var dist = pos.distance_squared_to(seed_points[i])
		var nx := noise.get_noise_2d(pos.x * wobble_freq + seed_points[i].x * 0.01, pos.y * wobble_freq + seed_points[i].y * 0.01)
		dist += nx * wobble_amp
		
		if dist < min_dist:
			min_dist = dist
			closest_idx = i
	return closest_idx
	
func find_closest_point_tree(pos: Vector2, tolerance: float = border_tol) -> Array: #needed for assiging groups to trees
	var min_dist = INF
	var closest_idx = -1
	var close_indices = []
	
	# First pass find the minimum distance
	for i in range(seed_points.size()):
		var dist = pos.distance_squared_to(seed_points[i])
		var nx := noise.get_noise_2d(pos.x * wobble_freq + seed_points[i].x * 0.01, pos.y * wobble_freq + seed_points[i].y * 0.01)
		dist += nx * wobble_amp
		if dist < min_dist:
			min_dist = dist
			closest_idx = i
	close_indices.append(closest_idx)
	# Second pass find all indices within the tolerance range (for trees that move between groups)
	for i in range(seed_points.size()):
		var dist = pos.distance_squared_to(seed_points[i])
		if dist <= min_dist * (1+tolerance):
			close_indices.append(i)
	return close_indices

func too_close_to_camp_lake(pos: Vector2): #kill trees to close to camps and lakes
	for camp in camps:
		var dist = pos.distance_squared_to(camp.position)
		if dist < campsite_clearing:
			return true
	var idx = find_closest_point(pos)
	for lake in lakes: # this will need to be replaced soon
		if lake == idx:
			return true
	var dist = pos.distance_squared_to(lookout.position) 
	if dist < campsite_clearing:
			return true
	return false

func get_color_for_index(idx: int) -> Color: # for debugging, each seed point gets a color
	var hue = float(idx) / float(num_points)
	return Color.from_hsv(hue, 0.7, 0.9)

func spawn_lakes():
	lakes.append(2) #stupid but good for now
	lakes.append(3)
	
func spawn_rivers():
	var flow_dir = get_direction(seed_points[2], seed_points[3]) #get a direction so both rivers flow "down"
	var threads = []
	var river_seeds = [2,3]
	for i in range(river_seeds.size()):
		var thread := Thread.new()
		threads.append(thread)
		var args = [river_seeds[i], flow_dir]
		var callable = Callable(self, "_generate_river_network").bindv(args)
		thread.start(callable)
		
	for i in range(river_seeds.size()):
		threads[i].wait_to_finish()
	
func get_direction(start1: Vector2, start2: Vector2):
	var flow = -start2-start1
	return flow.normalized()

func _generate_river_network(start: int, flow: Vector2):
	var main_points = generate_river_points(
		seed_points[start],
		MAIN_LENGTH,
		MAIN_STEP,
		0,
		flow
	)
	create_line2d(main_points, 10)
	# Create branches
	for i in range(BRANCH_COUNT):
		var idx = randi_range(0, main_points.size()-1) #WHAT POINT TO MAKE RIVER
		var branch_start = main_points[idx]
		var branch_points = generate_river_points(
			branch_start,
			MAIN_LENGTH / 2,
			BRANCH_STEP,
			0,
			flow
		) # ERROR: Invalid access of index '200' on a base object of type: 'Array'. Randomly occurs on launch
		# Error: Invalid access of index '0' on a base object of type: 'Array'. Also
		create_line2d(branch_points,  6)

func generate_river_points(start: Vector2, length: int, step: float, noise_offset: int, flow: Vector2) -> Array:
	var points: Array = []
	var pos = start
	var angel_const = 0
	if length != MAIN_LENGTH:
		angel_const = randf_range(-90, 90)
	for i in range(length):
		var t = float(i) * 0.03

		var angle = noise.get_noise_1d(t + noise_offset) * 1.5
		var direction = flow.rotated(angle + angel_const)

		pos += direction * step
		if 0 > pos.x or pos.x > screen_size.x or 0 > pos.y or pos.y > screen_size.y:
			break
		points.append(pos)
	return points

func create_line2d(points: Array, width := 10):
	var line := Line2D.new()
	line.width = 10
	line.z_index = line.global_position.y # sets rivers to be ordered on their y for illusion 
	for p in points:
		line.add_point(p)
		
	line.texture = water_Texture
	line.texture_mode = Line2D.LINE_TEXTURE_TILE  # best for rivers
	line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	call_deferred("add_child", line)
	rivers.append(line)
	
func spawn_look_out():
	var lookouttemp = lookout_scene.instantiate()
	lookouttemp.position = seed_points[4]
	lookout = lookouttemp
	add_child(lookout)
	
func spawn_campsite_control():
	var camp = camp_control_scene.instantiate()
	add_child(camp)

func set_camptree(tree): #calculate which trees are next too camps and can be lit on fire
	for camp in camps:
		var dist = tree.position.distance_squared_to(camp.position)
		if dist < (campsite_clearing + CAMP_REACH): # may need to review this
			tree.camp_tree  = true
			camp.trees.append(tree)

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
	tree.seed = idxes[0]
	tree.set_texture(idxes[0]) #main idx
	add_child(tree)
	tree.modulate = get_color_for_index(idxes[0])
	set_camptree(tree)

func get_flow_direction(pos: Vector2) -> Vector2:
	return -pos.normalized()

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

func find_two_closest(pos: Vector2) -> Dictionary:
	var best1 := INF
	var best2 := INF
	var idx1 := -1
	var idx2 := -1

	for i in range(seed_points.size()):
		var dist = pos.distance_squared_to(seed_points[i])
		var nx := noise.get_noise_2d(pos.x * wobble_freq + seed_points[i].x * 0.01, pos.y * wobble_freq + seed_points[i].y * 0.01)
		dist += nx * wobble_amp

		if dist < best1:
			best2 = best1
			idx2 = idx1
			best1 = dist
			idx1 = i
		elif dist < best2:
			best2 = dist
			idx2 = i

	return {
		"closest_idx": idx1,
		"second_idx": idx2,
		"closest_dist": best1,
		"second_dist": best2
	}
