extends TabContainer


onready var animator = $Animator


func switch_tab(index):
	if current_tab < index:
		animator.play("rotate_left")
		yield(animator, "animation_finished")
		animator.play_backwards("rotate_right")
	else:
		animator.play("rotate_right")
		yield(animator, "animation_finished")
		animator.play_backwards("rotate_left")
	current_tab = index
	
#	match current_tab:
#		0, 2:
#			get_current_tab_control().get_child(0).grab_focus()
#		1:
#			get_current_tab_control().get_child(get_child_count() - 1).grab_focus()
