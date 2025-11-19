class_name ExpandableList
extends VBoxContainer

var disabled_icon := preload("uid://bkvsjbkmy76bp")
var enabled_icon := preload("uid://b7a6f88ddh4sy")

@onready var items_control := %ItemControl
@onready var item_vbox := %ItemVBox
@onready var head_button := %Head

var list_name := "MyList"
var number_of_items := 0

func _ready() -> void:
	head_button.toggled.connect(_on_toggled)
	head_button.icon = enabled_icon

func _on_toggled(toggle) -> void:
	if number_of_items > 0:
		head_button.icon = disabled_icon if toggle else enabled_icon
		toggle_expand(not toggle)

func add_item(item: Node) -> void:
	item_vbox.add_child(item)
	number_of_items += 1

func update_visuals() -> void:
	head_button.text = list_name + " (" + str(number_of_items) + ")"
	var items = item_vbox.get_children()
	if items.size() > 0:
		var last_child = items[items.size() - 1]
		items_control.custom_minimum_size.y = last_child.position.y + last_child.size.y

func toggle_expand(expand: bool) -> void:
	var expand_to: int = 0
	if expand:
		var items = item_vbox.get_children()
		if not items.is_empty():
			var last_child = items[items.size() - 1]
			expand_to = last_child.position.y + last_child.size.y
	var tween = create_tween()
	tween.tween_property(items_control, "custom_minimum_size", Vector2(0, expand_to), 0.1)
