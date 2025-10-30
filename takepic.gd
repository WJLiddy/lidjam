extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Ensure rendering is complete before capturing
	if Input.is_mouse_button_pressed(1):
		await RenderingServer.frame_post_draw

		# Get the image data from the viewport's texture
		var image = get_viewport().get_texture().get_image()
		image.resize(100,100)
		get_node("../TextureRect").texture = ImageTexture.create_from_image(image)
		
		
	pass
