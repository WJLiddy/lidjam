extends Node

var pics = []
var picsmax = 30

var is_using_puter = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func add_pic(pic: Dictionary):
	pics.push_front(pic)
	

func pic_count():
	return pics.size()
