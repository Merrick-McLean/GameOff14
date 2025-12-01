extends Node2D

@onready var animation = $animation

func _ready() -> void:
	self.visible = false

func _process(_delta: float) -> void:
	if not animation.is_playing():
		self.visible = false

func play():
	await get_tree().create_timer(randf_range(4.0, 8.0)).timeout
	self.visible = true
	animation.play("default")
	get_parent().get_node("Level_generate").trees.pick_random().ignite()
