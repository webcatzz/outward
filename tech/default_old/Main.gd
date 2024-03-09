extends ColorRect


var player_data = {
	"location": "puddle",
	"has_watch": false,
	"time": 0,
	"visited": []
}
var location_data = {}

onready var background = $Margins/Squarer/Separator/Display/Panel/Background
onready var background_animator = $Margins/Squarer/Separator/Display/Animator
onready var movement = $Margins/Squarer/Separator/Controls/Grids/Movement
onready var movement_center = $Margins/Squarer/Separator/Controls/Grids/Movement/Act
onready var actions = $Margins/Squarer/Separator/Controls/Grids/Actions
onready var dialogue = $Margins/Squarer/Separator/Controls/Dialogue
onready var controls = $Margins/Squarer/Separator/Controls
onready var music = $Music


func _ready(): # loading data
	load_player()
	load_location(player_data["location"])


func _unhandled_input(event): # input
	if event.is_action_released("fullscreen"):
		controls.switch_panel("battle")
#		OS.window_fullscreen = !OS.window_fullscreen


func move(direction):
	load_location(location_data["neighbors"][direction])
	controls.last_grid_center.grab_focus()


func load_location(location):
	# reading location from file:
	var file = File.new()
	file.open("res://data/locations.json", File.READ)
	var content = parse_json(file.get_as_text())
	location_data = content[location]
	file.close()
	
	# resetting objects & controls:
	for object in background.get_children():
		if object.name != "Shaders":
			object.queue_free()
	for button in movement.get_children():
		button.disabled = true
	for button in actions.get_children():
		if button.name != "Move":
			button.queue_free()
	
	# executing location data:
	for key in location_data:
		match key:
			"intro":
				if not location in player_data["visited"]:
					dialogue.animate(location_data["intro"])
			"music":
				music.stream = load("res://music/" + location_data["music"] + ".wav")
				music.play()
			"objects":
				for object in location_data["objects"]:
					var sprite = load("res://tech/main/Object.tscn").instance()
					sprite.texture = load(location_data["objects"][object])
#					sprite.rect_position = Vector2(location_data["objects"][object][1], location_data["objects"][object][2])
					background.add_child(sprite)
			"actions":
				movement_center.disabled = false
				for action in location_data["actions"]:
					var button = Button.new()
					button.text = action + "..."
					button.set_script(load("res://tech/main/Action.gd"))
					button.response = location_data["actions"][action]
					button.connect("dialogue", dialogue, "animate")
					actions.add_child(button)
			"neighbors":
				for direction in location_data["neighbors"]:
					movement.get_node(direction.capitalize()).disabled = false
	
	# setting background:
	background_animator.play("fade")
	yield(background_animator, "animation_finished")
	if "background" in location_data:
		background.texture = load(location_data["background"])
	else:
		background.texture = load("res://assets/locations/" + location + ".png")
	background_animator.play_backwards("fade")
	
	# marking as visited:
	player_data["location"] = location
	if not location in player_data["visited"]:
		player_data["visited"].append(location)


func load_player():
	var file = File.new()
	if not file.file_exists("res://data/player.json"):
		save_player()
		return
	file.open("res://data/player.json", File.READ)
	var content = parse_json(file.get_as_text())
	player_data = content
	
	if player_data["has_watch"]:
		$Margins/Squarer/Separator/Display/Watch.visible = true


func save_player():
	var file = File.new()
	file.open("res://data/player.json", File.WRITE)
	file.store_line(to_json(player_data))
	file.close()
