extends PanelContainer


var selected_item: Object

onready var slots = $Slots.get_children()


func _ready() -> void:
	update_inventory()


func add_item(item) -> void:
	if global.data.inventory.size() == 8:
		print("inventory full!")
	else:
		global.data.inventory.append(item)
		update_inventory()


func remove_item(item) -> void:
	global.data.inventory.remove(item)
	update_inventory()


func update_inventory() -> void:
	for slot in slots:
		slot.hint_tooltip = ""
		slot.icon = null
	for i in range(global.data.inventory.size()):
		slots[i].hint_tooltip = global.data.inventory[i].name
		slots[i].icon = global.data.inventory[i].texture


func item_selected(index: int) -> void:
	selected_item = slots.get_child(index)
