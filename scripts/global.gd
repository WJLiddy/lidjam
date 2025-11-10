extends Node

var pics = []
var picsmax = 20
var bests = {}
var is_on_title = true
var money = 99

var zoom_unlocked = false
var quickscope_unlocked = false
var bonus_film_unlocked = false
var bait_unlocked = false
var whistle_unlocked = false

var is_using_puter = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func add_pic(pic: Dictionary):
	pics.push_front(pic)
	

func pic_count():
	return pics.size()
