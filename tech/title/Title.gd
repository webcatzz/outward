extends Control


signal accept

enum TAB {DEFAULT, SETTINGS, NAME, DELETE_DATA}

onready var tabs = $Separator/Main/Tabs
onready var name_tabs = $Separator/Main/Tabs/Name
onready var name_input = $Separator/Main/Tabs/Name/Input/LineEdit
onready var animator = $Animator


var data_found


func _ready():
	data_found = true
	$Separator/Main/Tabs/Default/Play.text = "resume...?"
	
	$Separator/Main.visible = false
	yield(self, "accept")
	$Tip/Label.visible = false
	$Separator/Main.visible = true
	
	$Separator/Main/Tabs/Settings/Options/VolumeSlider.value = global.data.volume
	$Separator/Main/Tabs/Settings/Options/SaturationSlider.value = global.data.saturation


func _input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		emit_signal("accept")


func play():
	if data_found:
		get_tree().change_scene("res://tech/default/Main.tscn")
	else:
		animator.play("enter_name")
		tabs.switch_tab(TAB.NAME)
		name_input.grab_focus()
func switch_to_settings():
	tabs.switch_tab(TAB.SETTINGS)
func exit():
	get_tree().quit()
func switch_to_battle():
	global.start_battle(["Pawn", "Bishop", "Pawn"])


func set_volume(value):
	global.data.volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))
func set_saturation(value):
	global.data.saturation = value
func request_delete_data():
	$Separator/Main/Tabs/Settings/Restart/Confirmation.popup_centered()
func delete_data():
#	Directory.new().remove("res://data.json")
	pass
func close_settings():
	tabs.switch_tab(TAB.DEFAULT)


func on_name_input(input):
	if input.empty():
		animator.play("RESET")
		tabs.switch_tab(TAB.DEFAULT)
	else:
		global.data.name = input.strip_edges()
		$Separator/Main/Tabs/Name/Confirmation/Name.bbcode_text = "[center][wave]" + global.data.name + "[/wave]. Is that how you wish to be called?[/center]"
		name_tabs.current_tab = 1
func on_name_denied():
	name_tabs.current_tab = 0
	name_input.grab_focus()
func on_name_confirm():
#	name_tabs.current_tab = 2
	get_tree().change_scene("res://tech/default/Main.tscn")
