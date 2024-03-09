extends PanelContainer

var location_data: Dictionary

onready var background = $Background
onready var actions = $Margins/UI/Tabs/Actions
onready var dialogue = $Margins/UI/Tabs/Dialogue
onready var music = $Music


func _ready():
	load_location(global.data["location"])


func act(action):
	var result = location_data["actions"][action]
	
	for key in result:
		match key:
			"dialogue":
				dialogue.animate(result["dialogue"], null)
				yield(dialogue, "finished")
			"move":
				load_location(result["move"])


func load_location(location):
	# loading from file:
	var file = File.new()
	file.open("res://data/locations.json", File.READ)
	var file_data = parse_json(file.get_as_text())
	file.close()
	if location in file_data:
		location_data = file_data[location]
	else:
		location_data = file_data["404"]
	
	# resetting:
	for i in actions.get_children():
		i.queue_free()
	
	# running through keys:
	for key in location_data:
		match key:
			"intro":
				if not location in global.data["visited"]:
					dialogue.animate(location_data["intro"], null)
			"music":
				music.stream = load("res://music/" + location_data["music"] + ".wav")
				music.play()
			"actions":
				for action in location_data["actions"]:
					var button = Button.new()
					button.text = action
					button.connect("pressed", self, "act", [button.text])
					actions.add_child(button)
				actions.get_child(0).grab_focus()
	
	# setting background:
	if "background" in location_data:
		background.texture = load(location_data["background"])
	else:
		background.texture = load("res://assets/locations/" + location + ".png")
	
	
	# marking as visited:
	global.data["location"] = location
	if not location in global.data["visited"]:
		global.data["visited"].append(location)
