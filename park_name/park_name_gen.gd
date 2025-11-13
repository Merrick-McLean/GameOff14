extends RichTextLabel

func _ready():
	var name_lists = load("res://park_name/park_name_lists.gd").new()

	var word_one = name_lists.pre.pick_random()
	var word_two = name_lists.suff.pick_random()
	var word_three = name_lists.designation.pick_random()

	text = word_one + " " + word_two + " " + word_three
