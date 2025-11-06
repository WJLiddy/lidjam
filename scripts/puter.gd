extends Node

var pictures_to_grade = []
var grading_index = 0
var in_grading = false

var base_scores = {
	"rigtest" : 30
}

var pose_mults = {
	"tpose" : 2,
	"idle" : 1.5,
	"walking" : 1
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func sort_by_score(a,b):
	return a["score"] > b["score"]
	
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
						
						# score all photos, pick the highest scoring pic of each critter
						var pics_by_critter = {}
						for p in Global.pics.duplicate():
							var out = process_picture(p)
							if(out["score"] != 0):
								var cname = p["critters"][0]["name"]
								# check if it's in pics by critter
								if(pics_by_critter.has(cname) and pics_by_critter[cname]["score"] < out["score"]):
									# we have a better pic
									pics_by_critter[cname] = out
								elif not pics_by_critter.has(cname):
									# we have no other pic liek this
									pics_by_critter[cname] = out
						# done scoring
						# put into list
						pictures_to_grade = pics_by_critter.values()
						grading_index = 0
						
						# sort, worst pics first
						pictures_to_grade.sort_custom(sort_by_score)
						# pictures are ready. load the first one.
						ui_grade()
						get_node("/root/forest/UIRender").rewind()
						$Background.visible = false
						in_grading = true
						$Grading.visible = true
				else:
					# grading
					if $Grading/Next/Next.get_overlapping_bodies().size() == 1:
						grading_index += 1
						if(grading_index == pictures_to_grade.size()):
							$Background.visible = true
							in_grading = false
							$Grading.visible = false
						else:
							ui_grade()
				
		# clamp to -.25 to 25
		# 0.15 to 0.45
	get_node("Mouse").position.x = clamp(get_node("Mouse").position.x,-0.25,0.25)
	get_node("Mouse").position.y = clamp(get_node("Mouse").position.y,0.15,0.45)

func ui_grade():
	var p = pictures_to_grade[grading_index]
	var cr = ImageTexture.create_from_image(p["pic"])
	cr.set_size_override(Vector2(200,150))
	$Grading/Preview.texture = cr
	$Grading/LabelJustLeft.text = p["ltext"]
	$Grading/LabelJustRight.text = p["rtext"]
	
	
	
func process_picture(pic : Dictionary) -> Dictionary:

	if(pic["critters"].size() == 0):
		return {"score":0}
		
	# get the first critter. it is the closest.
	var c0 = pic["critters"][0]
	
	# tryhard math eq
	var dist_weighted = 60 - (40 * atan(0.3 * (c0["dist"] * c0["zoom"]) - 2))
	
	var distance_val = int(clamp(dist_weighted,5,100))
	
	# no points if the critter is really far away
	if(distance_val == 5):
		return {"score":0}
	
	var base_val = base_scores[c0["name"]]
	# dist of less than 2 is perfect
	# dist of 50 is too far
	var same_bonus = pic["critters"].reduce(func(count, next): return count + 1 if c0["name"] == next["name"] else count, -1)
	var dif_bonus = pic["critters"].reduce(func(count, next): return count + 1 if c0["name"] != next["name"] else count, 0)
	var pose_mult = pose_mults[c0["pose"]]
	var orient_mult = 1
	# good facing
	if c0["orient"] < 1:
		orient_mult = 1.5
		
	var total_score = (base_val + distance_val + int(20 * sqrt(same_bonus)) + int(30 * sqrt(dif_bonus))) * (pose_mult + orient_mult)
	
	var left_text = "MONSTER\n"
	var right_text = "\n"
	left_text += c0["name"] + "\n"
	right_text += str(base_val) + "\n"
	
	left_text += "SIZE\n"
	right_text += "\n"
	left_text += str(int((c0["dist"] * c0["zoom"]))) + "\n"
	right_text += str(distance_val) + "\n"
	
	left_text += "OTHER MONSTERS\n"
	right_text += "\n"
	left_text += str(same_bonus) + " same\n"
	right_text += str(int(20 * sqrt(same_bonus))) + "\n"
	left_text += str(dif_bonus) + " different\n"
	right_text += str(int(20 * sqrt(dif_bonus)))  + "\n"
	
	left_text += "POSE\n"
	right_text += "\n"
	left_text += c0["pose"] 
	if(orient_mult != 1):
		left_text += ", front"
	left_text += "\n"
	right_text += "x" + str(pose_mult + orient_mult) + "\n"
	
	left_text += "TOTAL"
	right_text += str(total_score)
	print(total_score)
	
	return {"score":total_score,"ltext":left_text,"rtext":right_text,"pic":pic["image"]}
