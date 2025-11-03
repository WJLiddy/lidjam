extends Node

var pictures_to_grade = []
var in_grading = false

var base_scores = {
	"rigtest" : 30
}

var pose_mults = {
	"idle" : 2,
	"walking" : 1
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _input(event: InputEvent) -> void:
	if(Global.is_using_puter):
		if event is InputEventMouseMotion:
			get_node("Mouse").position.x += event.relative.x / 1000
			get_node("Mouse").position.y -= event.relative.y / 1000
			
		if event is InputEventMouseButton:
			if event.pressed:
				if(!in_grading):
					if $Background/Logoff/Logoff.get_overlapping_bodies().size() == 1:
						Global.is_using_puter = false
						get_node("../../Player").action_cooldown = 0.4
					if $Background/Upload/Upload.get_overlapping_bodies().size() == 1:
						pictures_to_grade = Global.pics.duplicate()
						get_node("/root/forest/UIRender").rewind()
						$Background.visible = false
						in_grading = true
						$Grading.visible = true
				else:
					# grading
					if $Grading/Next/Next.get_overlapping_bodies().size() == 1:
						if pictures_to_grade > 0:
							var output = process_picture(pictures_to_grade[pictures_to_grade.size()-1])
							pictures_to_grade.remove_at(pictures_to_grade.size()-1)
							$Grading/LabelJustLeft.text = output[1]
							$Grading/LabelJustRight.text = output[2]
						else:
							$Background.visible = true
							in_grading = false
							$Grading.visible = false
				
		# clamp to -.25 to 25
		# 0.15 to 0.45
	get_node("Mouse").position.x = clamp(get_node("Mouse").position.x,-0.25,0.25)
	get_node("Mouse").position.y = clamp(get_node("Mouse").position.y,0.15,0.45)

func process_picture(pic : Dictionary):
	var cr =  ImageTexture.create_from_image(pic["image"])
	cr.set_size_override(Vector2(200,150))
	$Grading/Preview.texture = cr 
	if(pic["critters"].size() == 0):
		return [0,"",""]
	# get the first critter. it is the closest.
	var c0 = pic["critters"][0]
	
	# no points if the critter is really far away
	if(c0["dist"] > 90):
		return [0,"",""]
	
	var base_val = base_scores[c0["name"]]
	var distance_val = int((100 - c0["dist"])) 
	var same_bonus = pic["critters"].reduce(func(count, next): return count + 1 if c0["name"] == next["name"] else count, -1)
	var dif_bonus = pic["critters"].reduce(func(count, next): return count + 1 if c0["name"] != next["name"] else count, 0)
	var pose_mult = pose_mults[c0["pose"]]
	var orient_mult = 1
	# good facing
	if c0["orient"] < 1:
		orient_mult = 2
		
	var total_score = (base_val + distance_val + int(20 * sqrt(same_bonus)) + int(30 * sqrt(dif_bonus))) * pose_mult * orient_mult
	
	var left_text = "MONSTER\n"
	var right_text = "\n"
	left_text += c0["name"] + "\n"
	right_text += str(base_val) + "\n"
	
	left_text += "DISTANCE\n"
	right_text += "\n"
	left_text += str(int(c0["dist"])) + "\n"
	right_text += str(distance_val) + "\n"
	
	left_text += "OTHER MONSTERS\n"
	right_text += "\n"
	left_text += str(same_bonus) + " same\n"
	right_text += str(int(20 * sqrt(same_bonus))) + "\n"
	left_text += str(dif_bonus) + " different\n"
	right_text += str(int(20 * sqrt(dif_bonus)))  + "\n"
	
	left_text += "POSE\n"
	right_text += "\n"
	left_text += c0["pose"] + "\n"
	right_text += str(pose_mult) + "\n"
	
	left_text += "TOTAL"
	right_text += str(total_score)
	
	return [total_score,left_text,right_text]
