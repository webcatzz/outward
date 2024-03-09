extends PanelContainer


onready var animator = $Animator


func _ready():
	$Panel/VBox/VolumeSlider.value = global.data.volume
	$Panel/VBox/SaturationSlider.value = global.data.saturation
	$Hello.text = "Hello, " + global.data.name + "."


func toggle():
	if visible:
		animator.play_backwards("open")
		yield(animator, "animation_finished")
		visible = false
	else:
		visible = true
		animator.play("open")


func set_volume(value: float):
	global.data.volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))


func set_saturation(value: float):
	global.data.saturation = value


func exit():
	get_tree().change_scene("res://tech/title/Main.tscn")
