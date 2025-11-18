extends Sprite2D 

# Radius of the circle
var r = 50

func _ready():
	# Create an Image of size 2r x 2r
	var img = Image.new()
	img.create(r * 2, r * 2, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))  # Transparent background

	# Draw the circle
	for x in range(img.get_width()):
		for y in range(img.get_height()):
			var pos = Vector2(x, y) - Vector2(r, r)
			if pos.length() <= r:
				img.set_pixel(x, y, Color(1, 0, 0, 1))  # Red circle

	# Convert Image to Texture
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	
	# Assign texture to this sprite
	texture = tex

	# Center the sprite
	offset = Vector2(r, r)
