extends MenuButton

var settings_submenu: PopupMenu

func _init() -> void:
	var menu = get_popup()
	# Create the check for updates button
	@warning_ignore("int_as_enum_without_match")
	menu.add_item("Check For Updates", -1, (KEY_MASK_CTRL | KEY_R) as Key)
	
	# Create the settings submenu
	settings_submenu = PopupMenu.new()
	
	settings_submenu.add_check_item("Check For Updates on Launch")
	settings_submenu.add_check_item("Discord Rich Presence")
	
	menu.add_submenu_node_item("Settings", settings_submenu)
	
	menu.index_pressed.connect(_on_item_selected)
	settings_submenu.index_pressed.connect(_on_subitem_selected)
	
	UIManager.settings_popup = settings_submenu


func _on_item_selected(index):
	match index:
		0:
			Updater.check_for_updates()


func _on_subitem_selected(index):
	var item_toggle := !settings_submenu.is_item_checked(index)
	settings_submenu.set_item_checked(index, item_toggle)
	# TODO: Apply settings 
	match index:
		0:
			Updater.auto_check_updates = item_toggle
		1:
			pass
	SettingsManager.save_settings()
