extends VBoxContainer


signal OK

onready var label = $Text
onready var arrow = $Text/Arrow
onready var animator = $Animator
onready var menus = get_node("/root/Root/Container/Menus")


func animate(dialogue):
	menus.visible = false
	
	visible = true
	grab_focus()
	animator.play("open")
	yield(animator, "animation_finished")
	
	if dialogue is Array or dialogue is PoolStringArray:
		for section in dialogue:
			yield(run_text(section), "completed")
	else:
		yield(run_text(dialogue), "completed")
	
	animator.play_backwards("open")
	yield(animator, "animation_finished")
	release_focus()
	visible = false
	
	menus.visible = true


func run_text(text):
	label.text = text
	animator.play("fade")
	yield(self, "OK")
	animator.play_backwards("fade")
	yield(animator, "animation_finished")


func input(event: InputEvent):
	if event.is_action_released("ui_accept"):
		emit_signal("OK")
