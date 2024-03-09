extends RichTextLabel


signal next_section

var stopped = false
var wait = 0.05

onready var timer = $Timer
onready var animator = $Animator
onready var next_icon = $Next


# issues with skipping. leads to "stacking".
# speeds up, sometimes closes prematurely.
# need to find a way to stop that for loop!


func animate(response):
	# grabbing focus:
	grab_focus()
	
	# fading in:
	percent_visible = 0
	visible = true
	set_process_input(true)
	animator.play("fade", 0, 5, false)
	yield(animator, "animation_finished")
	
	# typing response:
	stopped = false
	for section in response:
		if stopped:
			break
		percent_visible = 0
		bbcode_text = section
		timer.start(wait)
		
		for letter in text:
			yield(timer, "timeout")
			if percent_visible == 1 or stopped:
				break
			if letter in [".", "!", "?", "-", ":"]:
				timer.start(wait * 10)
			elif letter == ",":
				timer.start(wait * 5)
			else:
				timer.start(wait)
			visible_characters += 1
		
		next_icon.visible = true
		yield(self, "next_section")
		next_icon.visible = false
	
	stop()


func stop():
	percent_visible = 1
	stopped = true
	
	# returning focus:
	get_parent().last_grid_center.grab_focus()
	set_process_input(false)
	
	# fading out:
	animator.play("fade", 0, -10, true)
	yield(animator, "animation_finished")
	visible = false


func _input(event):
	# skipping animation & requesting next section:
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
