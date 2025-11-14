extends MenuButton

var menu: PopupMenu

func _ready() -> void:
	menu = get_popup()
	
	# Add options
	menu.add_item("Uninstall")
	menu.add_item("Open Installation Location")
	menu.add_item("Clear Image Cache")
	
	# Connect signals
	menu.index_pressed.connect(_on_item_selected)
	SettingsManager.manager.game_selected.connect(_on_game_selected)


func _on_game_selected(game: GameData):
	menu.set_item_disabled(0, not InstallManager.game_is_installed(game))
	menu.set_item_disabled(1, not InstallManager.game_is_installed(game))


func _on_item_selected(index: int) -> void:
	match index:
		0:
			pass # TODO: Implement option functionality
		1:
			SettingsManager.manager.open_selected_game_file_location()
		2:
			var game_id = SettingsManager.manager.selected_game.game_id
			CacheManager.clear_image_cache(game_id)
