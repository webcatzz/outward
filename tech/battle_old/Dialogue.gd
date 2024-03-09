extends RichTextLabel


signal next_section

var stopped = false
var wait = 0.05

onready var timer = $Timer
onready var next_icon = $Next
onready var return_to = get_node("/root/Battle/Margins/Squarer/Rectangler/Container/Controls/Buttons/Attack")
onready var animator = get_node("/root/Battle/Margins/Squarer/Rectangler/Container/Controls/Animator")


func animate(dialogue):
	grab_focus()
	set_process_input(true)
	
	animator.play("panel_open")
	yield(animator, "animation_finished")
	
	# typing response:
	stopped = false
	if dialogue is Array:
		for section in dialogue:
			if stopped:
				break
			yield(run_through(dialogue), "completed")
	else:
		yield(run_through(dialogue), "completed")
	
	stop()


func run_through(dialogue):
	percent_visible = 0
	bbcode_text = dialogue
	timer.start(wait)
	
	for letter in text:
		yield(timer, "timeout")
		if percent_visible == 1 or stopped:
			break
		if letter in [".", "!", "?", ":"]:
			timer.start(wait * 10)
		elif letter == ",":
			timer.start(wait * 5)
		else:
			timer.start(wait)
		visible_characters += 1
	
	next_icon.visible = true
	yield(self, "next_section")
	next_icon.visible = false


func stop():
	percent_visible = 1
	stopped = true
	
	return_to.grab_focus()
	set_process_input(false)
	
	animator.play_backwards("panel_open")


func _input(event):
	if event.is_action_released("ui_accept"):
		if percent_visible < 1:
			percent_visible = 1
		else:
			emit_signal("next_section")
	
	# closing dialogue:
	if event.is_action_released("ui_cancel"):
		stop()
	
	# speeding up:
	elif event.is_action_pressed("modify"):
		wait /= 5
	elif event.is_action_released("modify"):
		wait *= 5
