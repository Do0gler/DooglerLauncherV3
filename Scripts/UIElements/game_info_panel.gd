@tool
extends VBoxContainer
class_name GameInfoPanel

@export var panel_name := "Info Panel":
	set(value):
		panel_name = value
		update_label()

func update_label() -> void:
	%NameLabel.text = panel_name

func add_item(item: Node) -> void:
	%InfoContainer.add_child(item)

func clear_items() -> void:
	for child in %InfoContainer.get_children():
		child.queue_free()
