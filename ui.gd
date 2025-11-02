extends Control

@export var picSpots: Array[TextureRect]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.wwdea
func _process(delta: float) -> void:
	$Flash.color = Color(1,1,1,$Flash.color.a -  10 * delta)
	pass

func update_total(count: int) -> void:
	$PicTotal.text = str(count)
	
func push_image(image: Image) -> void:
	$Flash.color = Color(1,1,1,1)
	for i in picSpots.size():
		if i == (picSpots.size() - 1):
			var cr =  ImageTexture.create_from_image(image)
			cr.set_size_override(Vector2(95,70))
			picSpots[i].texture = cr
		else:
			picSpots[i].texture = picSpots[i+1].texture
	
