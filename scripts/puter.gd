extends Node

var pictures_to_grade = []
var grading_index = 0
# desktop, menu, shopping, review
var state = "desktop"
var nopic = load("res://programmerart/nopic.png")

var upload_timer = 5

# species hardcoded stuff
var base_score = {
	"Olturtle" : 2,
	"Burglerat" : 2,
	"Veerabbit" : 2,
	"Cowbug" : 2,
	"Castcrab" : 2,
	"Pargopher" : 3,
	"Frankendeer" :3,
	"Vamphibian" : 3,
	"Cowbird" : 3,
	"Billterfly" : 3,
	"Cresbird" : 4,
	"Leghost" : 4,
	"Bugleton" : 4,
	"Corpofish" : 4,
	"Gold Burglerat" : 7
}

var species_same_max = {
	"Olturtle" : 0,
	"Burglerat" : 2,
	"Veerabbit" : 3,
	"Cowbug" : 3,
	"Pargopher" : 3,
	"Cresbird" : 3,
	"Frankendeer" : 2,
	"Vamphibian" : 0,
	"Cowbird" : 5,
	"Leghost" : 2,
	"Bugleton" : 2,
	"Gold Burglerat" : 0,
	
	"Castcrab" : 0,
	"Billterfly" : 0,
	"Corpofish" : 0,
}

# best possible score
var species_best_pose = {
	"Olturtle" : "Resting",
	"Burglerat" : "Eating",
	"Veerabbit" : "Scared",
	"Cowbug" : "Listening",
	"Pargopher" : "Partying",
	"Leghost" : "Spooked",
	"Bugleton" : "Bugling",
	"Cowbird" : "Eating",
	"Cresbird" : "Eating",
	"Vamphibian" : "Using Magic",
	"Frankendeer" : "Petrified",
	"Gold Burglerat" : "Resting",
	"Castcrab" : "Resting",
	"Corpofish" : "Swimming",
	"Billterfly" : "Flying"
}

var pose_score = {
	"Hiding" : 0,
	
	"Resting" : 1,
	"Walking" : 1,
	"Turning" : 1,
	"Flying" : 1,
	"Rolling" : 1,
	"Peeking" : 1,
	"Swimming" : 1,
	
	"Perched" : 2,
	"Judging" : 2,
	"Grazing" : 2,
	"Excited" : 2,
	"Waddling" : 2,
	"Roll Starting" : 2,
	"Roll Ending" : 2,
	
	"Eating" : 3,
	"Curious" : 3,
	
	"Listening" : 4,
	"Digging" : 4,
	"Petrified" : 4,
	# scared is a running animation
	"Scared" : 4,
	
	"Partying" : 5,
	"Confused" : 5,
	"Running" : 5,
	"Bugling" : 5,
	
	"Spooked" : 6,
	"Using Magic" : 6
}

func get_best_possible_score(creature):
	return base_score[creature] + 5 + 2 + species_same_max[creature] + 1 + pose_score[species_best_pose[creature]]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _process(delta: float) -> void:
	upload_timer -= delta
	if(state == "upload" and upload_timer < 0):
		$Upload.visible = false
		state = "grading"
		$Grading.visible = true
	$Shop/Buy1.visible = !Global.zoom_unlocked
	$Shop/Buy2.visible = !Global.quickscope_unlocked
	$Shop/Buy3.visible = !Global.bonus_film_unlocked
	$Shop/Buy4.visible = !Global.bait_unlocked
	$Shop/Buy5.visible = !Global.whistle_unlocked
	$Shop/Buy6.visible = !Global.shoes_unlocked
			
func sort_by_score(a,b):
	return a["score"] > b["score"]
	
func get_star_string(total,max):
	var retstr = ""
	for i in range(total):
		retstr += "★"
	for i in range(max-total):
		retstr += "☆"
	return retstr

func process_all_pictures():
	# score all photos, pick the highest scoring pic of each critter
	var pics_by_critter = {}
	for p in Global.pics.duplicate():
		var out = process_picture(p)
		for c in out:
			var cname = c["critter"]
			# check if it's in pics by critter
			if(pics_by_critter.has(cname) and pics_by_critter[cname]["score"] < c["score"]):
				# we have a better pic
				pics_by_critter[cname] = c
			elif not pics_by_critter.has(cname):
				# we have no other pic liek this
				pics_by_critter[cname] = c
	# done scoring
	# put into list
	pictures_to_grade = pics_by_critter.values()
	pictures_to_grade.sort_custom(sort_by_score)
	
func _input(event: InputEvent) -> void:
	if(Global.is_using_puter):
		Global.bait = 20
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
							upload_timer = 0.2 * (2+Global.pics.size())
							grading_index = 0
							ui_grade()
							$Background.visible = false
							state = "upload"
							$Upload.visible = true
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
					if $Shop/Buy1/Buy1.get_overlapping_bodies().size() == 1 and Global.money >= 40 and not Global.zoom_unlocked:
						Global.zoom_unlocked = true
						Global.money -= 40
					if $Shop/Buy2/Buy2.get_overlapping_bodies().size() == 1 and Global.money >= 25 and not Global.quickscope_unlocked:
						Global.quickscope_unlocked = true
						Global.money -= 25
					if $Shop/Buy3/Buy3.get_overlapping_bodies().size() == 1 and Global.money >= 30 and not Global.bonus_film_unlocked:
						Global.bonus_film_unlocked = true
						Global.money -= 30
						Global.picsmax = 40
					if $Shop/Buy4/Buy4.get_overlapping_bodies().size() == 1 and Global.money >= 20 and not Global.bait_unlocked:
						Global.bait_unlocked = true
						Global.money -= 20
					if $Shop/Buy5/Buy5.get_overlapping_bodies().size() == 1 and Global.money >= 60 and not Global.whistle_unlocked:
						Global.whistle_unlocked = true
						Global.money -= 60
					if $Shop/Buy6/Buy6.get_overlapping_bodies().size() == 1 and Global.money >= 15 and not Global.shoes_unlocked:
						Global.shoes_unlocked = true
						Global.money -= 15
					if $Shop/Next/Next.get_overlapping_bodies().size() == 1:
						state = "desktop"
						$Shop.visible = false
						$Background.visible = true
				
		# clamp to -.25 to 25
		# 0.15 to 0.45
	get_node("Mouse").position.x = clamp(get_node("Mouse").position.x,-0.25,0.25)
	get_node("Mouse").position.y = clamp(get_node("Mouse").position.y,0.13,0.46)

func ui_grade():
	var p = pictures_to_grade[grading_index]
	var cr = ImageTexture.create_from_image(p["pic"])
	cr.set_size_override(Vector2(200,150))
	$Grading/Preview.texture = cr
	$Grading/LabelJustLeft.text = p["ltext"]
	var critter = pictures_to_grade[grading_index]["critter"]
	if(Global.bests.has(critter)):
		var cr2 = ImageTexture.create_from_image(Global.bests[critter]["pic"])
		cr2.set_size_override(Vector2(40,30))
		$Grading/Old.texture = cr2
		$Grading/OldText.text = "Prev:" + str(Global.bests[critter].score)
	else:
		$Grading/Old.texture = null
	
	if(not Global.bests.has(critter)):
		$Grading/ProfText.text = wrap_text("Wow! This is your first picture of " + critter + ".")
	else:
		if(Global.bests[critter]["score"] > p["score"]):
			# Make Suggestions
			if (p["pdata"]["dist"] <= 3):
				$Grading/ProfText.text =  wrap_text("Get a close-up of " + critter + " for a better pic!")
			elif (p["pdata"]["orient"] == false):
				$Grading/ProfText.text =  wrap_text("I want to see the front of " + critter + "!")
			elif (p["pdata"]["diff"] < 2):
				$Grading/ProfText.text =  wrap_text("Imagine a pic with " + critter + " and another species!")
			elif (p["pdata"]["same"] < species_same_max[critter]):
				$Grading/ProfText.text =  wrap_text("I want to see " + str(species_same_max[critter]) + critter + "s in the same pic!")
			elif (p["pdata"]["pose"] != species_best_pose[critter]):
				$Grading/ProfText.text =  wrap_text("Hmm.. could you get" + critter + " " + species_best_pose[critter] + "???")
		else:
			$Grading/ProfText.text = wrap_text("This pic of " + critter + " is better than your last!")
			
func get_keys_sorted_by_score(dict: Dictionary) -> Array:
	var keys = dict.keys()
	keys.sort_custom(func(a, b):
		return dict[a]["score"] > dict[b]["score"]
	)
	return keys
	
func ui_review():
	for p in get_node("Review/PrevPics").get_children():
		p.get_node("S1").texture = nopic
		p.get_node("Name").text = "?????"
		p.get_node("Prev").text = "??/??"
		p.get_node("Name").modulate = Color(1,1,1,1)
		p.get_node("Prev").modulate = Color(1,1,1,1)
		
	var k = get_keys_sorted_by_score(Global.bests)
	var i = 0
	for key in k:
		var b = Global.bests[key]
		var cr = ImageTexture.create_from_image(b["pic"])
		cr.set_size_override(Vector2(90,75))
		get_node("Review/PrevPics").get_children()[i].get_node("S1").texture = cr
		get_node("Review/PrevPics").get_children()[i].get_node("Name").text = b["critter"]
		get_node("Review/PrevPics").get_children()[i].get_node("Name").modulate = Color(0,0,0,1)
		if(b["critter"] == "Gold Burglerat"):
			get_node("Review/PrevPics").get_children()[i].get_node("Name").text = "G. Burglerat"
		get_node("Review/PrevPics").get_children()[i].get_node("Prev").text = str(b["score"]) + "/" + str(get_best_possible_score(b["critter"]))
		get_node("Review/PrevPics").get_children()[i].get_node("Prev").modulate = Color(0,0,0,1)
		if(b["score"] == get_best_possible_score(b["critter"])):
			get_node("Review/PrevPics").get_children()[i].get_node("Prev").modulate = Color(0,0.4,0,1)
		i += 1
	

func process_picture(pic : Dictionary) -> Array:

	var out = []
	for c0 in pic["critters"]:
		
		var dist_rating = 0
		var dist_total = (c0["dist"])
		if (dist_total > 20):
			dist_rating = 5
		elif (dist_total > 10):
			dist_rating = 4
		elif (dist_total > 5):
			dist_rating = 3
		elif (dist_total > 2.5):
			dist_rating = 2
		elif (dist_total > 0.5):
			dist_rating = 1
		
		# no points if the critter is really far away
		if(dist_rating == 0):
			continue
		
		var base_val = base_score[c0["name"]]
		
		var same_val = clamp(pic["critters"].reduce(func(count, next): return count + 1 if c0["name"] == next["name"] else count, -1),0,species_same_max[c0["name"]])
		var dif_val = 0
		if(pic["critters"].reduce(func(count, next): return count + 1 if c0["name"] != next["name"] else count, 0) > 0):
			# they got different mon bonus
			dif_val = 2
			
		var pose_val = pose_score[c0["pose"]]
		var orient_good = c0["orient"] > 2
		if orient_good:
			pose_val += 1
		var best_possible_pose = pose_score[species_best_pose[c0["name"]]] + 1
			
		var total_score = (base_val + dist_rating + same_val + dif_val + pose_val)
		
		var left_text = ""
		
		if(c0["name"] == "Gold Buglerat"):
			left_text += "G. Buglerat" + "\n" + get_star_string(base_val,base_val) + "\n"
		else:
			left_text += c0["name"] + "\n" + get_star_string(base_val,base_val) + "\n"
			
		left_text += "SIZE\n" + get_star_string(dist_rating,5)+"\n"
		left_text += c0["pose"]
		if(orient_good):
			left_text += ",\nFACING CAM"
			
		left_text += "\n" + get_star_string(pose_val,best_possible_pose) + "\n"
		
		if(species_same_max[c0["name"]] > 0):
			left_text += str(species_same_max[c0["name"]]) + " OF THE SAME? \n" + get_star_string(same_val,species_same_max[c0["name"]]) + "\n"
			
		left_text += "OTHER SPECIES\n" + get_star_string(dif_val,2) + "\n"

		left_text += "TOTAL " + str(total_score) + " / " + str(get_best_possible_score(c0["name"]))
		
		var pdata = {
			"dist" : dist_rating,
			"pose" : pose_val,
			"orient" : orient_good,
			"same" : same_val,
			"diff" : dif_val
		}
		
		out.push_back({"score":total_score,"ltext":left_text,"pic":pic["image"],"critter":c0["name"],"pdata" : pdata})
	return out



func wrap_text(text: String, max_chars: int = 15) -> String:
	var words = text.split(" ")
	var lines: Array[String] = []
	var current_line = ""

	for word in words:
		if current_line == "":
			current_line = word
		elif current_line.length() + 1 + word.length() <= max_chars:
			current_line += " " + word
		else:
			lines.append(current_line)
			current_line = word

	if current_line != "":
		lines.append(current_line)

	return "\n".join(lines)
