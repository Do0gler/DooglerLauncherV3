extends MenuButton

@export var sorting_default_icon: Texture2D
@export var sorting_reversed_icon: Texture2D

## Maps sorting method names to their corresponding menu item indices.
const SORTING_MAP := {
	"alphabetical": 0,
	"date_created": 1,
	"play_time": 2,
	"size": 3,
}

var menu_popup: PopupMenu
var last_selected_index: int

func _enter_tree() -> void:
	menu_popup = get_popup()
	
	_add_sorting_option("Alphabetical")
	_add_sorting_option("Creation Date")
	_add_sorting_option("Play Time")
	_add_sorting_option("File Size")
	
	_set_enabled_icon(0)
	
	menu_popup.index_pressed.connect(_on_item_selected)


func _add_sorting_option(label: String, id := -1) -> void:
	menu_popup.add_multistate_item(label, 2, 0, id)
	menu_popup.set_item_icon_max_width(id, 25)


func _on_item_selected(index: int) -> void:
	# If the item was first selected, set to inital state (forward sorting)
	if last_selected_index != index:
		menu_popup.set_item_multistate(index, 0)
	else:
		menu_popup.toggle_item_multistate(index)
	
	var sorting_methods := SORTING_MAP.keys()
	var sorting_method: String = sorting_methods[index]
	
	var reversed_sorting = menu_popup.get_item_multistate(index) == 1
	
	GameOrganizer.set_sorting(sorting_method, reversed_sorting)
	
	_set_enabled_icon(index)
	last_selected_index = index


func _set_enabled_icon(enabled_id: int) -> void:
	for i in range(menu_popup.item_count):
		if i == enabled_id:
			var reversed_button_state = menu_popup.get_item_multistate(i) == 1
			var icon_texture = sorting_reversed_icon if reversed_button_state else sorting_default_icon
			menu_popup.set_item_icon(i, icon_texture)
			menu_popup.set_item_icon_modulate(i, Color.WHITE)
		else:
			# Set icon to transparent instead of removing to avoid item resizing
			menu_popup.set_item_icon_modulate(i, Color.TRANSPARENT)


## Updates the sorting button UI to reflect the given sorting state.
func set_sorting_ui(sorting: String, reversed: bool) -> void:
	var index: int = SORTING_MAP.get(sorting)
	menu_popup.set_item_multistate(index, 1 if reversed else 0)
	_set_enabled_icon(index)
	last_selected_index = index
