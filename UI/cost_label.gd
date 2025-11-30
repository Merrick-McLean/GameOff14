extends RichTextLabel

func _ready() -> void:
	self.text = "$"+str(get_parent().cost)
