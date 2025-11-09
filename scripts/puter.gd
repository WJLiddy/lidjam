extends Node

var pictures_to_grade = []
var grading_index = 0
# desktop, menu, shopping, review
var state = "desktop"

var base_score = {
	"Turtle" : 2,
}

var pose_score = {
	"Resting" : 1,
	"Walking" : 2,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func sort_by_score(a,b):
	return a["score"] > b["score"]
	
func process_all_pictures():
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
	pictures_to_grade.sort_custom(sort_by_score)
	
func _input(event: InputEvent) -> void:
	if(Global.is_using_puter):
		if event is InputEventMouseMotion:
			get_node("Mouse").position.x += event.relative.x / 1000
			get_node("Mouse").position.y -= event.relative.y / 1000
			
		if event is InputEventMouseButton:
			if event.pressed:
				if(state == "desktop"):
					if $Background/Logoff/Logoff.get_overlapping_bodies().size() == 1:
						Global.is_using_puter = false
						get_node("../../Player").action_cooldown = 0.4
					if $Background/Shop/Shop.get_overlapping_bodies().size() == 1:
						state = "shop"
						$Background.visible = false
						$Shop.visible = true
					if $Background/Upload/Upload.get_overlapping_bodies().size() == 1 and Global.pics.size() > 0:
						process_all_pictures()
						get_node("../../../../UIRender").rewind()
						# fix later
						if not pictures_to_grade.is_empty():
							grading_index = 0
							ui_grade()
							$Background.visible = false
							state = "grading"
							$Grading.visible = true
				elif(state == "grading"):
					# grading
					if $Grading/Next/Next.get_overlapping_bodies().size() == 1:
						grading_index += 1
						if(grading_index == pictures_to_grade.size()):
							$Review.visible = true
							state = "review"
							$Grading.visible = false
							#update all the best scores
							for p in pictures_to_grade:
								if not Global.bests.has(p["critter"]):
									Global.bests[p["critter"]] = p
									Global.money += p["score"]
								elif Global.bests[p["critter"]]["score"] < p["score"]:
									Global.money += (p["score"] - Global.bests[p["critter"]]["score"])
									Global.bests[p["critter"]] = p
							ui_review()
						else:
							ui_grade()
				elif(state == "review"):
					if $Review/Next/Next.get_overlapping_bodies().size() == 1:
						state = "desktop"
						$Review.visible = false
						$Background.visible = true
				elif(state == "shop"):
					if $Shop/Buy1/Buy1.get_overlapping_bodies().size() == 1 and Global.money > 100 and not Global.zoom_unlocked:
						Global.zoom_unlocked = true
						Global.money -= 100
					if $Shop/Buy2/Buy2.get_overlapping_bodies().size() == 1 and Global.money > 100 and not Global.quickscope_unlocked:
						Global.quickscope_unlocked = true
						Global.money -= 100
					if $Shop/Buy3/Buy3.get_overlapping_bodies().size() == 1 and Global.money > 100 and not Global.bonus_film_unlocked:
						Global.bonus_film_unlocked = true
						Global.money -= 100
						Global.picsmax = 40
					if $Shop/Buy4/Buy4.get_overlapping_bodies().size() == 1 and Global.money > 100 and not Global.bonus_film_unlocked:
						Global.bait_unlocked = true
						Global.money -= 100
					if $Shop/Buy5/Buy5.get_overlapping_bodies().size() == 1 and Global.money > 100 and not Global.whistle_unlocked:
						Global.whistle_unlocked = true
						Global.money -= 100
					if $Shop/Next/Next.get_overlapping_bodies().size() == 1:
						state = "desktop"
						$Shop.visible = false
						$Background.visible = true
				
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
	var critter = pictures_to_grade[grading_index]["critter"]
	if(Global.bests.has(critter)):
		var cr2 = ImageTexture.create_from_image(Global.bests[critter]["pic"])
		cr2.set_size_override(Vector2(40,30))
		$Grading/Old.texture = cr2
		$Grading/OldText.text = str(Global.bests[critter].score)
	else:
		$Grading/Old.texture = null
	
	if(not Global.bests.has(critter)):
		$Grading/ProfText.text = "First time taking\n a picture of\n this critter. Weow"
	else:
		if(Global.bests[critter]["score"] > p["score"]):
			$Grading/ProfText.text = "This is your best pic\n of " + critter + ". However\n, your old pic was better."
		else:
			$Grading/ProfText.text = "This pic of " + critter + "\n is better than\n your previous best!"
			

func ui_review():
	for p in get_node("Review/PrevPics").get_children():
		p.texture = null
	
	for i in range(Global.bests.keys().size()):
		var b = Global.bests[Global.bests.keys()[i]]
		var cr = ImageTexture.create_from_image(b["pic"])
		cr.set_size_override(Vector2(40,30))
		get_node("Review/PrevPics").get_children()[i].texture = cr
		get_node("Review/PrevPics").get_children()[i].get_node("Label3D").text = b["critter"] + ", " + str(b["score"])
	
	
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
	
	var base_val = base_score[c0["name"]]
	# dist of less than 2 is perfect
	# dist of 50 is too far
	var same_bonus = pic["critters"].reduce(func(count, next): return count + 1 if c0["name"] == next["name"] else count, -1)
	var dif_bonus = pic["critters"].reduce(func(count, next): return count + 1 if c0["name"] != next["name"] else count, 0)
	var pose_mult = pose_score[c0["pose"]]
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
	
	return {"score":total_score,"ltext":left_text,"rtext":right_text,"pic":pic["image"],"critter":pic["critters"][0]["name"]}
