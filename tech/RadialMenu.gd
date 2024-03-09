tool
extends Container
class_name RadialContainer


export(int) var radius = 100 setget set_radius
export(int, 0, 180) var separation = 30 setget set_separation
export(int, 359) var orientation = 0 setget set_orientation

var sprite_index: int


func _draw():
	modulate.a = 0
	draw_texture(load("res://assets/ui/dot.png"), Vector2(-3, -3))
	var tween = get_tree().create_tween()
	tween.set_ease(1)
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	
	var children = get_children()
	var angle = (deg2rad(separation) / -2) * (children.size() - 1) - deg2rad(orientation)
	for child in children:
		child.rect_size = child.rect_min_size
		child.rect_position = child.rect_size / -2
		tween.tween_property(child, "rect_position", Vector2(radius, 0).rotated(angle) - (child.rect_size / 2), 0.1)
		angle += deg2rad(separation)
	


func set_radius(value: int):
	radius = value
	update()


func set_separation(value: int):
	separation = value
	update()


func set_orientation(value: int):
	orientation = value
	update()
