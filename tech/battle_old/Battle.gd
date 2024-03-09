extends ColorRect


enum ACTION_TYPE {DAMAGE, HEALING}

var battle_data = {
	"enemies": ["pawn", "bishop", "pawn"],
	"background": {
		0: Color("3f2832"),
		1: {
			"texture": "squares",
			"modulate": Color("181425"),
			"amplitude": -1,
			"pan_to": Vector2(0, 1),
		},
		2: {
			"texture": "squares",
			"modulate": Color("9e2835"),
			"pan_to": Vector2(0, 0.5),
		}
	}
}
var intros = [
	"The ground shakes. You shake with it.",
	"Tensions are rising.",
	"The atmosphere is electric.",
	"The hush is shattered like glass!",
	"A wild ` appears!",
	"A rogue ` accosts you!",
	"En garde! ` challenges you on your honor!",
	"` barges in like it's nobody's business!",
	"` is really very sorry for barging in.",
	"` asks you to go a little easy on them.",
	"` is admiring your skills.",
	"` is sweating bullets.",
	"` would like to go home now.",
]
var enemies: Array

onready var background = $Margins/Squarer/Rectangler/Container/Display/Background
onready var foreground = $Margins/Squarer/Rectangler/Container/Display/Foreground/Separator
onready var animator = $Margins/Squarer/Rectangler/Container/Controls/Animator
onready var buttons = $Margins/Squarer/Rectangler/Container/Controls/Buttons
onready var panel = $Margins/Squarer/Rectangler/Container/Controls/Panel
onready var dialogue = $Margins/Squarer/Rectangler/Container/Controls/Panel/Dialogue


func _ready():
	randomize()
	
	# loading battle:
	buttons.get_child(0).grab_focus()
	load_battle()
	
	# displaying intro:
	var intro = intros[randi() % intros.size()]
	intro = intro.replace("`", enemies[randi() % enemies.size()].type.to_upper())
	dialogue.animate(intro)


func pressed(button):
	match button:
		"attack":
			panel.current_tab = 1
			select_enemy()
		"act":
			panel.current_tab = 2
		"item":
			panel.current_tab = 3
		"run":
			panel.current_tab = 4
	animator.play("panel_open")


func select_enemy():
	for enemy in enemies:
		enemy.selector.focus_mode = FOCUS_ALL
		enemy.selector.disabled = false
	enemies[0].selector.grab_focus()
	
	yield()
	
	for enemy in enemies:
		enemy.selector.focus_mode = FOCUS_NONE
		enemy.selector.disabled = true
	buttons.get_child(0).grab_focus()


func affect(target):
	var type = ACTION_TYPE.DAMAGE
	var value = 5
	
	match type:
		ACTION_TYPE.DAMAGE:
			target.health.value -= value
		ACTION_TYPE.HEALING:
			target.health.value += value
	
	if target.health.value == 0:
		find_next_valid_focus().grab_focus()
		target.queue_free()
		enemies = foreground.get_children()


func run():
	printerr(get_tree().change_scene("res://tech/main/Main.tscn"))


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		animator.play_backwards("panel_open")


func load_battle():
	# loading enemies:
	var enemy_base = load("res://tech/battle/Enemy.tscn")
	for enemy in battle_data["enemies"]:
		var new_enemy = enemy_base.instance()
		new_enemy.type = enemy
		foreground.add_child(new_enemy)
	enemies = foreground.get_children()
	
	# setting background:
	var layer_base = load("res://tech/battle/background_layer.tscn")
	for layer in battle_data["background"].values():
		# setting color:
		if layer is Color:
			background.color = layer
			continue
		
		# adding layers:
		var new_layer = layer_base.instance()
		for parameter in layer.keys():
			match parameter:
				"texture":
					new_layer.texture = load("res://assets/battle/" + layer["texture"] + ".png")
				"modulate":
					new_layer.modulate = layer["modulate"]
				"amplitude":
					new_layer.material.set_shader_param("amplitude", new_layer.material.get_shader_param("amplitude") * layer["amplitude"])
				"pan_to":
					new_layer.material.set_shader_param("scroll_direction", layer["pan_to"])
		background.add_child(new_layer)
