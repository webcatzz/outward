extends ColorRect


onready var reset = $Container/Separator/Reset


func _ready() -> void:
	$Container/Separator/Name.grab_focus()


func on_text_entered(text: String) -> void:
	if reset.pressed:
		global.data.visited_locations.clear()
	
	global.data.location = text
	get_tree().change_scene("res://tech/default/Main.tscn")
