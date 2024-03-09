extends MarginContainer


var data: Dictionary
var max_health: int
var health: int = max_health

export var player: bool

onready var health_bar = $Separator/Health/Meter
onready var arrow = $Arrow
onready var animator = $Animator
onready var music = get_node("/root/Root/Music")

func _ready():
	if player:
		name = global.data.name
		$Separator/Info/Separator/Level.text = "LV. " + String(global.data.level)
		$Separator/Info/Icon.texture = load("res://assets/battle/icons/player.png")
		max_health = 100
		health = global.data.health
	else:
		name = data["name"]
		$Separator/Info/Separator/Level.text = "LV. " + String(data["level"])
		$Separator/Info/Icon.texture = load("res://assets/battle/icons/" + name.to_lower() + ".png")
		max_health = data["max_health"]
		health = data["health"]
	
	$Separator/Info/Separator/Name.text = name
	health_bar.max_value = max_health
	health_bar.value = health
	arrow.position.x = rect_size.x / 2
	rect_pivot_offset = rect_size / 2


func affect_health(value: int):
	health += value
	health = clamp(health, 0, max_health)
	health_bar.value = health
	
	if value < 0:
		animator.play("hurt")
	else:
		animator.play("heal")
	yield(animator, "animation_finished")
	
	if health == 0:
		modulate.v = 0.5
		if player:
			get_tree().change_scene("res://tech/death/Main.tscn")
	
	if player and health < max_health/3:
		music.pitch_scale = (1 - (float(health) * 3 / max_health)) * 0.5 + 1
