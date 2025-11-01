extends Control

@export var picSpots: Array[TextureRect]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_total(count: int) -> void:
	$PicTotal.text = str(count)
	
func push_image(image: Image) -> void:
	for i in picSpots.size():
		if i == (picSpots.size() - 1):
			var cr =  ImageTexture.create_from_image(image)
			cr.set_size_override(Vector2(95,70))
			picSpots[i].texture = cr
		else:
			picSpots[i].texture = picSpots[i+1].texture
	
