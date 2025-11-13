extends MenuButton

@export var sorting_default_icon: Texture2D
@export var sorting_reversed_icon: Texture2D

var menu_popup: PopupMenu
var last_selected_index: int


func _ready() -> void:
	menu_popup = get_popup()
	
	add_sorting_option("Alphabetical", 0)
	add_sorting_option("Creation Date", 1)
	add_sorting_option("Play Time", 2)
	add_sorting_option("File Size", 3)
	
	set_enabled_icon(0)
	
	menu_popup.index_pressed.connect(_on_item_selected)


func add_sorting_option(label: String, id := -1) -> void:
	menu_popup.add_multistate_item(label, 2, 0, id)
	menu_popup.set_item_icon_max_width(id, 25)


func _on_item_selected(index: int) -> void:
	# If the item was first selected, set to inital state (forward sorting)
	if last_selected_index != index:
		menu_popup.set_item_multistate(index, 0)
	else:
		menu_popup.toggle_item_multistate(index)
	
	var sorting_method := ""
	var reversed_sorting = menu_popup.get_item_multistate(index) == 1
	
	match index:
		0: sorting_method = "alphabetical"
		1: sorting_method = "date_created"
		2: sorting_method = "play_time"
		3: sorting_method = "size"
	
	GameOrganizer.set_sorting(sorting_method, reversed_sorting)
	
	set_enabled_icon(index)
	last_selected_index = index


func set_enabled_icon(enabled_id: int) -> void:
	for i in range(menu_popup.item_count):
		if i == enabled_id:
			var reversed_button_state = menu_popup.get_item_multistate(i) == 1
			var icon_texture = sorting_reversed_icon if reversed_button_state else sorting_default_icon
			menu_popup.set_item_icon(i, icon_texture)
			menu_popup.set_item_icon_modulate(i, Color.WHITE)
		else:
			# Set icon to transparent instead of removing to avoid item resizing
			menu_popup.set_item_icon_modulate(i, Color.TRANSPARENT)
