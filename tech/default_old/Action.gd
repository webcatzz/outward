extends Button


signal dialogue(response)

var response


func _pressed():
	emit_signal("dialogue", response)
