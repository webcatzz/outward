extends Control


enum ACTION_TYPE {DAMAGE, HEALING}

var defense = 0
var actions: Dictionary

export(String, "pawn", "bishop") var type

onready var arrow = $Container/VBox/Arrow
onready var sprite = $Container/VBox/Sprite
onready var health = $Container/VBox/Health
onready var selector = $Container/Selector


func _ready():
	match type:
		"pawn":
			health.max_value = 10
			actions = {
				"Shortblade": {ACTION_TYPE.DAMAGE:  5},
			}
		"bishop":
			health.max_value = 10
			actions = {
				"Smite": {ACTION_TYPE.DAMAGE: 5},
				"Soft Prayer": {ACTION_TYPE.HEALING: 5},
			}
	
	sprite.texture = load("res://assets/battle/sprites/" + type + ".png")
	health.value = health.max_value
	selector.connect("pressed", get_node("/root/Battle"), "affect", [self])


func take_turn():
	var chosen_action = actions.keys()[0]
	actions[chosen_action][ACTION_TYPE.DAMAGE]
	
#	var preferred_action: Array
#	if health < max_health/4:
#		preferred_action.append(ACTION_TYPE.HEALING)


func on_focus():
	arrow.visible = !arrow.visible
	health.visible = !health.visible
