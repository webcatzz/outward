extends ColorRect


signal party_acted

enum EFFECT {DAMAGE, HEALING, PERFORMANCE, ITEM}

var enemy_data := {
	"Pawn": {
		"max_health": 10,
		"actions": {
			"Shortsword": [EFFECT.DAMAGE, 1],
		},
		"party_actions": {
			"Hug": [EFFECT.PERFORMANCE, 50]
		},
	},
	"Bishop": {
		"max_health": 10,
		"actions": {
			"Holy Bandaid": [EFFECT.HEALING, 1],
		},
		"party_actions": {
			"Hereticize": [EFFECT.PERFORMANCE, -50]
		},
	}
}

var blurbs := [
	"The ground shakes. You shake with it.",
	"The atmosphere is electric.",
	"You can do this.",
	"Are you trembling, or is %s?",
	"%s asks you to go a little easy on them.",
	"%s is admiring your skills.",
	"%s is sweating bullets.",
	"%s would like to go home now.",
	"%s is sobbing big fat tears."
]

onready var blurb = $Container/Blurb/Label
onready var display = $Container/Display
onready var enemy_list = $Container/Display/Enemies
onready var party_list = $Container/Bottom/Party
onready var status = $Container/Bottom/Status
onready var animator = $Animator
onready var timer = $Timer


func _ready():
	randomize()
	$Container/Display/Background.visible = true
	
	# setting background:
#	var background = load("res://tech/battle/backgrounds/Checkerboard.tscn").instance()
#	display.add_child(background)
#	display.move_child(background, 0)
	
	animator.play("player_turn")
	
	# adding party members:
	var party_member_base = load("res://tech/battle/PartyMember.tscn")
	for member in global.data["party"].keys():
		var party_member = party_member_base.instance()
		party_member.data = global.data["party"][member]
		party_list.add_child(party_member)
	
	yield(get_tree(), "idle_frame")
	
	run_party_turns()


func add_enemies(new_enemies: Array):
	var enemy_base = load("res://tech/battle/Enemy.tscn")
	for enemy in new_enemies:
		var new_enemy = enemy_base.instance()
		new_enemy.type = enemy
		new_enemy.data = enemy_data[enemy]
		enemy_list.add_child(new_enemy)
	
	blurb.text = blurbs[randi() % blurbs.size()].replace("%s", enemy_list.get_children()[randi()% enemy_list.get_child_count()].type)


func run_enemy_turns():
	global.set_input(false)
	animator.play("enemy_turn")
	
	timer.start(1)
	yield(timer, "timeout")
	
	# cycling thru enemy turns:
	for enemy in enemy_list.get_children():
		if is_instance_valid(enemy):
			var effect = enemy.do_turn()
			run_effect(effect[0], effect[1])
			if effect[0] == EFFECT.DAMAGE:
				status.text = enemy.type.to_upper() + " ATTACKS!"
				animator.play("status")
			timer.start(1)
			yield(timer, "timeout")
			status.visible = false
	
	if enemy_list.get_child_count() != 0:
		animator.play("fade_blurb")
		yield(animator, "animation_finished")
		blurb.text = blurbs[randi() % blurbs.size()].replace("%s", enemy_list.get_children()[randi()% enemy_list.get_child_count()].type)
		
		run_party_turns()
	else:
		on_victory()


func run_party_turns():
	global.set_input(true)
	animator.play("player_turn")
	
	for member in party_list.get_children():
		if member.health != 0 and enemy_list.get_child_count() != 0:
			member.arrow.visible = true
			yield(self, "party_acted")
			member.arrow.visible = false
	
	run_enemy_turns()


func run_effect(type: int, value: int, target: Object = null, player_action: bool = false):
	if target == null: # getting target if not specified:
		if type == EFFECT.DAMAGE: # attacks random party member
			var potential_targets = party_list.get_children()
			for member in party_list.get_children():
				if member.health == 0:
					potential_targets.erase(member)
			target = potential_targets[randi() % potential_targets.size()]
		elif type == EFFECT.HEALING: # heals most damaged enemy
			target = enemy_list.get_child(0)
			for enemy in enemy_list.get_children():
				if enemy.health < target.health:
					target = enemy
	
	# affecting target:
	match type:
		EFFECT.DAMAGE:
			target.affect_health(-value)
		EFFECT.HEALING:
			target.affect_health(value)
		EFFECT.PERFORMANCE:
			target.affect_morale(value)
		EFFECT.ITEM:
			pass
	
	if player_action:
		emit_signal("party_acted")


func enemy_selected(enemy: Object, actions: Dictionary = {}):
	for enemy in enemy_list.get_children():
		enemy.on_hover_exit()
	actions.merge({"Attack": [EFFECT.DAMAGE, 5]})
	for action in actions:
		var button = Button.new()
		button.text = action.to_lower()
		button.connect("pressed", self, "run_effect", [actions[action][0], actions[action][1], enemy, true])
		button.connect("pressed", enemy, "on_hover_exit")
		enemy.menu.add_child(button)


func on_victory():
	$Container/Confetti.visible = true
	$Container/Confetti.playing = true
	
	animator.play("fade_blurb")
	yield(animator, "animation_finished")
	blurb.text = "You won!"


func _on_Button_pressed() -> void:
	party_list.get_child(0).affect_health(-1)
