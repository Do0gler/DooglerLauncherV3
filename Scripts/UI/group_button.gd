extends MenuButton

@export var enabled_icon: Texture2D
@export var disabled_icon: Texture2D

var menu_popup: PopupMenu


func _ready() -> void:
	menu_popup = get_popup()
	
	add_category_option("Favorited", 0)
	add_category_option("Engine", 1)
	add_category_option("Completion Status", 2)
	add_category_option("None", 3)
	
	set_enabled_icon(0)
	
	menu_popup.index_pressed.connect(_on_item_selected)


func add_category_option(label: String, id := -1) -> void:
	menu_popup.add_item(label, id)
	menu_popup.set_item_icon_max_width(id, 25)


func _on_item_selected(index: int) -> void:
	match index:
		0: GameOrganizer.set_grouping("favorited")
		1: GameOrganizer.set_grouping("engine")
		2: GameOrganizer.set_grouping("status")
		3: GameOrganizer.set_grouping("none")
	set_enabled_icon(index)


func set_enabled_icon(enabled_id: int) -> void:
	for i in range(menu_popup.item_count):
		var icon_texture = enabled_icon if i == enabled_id else disabled_icon
		menu_popup.set_item_icon(i, icon_texture)
