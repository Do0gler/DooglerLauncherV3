extends MenuButton

@export var enabled_icon: Texture2D
@export var disabled_icon: Texture2D

## Maps grouping method names to their corresponding menu item indices.
const GROUPING_MAP := {
	"favorited": 0,
	"engine": 1,
	"status": 2,
	"none": 3,
}

var menu_popup: PopupMenu


func _enter_tree() -> void:
	menu_popup = get_popup()
	
	_add_category_option("Favorited")
	_add_category_option("Engine")
	_add_category_option("Completion Status")
	_add_category_option("None")
	
	_set_enabled_icon(0)
	
	menu_popup.index_pressed.connect(_on_item_selected)


func _add_category_option(label: String, id := -1) -> void:
	menu_popup.add_item(label, id)
	menu_popup.set_item_icon_max_width(id, 25)


func _on_item_selected(index: int) -> void:
	var grouping_methods := GROUPING_MAP.keys()
	var grouping_method: String = grouping_methods[index]
	
	GameOrganizer.set_grouping(grouping_method)
	_set_enabled_icon(index)


func _set_enabled_icon(enabled_id: int) -> void:
	for i in range(menu_popup.item_count):
		var icon_texture = enabled_icon if i == enabled_id else disabled_icon
		menu_popup.set_item_icon(i, icon_texture)

## Updates the grouping button UI to reflect the given grouping state.
func set_grouping_ui(grouping: String) -> void:
	var index: int = GROUPING_MAP.get(grouping)
	_set_enabled_icon(index)
