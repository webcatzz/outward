extends Control


onready var minute_hand = $Sprite/Minutes
onready var hour_hand = $Sprite/Hours

onready var ticking = $Ticking
onready var animator = $Animator

var minutes = 0


func _input(event):
	if event.is_action_pressed("modify"):
		show_watch()
	if event.is_action_released("modify"):
		hide_watch()


func show_watch():
	ticking.play()
	animator.play("pull")


func hide_watch():
	animator.play_backwards("pull")
	ticking.stop()


func every_minute():
	minute_hand.rect_rotation += 6
	minutes += 1
	if minutes == 60:
		hour_hand.rect_rotation += 6
		minute_hand.rect_rotation = 0
		minutes = 0
