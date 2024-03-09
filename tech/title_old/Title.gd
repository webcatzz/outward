extends PanelContainer


var data_found = false

onready var tabs = $Separator/Buttons/Margins/Centerer/Tabs
onready var name_tabs = $Separator/Buttons/Margins/Centerer/Tabs/Name
onready var name_input = $Separator/Buttons/Margins/Centerer/Tabs/Name/Input/LineEdit
onready var animator = $Animator


func _ready():
	if global.load_data():
		data_found = true
		$Separator/Buttons/Margins/Centerer/Tabs/Default/Play.text = "resume...?"


func play():
	if data_found:
		global.load_data()
		get_tree().change_scene("res://tech/main/Main.tscn")
	else:
		tabs.current_tab = 2
		name_input.grab_focus()


# Settings:

func open_settings():
	tabs.current_tab = 1


func set_volume(value):
	global.data["options"]["volume"] = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)


func set_saturation(value):
	global.data["options"]["saturation"] = value


func set_dialogue_mode(index):
	match index:
		0:
			global.data["options"]["dialogue_mode"] = "typewriter"
			$Separator/Buttons/Margins/Centerer/Tabs/Settings/DialogueHBox/DialogueRate.visible = true
		1:
			global.data["options"]["dialogue_mode"] = "instant"
			$Separator/Buttons/Margins/Centerer/Tabs/Settings/DialogueHBox/DialogueRate.visible = false


func set_dialogue_rate(value):
	global.data["options"]["dialogue_rate"] = value


func request_delete_data():
	$Separator/Buttons/Margins/Centerer/Tabs/Settings/Restart/Confirmation.popup_centered()


func delete_data():
	Directory.new().remove("res://data.json")


func close_settings():
	tabs.current_tab = 0


# Other stuff:

func quit():
	get_tree().quit()


func switch_to_battle():
	get_tree().change_scene("res://tech/battle/Battle.tscn")


# Name input:

func on_name_input(input):
	if input.empty():
		tabs.current_tab = 0
	else:
		global.data["name"] = input.strip_edges()
		$Separator/Buttons/Margins/Centerer/Tabs/Name/Confirmation/Name.bbcode_text = "[center][wave]" + global.data["name"] + "[/wave]. Is that how you wish to be called?[/center]"
		name_tabs.current_tab = 1


func on_name_denied():
	name_tabs.current_tab = 0
	name_input.grab_focus()


func on_name_confirm():
	name_tabs.current_tab = 2
	animator.play("fade_out")
	yield(animator, "animation_finished")
	get_tree().change_scene("res://tech/main/Main.tscn")
