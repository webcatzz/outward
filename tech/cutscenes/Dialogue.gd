extends VBoxContainer


signal next

onready var text = $Text
onready var animator = $Animator


func run(dialogue):
	animator.play("start")
	yield(animator, "animation_finished")
	if dialogue is Array:
		for i in dialogue:
			text.bbcode_text = i
			animator.play("reveal")
			yield(self, "next")
			animator.play_backwards("reveal")
			yield(animator, "animation_finished")
	else:
		text.bbcode_text = dialogue
		animator.play("reveal")
		yield(self, "next")
		animator.play_backwards("reveal")
		yield(animator, "animation_finished")
	
	animator.play("stop")


func _input(event):
	if event.is_action_released("ui_accept"):
		emit_signal("next")
