extends Node

var pics = []
var picsmax = 20
var bests = {}
var is_on_title = true
var money = 0
var bait = 20

var zoom_unlocked = false
var quickscope_unlocked = false
var bonus_film_unlocked = false
var bait_unlocked = false
var whistle_unlocked = false
var shoes_unlocked = false

var is_using_puter = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	money = 999
	if(false):
		zoom_unlocked = true
		quickscope_unlocked = true
		bonus_film_unlocked = true
		bait_unlocked = true
		whistle_unlocked = true
		shoes_unlocked = true
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func add_pic(pic: Dictionary):
	pics.push_front(pic)
	

func pic_count():
	return pics.size()
