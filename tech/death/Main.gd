extends ColorRect


func on_quit() -> void:
	get_tree().quit()


func on_continue() -> void:
	global.load_data()
	get_tree().change_scene("res://tech/default/Main.tscn")
