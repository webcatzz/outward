extends PanelContainer


signal OK

var passed: bool = false
var success_messages: PoolStringArray = [
	"CHECK PASSED!",
	"you dids it! smile",
	":O !!",
	"oh you actually passed that",
	"howd you dot aht",
	"HUH. OKAUY",
	"congratrulation s",
	"i am the coolest & sexiest person alive",
	"YEEEEAAAAAHH!!!!",
	"hell. yes.",
]
var fail_messages: PoolStringArray = [
	"CHECK FAILED!",
	"uou fucking FAIL. chump",
	":(",
	"have you tried. NOT failing",
	"stutid ass motherfucker",
	"what the hell is wrong with you",
	"well. i've seen better",
	"shit",
	"fuck",
	"goddamn",
]

onready var confetti = $Confetti
onready var number_container = $VBox/Number
onready var number = $VBox/Number/Raw
onready var modifier_label = $VBox/Number/Modifier
onready var DC_label = $VBox/DC
onready var result_label = $Result
onready var animator = $Animator
onready var timer = $Timer
onready var menus = get_node("/root/Root/Container/Menus")


func roll(DC) -> void:
	menus.visible = false
	DC_label.text = "DC: " + String(DC)
	visible = true
	randomize()
	
	for _i in range(20):
		number.text = String(randi() % 100 + 1)
		timer.start(0.05)
		yield(timer, "timeout")
	modifier_label.text = " + " + String(global.data["level"])
	modifier_label.visible = true
	
	animator.play("number")
	yield(animator, "animation_finished")
	
	if int(number.text) + global.data["level"] > DC:
		result_label.text = success_messages[randi() % success_messages.size()]
		result_label.modulate = Color.lime
		passed = true
		confetti.playing = true
		confetti.visible = true
	else:
		result_label.text = fail_messages[randi() % fail_messages.size()]
		result_label.modulate = Color.red
		passed = false
	
	animator.play("result")
	yield(animator, "animation_finished")
	yield(self, "OK")
	
	visible = false
	result_label.visible = false
	modifier_label.visible = false
	confetti.visible = false
	confetti.frame = 0
	
	menus.visible = true


func input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		emit_signal("OK")
