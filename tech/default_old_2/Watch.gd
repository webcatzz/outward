extends TextureRect


onready var minute_hand = $MinuteHand
onready var hour_hand = $HourHand


func _ready():
	pass


func every_minute():
	minute_hand.rect_rotation += 6
	if minute_hand.rect_rotation == 380:
		hour_hand.rect_rotation += 6
		minute_hand.rect_rotation = 20
	if hour_hand.rect_rotation == 380:
		hour_hand.rect_rotation = 20
