extends CharacterBody2D	

@export var wander_radius: float = 40.0
@export var move_speed: float = 10.0

var center_point: Vector2
var target_point: Vector2
var target_tree = null

var lighter = false

@onready var animation = $AnimatedSprite2D

func _ready():
	center_point = get_parent().position # start with center
	pick_new_point()
	z_index = global_position.y
	if not get_parent().source_camp:
		switch_animation("res://assets/Troops/camper2.tres")
	animation.play("walk")
	
func pick_new_point():
	var angle = randf() * TAU # TAU = PI*2,so gereate random angel
	var radius = randf() * wander_radius 
	target_point = center_point + Vector2(cos(angle), sin(angle)) * radius
	if animation.animation != "walk":
		animation.play("walk")

func go_light(tree):
	if lighter == true:
		return
	target_point = tree.position
	target_tree = tree
	lighter = true

func _process(_delta): # move and slide here does mose the lifting, just kinda want them to wander around camp
	var direction = (target_point - global_position).normalized()
	
	velocity = direction * move_speed
	move_and_slide()
	z_index = global_position.y
	# If close enough select a new point
	
	if velocity.x < -1:
		animation.flip_h = true
	elif velocity.x > 1:
		animation.flip_h = false
		
	if global_position.distance_to(target_point) < 10.0:
		if lighter == true:
			target_tree.ignite()
		lighter = false

		pick_new_point()

func switch_animation(path: String):
	var anim : SpriteFrames = load(path)
	animation.sprite_frames = anim
