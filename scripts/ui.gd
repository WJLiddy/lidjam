extends Control

@export var picSpots: Array[TextureRect]
var nopic = load("res://programmerart/nopic.png")

var whistling = false

var photomode = false

var critterprevtext = ""

var moneyprev = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.wwdea
func _process(delta: float) -> void:
	$Flash.color = Color(1,1,1,$Flash.color.a -  5 * delta)
	$Status.text = str(Global.pics.size()) + " / " + str(Global.picsmax)
	$FPS.text = "FPS " + str(Engine.get_frames_per_second())
	$Money.text = "$ " +  str(int(moneyprev))
	
	if(moneyprev < Global.money):
		moneyprev += delta*5
		$Money.scale = Vector2(2,2)
	if(moneyprev > Global.money):
		moneyprev = Global.money

	$Money.scale = lerp($Money.scale,Vector2(1,1),10*delta)
	
	
	$CandyCount/Label.text = str(Global.bait)
	if(whistling):
		$Whistle.modulate.a = move_toward($Whistle.modulate.a,1,delta)
	else:
		$Whistle.modulate.a = move_toward($Whistle.modulate.a,0.5,delta)

	$CandyCount.visible = not photomode and Global.bait_unlocked
	$Whistle.visible = not photomode and Global.whistle_unlocked
	$Money.visible = not photomode
	$PicSpot.visible = not photomode
	$PicSpot2.visible = not photomode
	$PicSpot3.visible = not photomode
	$CritterPrev.visible = photomode
	$CritterPrev.text = critterprevtext
	$CritterPrev.modulate = Color(1,1,1,.4)
	if(photomode):
		$Status.modulate = Color(1,1,1,.4)
		
	else:
		$Status.modulate = Color(1,1,1,1)
		


func push_image(image: Image) -> void:
	$Flash.color = Color(1,1,1,1)
	for i in picSpots.size():
		if i == (picSpots.size() - 1):
			var cr =  ImageTexture.create_from_image(image)
			cr.set_size_override(Vector2(95,70))
			picSpots[i].texture = cr
		else:
			picSpots[i].texture = picSpots[i+1].texture

func push_image_reverse(image: Image) -> void:
	var i = picSpots.size() - 1
	while(i > 0):
			picSpots[i].texture = picSpots[i-1].texture
			i -= 1
	var cr =  ImageTexture.create_from_image(image)
	cr.set_size_override(Vector2(95,70))
	picSpots[0].texture = cr

func rewind():
	while(Global.pics.size() > 0):
		$Upload.play()
		if(Global.pics.size() > 3):
			push_image_reverse(Global.pics[3]["image"]) 
		else:
			push_image_reverse(nopic.get_image())
		Global.pics.remove_at(0)
		await get_tree().create_timer(0.2).timeout
