extends MarginContainer


onready var grids = $Grids
onready var movement = $Grids/Movement
onready var movement_center = $Grids/Movement/Act
onready var actions = $Grids/Actions
onready var actions_center = $Grids/Actions/Move
onready var dialogue = $Dialogue

onready var all_panels = [movement, actions]
onready var last_grid_center = $Grids/Actions/Move


func switch_panel(panel):
	for item in all_panels:
		item.visible = false
	match panel:
		"movement":
			movement.visible = true
			movement_center.grab_focus()
			last_grid_center = movement_center
		"actions":
			actions.visible = true
			actions_center.grab_focus()
			last_grid_center = actions_center
		"battle":
			printerr(get_tree().change_scene("res://tech/Battle.tscn"))
