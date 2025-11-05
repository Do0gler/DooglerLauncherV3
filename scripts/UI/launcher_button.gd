extends MenuButton

func _ready() -> void:
	var menu = get_popup()
	# Create the check for updates button
	@warning_ignore("int_as_enum_without_match")
	menu.add_item("Check For Updates", -1, (KEY_MASK_CTRL | KEY_R) as Key)
	
	# Create the settings submenu
	var submenu := PopupMenu.new()
	
	submenu.add_check_item("Check For Updates on Launch")
	submenu.add_check_item("Discord Rich Presence")
	
	menu.add_submenu_node_item("Settings", submenu)
	
	menu.index_pressed.connect(_on_item_selected)
	submenu.index_pressed.connect(_on_subitem_selected)


func _on_item_selected(index):
	match index:
		0:
			%Updater.check_for_updates()


# TODO: Add functionality to buttons
func _on_subitem_selected(index):
	match index:
		0:
			print("Auto")
		1:
			print("RPC")
