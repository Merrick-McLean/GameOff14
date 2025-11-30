extends Node2D

@onready var anim := $AnimatedSprite2D

func _ready():
	z_index = 1499
	anim.play("retardent")
	anim.animation_finished.connect(_on_finish)

func _on_finish():
	queue_free()
