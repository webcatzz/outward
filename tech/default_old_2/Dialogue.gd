extends VBoxContainer


signal next_section
signal finished

var rate = 0.05
var instant = false

onready var ui = get_parent()
onready var name_label = $Name
onready var text = $Text
onready var next_icon = $Text/Next
onready var timer = $Timer


func animate(dialogue, speaker):
	ui.current_tab = 1
	set_process_input(true)
	grab_focus()
	
	# setting speaker:
	if speaker is String:
		name_label.text = speaker
		name_label.visible = true
	else:
		name_label.visible = false
	
	# typing response:
	if instant:
		if dialogue is Array:
			for i in dialogue:
				text.bbcode_text = dialogue
				yield(self, "next_section")
		else:
			text.bbcode_text = dialogue
			yield(self, "next_section")
	else:
		if dialogue is Array:
			for i in dialogue:
				yield(run_through(i), "completed")
		else:
			yield(run_through(dialogue), "completed")
	
	ui.current_tab = 0
	get_node("/root/Root/Margins/UI/Tabs/Actions").get_child(0).grab_focus()
	set_process_input(false)
	emit_signal("finished")
	rate = global.data["options"]["dialogue_rate"]


func run_through(dialogue):
	text.percent_visible = 0
	text.bbcode_text = dialogue
	timer.start(rate)
	
	for letter in dialogue:
		yield(timer, "timeout")
		if text.percent_visible == 1:
			break
		if letter in [".", "!", "?", ":"]:
			timer.start(rate * 10)
		elif letter == ",":
			timer.start(rate * 5)
		else:
			timer.start(rate)
		text.visible_characters += 1
	
	next_icon.visible = true
	yield(self, "next_section")
	next_icon.visible = false


func _input(event):
	if event.is_action_released("ui_accept"):
		if text.percent_visible < 1:
			text.percent_visible = 1
		else:
			emit_signal("next_section")
	
	# speeding up:
	elif event.is_action_pressed("modify"):
		rate /= 5
	elif event.is_action_released("modify"):
		rate *= 5
