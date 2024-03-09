extends Node


var data = preload("res://data/player/Player.tres")

onready var viewport = get_tree().get_root()


func _ready():
	OS.min_window_size = Vector2(800, 600)


func _input(event: InputEvent):
	if event.is_action_released("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen


func set_input(value: bool):
	viewport.gui_disable_input = !value
#	if value: # == true:
#		Input.set_default_cursor_shape(0)
#	else:
#		Input.set_default_cursor_shape(8)


func start_battle(enemy_list: Array):
	get_tree().change_scene("res://tech/battle/Main.tscn")
	yield(get_tree(), "idle_frame")
	viewport.get_node("Root").add_enemies(enemy_list)


func save_data():
	ResourceSaver.save("res://data/player/Player.tres", data)
