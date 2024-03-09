extends ColorRect


var location_data: Dictionary
var file_data: Dictionary = {
	"puddle": {
		"intro": [
			"Your first sensation: your head is throbbing.",
			"You are freezing and sopping wet. You have no idea where you are."
		],
		"music": "wind",
		"actions": {
			[Vector2(32, 300)]: {
				"roll over": "move:puddle_sky",
			},
		},
	},
	"puddle_sky": {
		"intro": [
			"You roll over onto your back. A groan escapes your lips.",
			"The sky is... blinding.",
			"Ribbons of searing color ripple across it -- all bright crimsons and purples and chartreuses -- cutting into your poor, poor eyeballs.",
			"It is like those oily puddles of water from back home. You can just faintly remember them over your throbbing migraine.",
			"The ones near the gas station that a smaller you would always stop to marvel at.",
			"man.",
			"what happened to marvelling, huh?",
			"...",
			"The sky does nothing to help your headache. It is less familiar than you thought, but just as indifferent as always."
		],
		"music": "city_spectres",
		"actions": {
			[Vector2(768, 568), 135]: {
				"get up": [
					"dialogue:oh./oh man/but//ok/fine/here i go//here i go",
					{
						"DC": 50,
						true: "move:street_1",
						false: ["dialogue:nah", "move:puddle"],
					},
				],
			},
		},
	},
	"street_1": {
		"intro": "You get up, knees aching.",
		"actions": {
			[Vector2(120, 330), 20, 75]: {
				"walk": "move:street_2",
			},
		},
	},
	"street_2": {
		"intro": "where the fuck am i",
		"actions": {
			[Vector2(520, 500), 170, 75]: {
				"walk": "move:street_1",
			},
		},
	},
}

onready var background = $Container/Background
onready var menu_container = $Container/Menus
onready var inventory = $Container/Inventory
onready var dialogue = $Container/Dialogue
onready var roller = $Container/Roller
onready var settings = $Container/Settings
onready var animator = $Animator
onready var music = $Music


func _ready() -> void:
	load_location(global.data["location"])


func run_action(action) -> void:
	match typeof(action):
		TYPE_ARRAY:
			for i in action:
				yield(run_action(i), "completed")
		TYPE_STRING:
			if action.begins_with("dialogue"):
				yield(dialogue.animate(action.trim_prefix("dialogue:").split("/")), "completed")
			elif action.begins_with("move"):
				yield(load_location(action.trim_prefix("move:")), "completed")
		TYPE_DICTIONARY:
			yield(roller.roll(action["DC"]), "completed")
			if roller.passed in action:
				run_action(action[roller.passed])


func load_location(location: String) -> void:
	# loading from file:
#	var file = File.new()
#	file.open("res://data/locations.json", File.READ)
#	var file_data = parse_json(file.get_as_text())
#	file.close()
	if location in file_data:
		location_data = file_data[location]
	else:
		location_data = file_data["404"]
	
	# fading out:
	animator.play("fade")
	yield(animator, "animation_finished")
	
	# clearing menus & objects:
	for i in menu_container.get_children():
		i.queue_free()
	
	# sorting through location data:
	for key in location_data:
		match key:
			"intro":
				if not location in global.data.visited_locations:
					dialogue.animate(location_data["intro"])
			"music":
				if location_data["music"] == "stop": # testing for stop
					music.stop()
				else: # playing music
					music.set_stream(load("res://music/" + location_data["music"] + ".mp3"))
					music.play()
			"actions":
				for menu in location_data["actions"]: # adding menus
					var center = RadialContainer.new()
					
					if "intro" in location_data and not location in global.data.visited_locations:
						menu_container.visible = false
					
					# configuring menu settings:
					var setting_index = 0
					for setting in menu:
						match setting_index:
							0:
								center.rect_position = menu[0]
							1:
								center.orientation = menu[1]
							2:
								center.radius = menu[2]
							3:
								center.separation = menu[3]
						setting_index += 1
					
					# adding buttons:
					for action in location_data["actions"][menu]:
						var button = Button.new()
						button.text = action
						button.connect("pressed", self, "run_action", [location_data["actions"][menu][action]])
						center.add_child(button)
					menu_container.add_child(center)
			"objects":
				for object in location_data["objects"]: # adding objects
					var sprite = Sprite.new()
					sprite.texture = location_data["objects"][object]
					sprite.position = object
					background.add_child(sprite)
	
	# setting background & fading in:
	background.texture = load("res://assets/locations/" + location + ".png")
	animator.play_backwards("fade")
	
	# marking as visited:
	global.data.location = location
	if not location in global.data.visited_locations:
		global.data.visited_locations.append(location)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		settings.toggle()
	elif event.is_action_released("inventory"):
		inventory.visible = !inventory.visible
	elif event.is_action_released("travel"):
		get_tree().change_scene("res://tech/Traveller.tscn")
	elif event.is_action_released("save"):
		global.save_data()
