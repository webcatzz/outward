extends MarginContainer


var data = {
	"max_health": 10,
	"actions": {
		"Attack": [0, 1],
	},
	"party_actions": {
		"Attack": [0, 5],
	},
}
var type: String
var health: int = data["max_health"]
var morale: int = 0

onready var menu = $Control/Menu
onready var sprite = $Separator/Sprite
onready var health_bar = $Separator/HealthBar
onready var animator = $Animator
onready var tween = $Tween
onready var root = get_tree().get_root().get_node("Root")


func _ready():
	sprite.texture = load("res://assets/battle/sprites/" + type.to_lower() + ".png")
	sprite.rect_min_size = sprite.texture.get_size() * 2
	sprite.rect_pivot_offset = sprite.rect_min_size / 2
	$Particles.position = sprite.rect_min_size / 2
	health_bar.max_value = health
	health_bar.value = health


func do_turn() -> Array:
	animator.play("act")
	return data["actions"].values()[randi() % data["actions"].size()]


func affect_health(value: int):
	health += value
	health = clamp(health, 0, data["max_health"])
	health_bar.value = health
	
	if value < 0:
		animator.play("hurt")
	else:
		animator.play("heal")
	yield(animator, "animation_finished")
	
	if health == 0:
		queue_free()


func affect_morale(value: int):
	morale += value
	morale = clamp(morale, -100, 100)
	
	if value > 0:
		animator.play("happy")
	else:
		animator.play("sad")
	yield(animator, "animation_finished")
	
	if morale == 100 or morale == -100:
		queue_free()


func on_hover():
	for child in menu.get_children():
		child.queue_free()
	root.enemy_selected(self, data["party_actions"])
	
	menu.visible = true
	tween.interpolate_property(sprite, "rect_position",
		Vector2.ZERO, Vector2(sprite.rect_size.x / 2, 0), 0.1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func on_hover_exit():
	menu.visible = false
	tween.interpolate_property(sprite, "rect_position",
		sprite.rect_position, Vector2.ZERO, 0.1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
