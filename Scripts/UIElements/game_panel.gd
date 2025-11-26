class_name GamePanel
extends PanelContainer

var color_running := Color("9cff91ff").to_html()
var color_installing := Color("91e5ffff").to_html()
var color_uninstalled := Color("a6a6a6").to_html()

var game_data: GameData
var popup_menu: PopupMenu
var settings_submenu: PopupMenu


func _ready() -> void:
	popup_menu = %PopupMenu
	
	%Button.pressed.connect(_on_pressed)
	%Button.gui_input.connect(_on_button_gui_input)
	
	popup_menu.index_pressed.connect(_on_context_item_selected)
	
	_setup_context_menu()


func set_button_group(button_group: ButtonGroup) -> void:
	%Button.button_group = button_group


func update_visuals() -> void:
	%NameLabel.text = _get_formatted_game_name()
	%Icon.texture = game_data.icon
	%UpdateIndicator.visible = game_data.outdated
	_update_context_menu()


func _setup_context_menu() -> void:
	popup_menu.add_item("Play")
	popup_menu.add_item("Favorite")
	
	settings_submenu = PopupMenu.new()
	settings_submenu.add_item("Uninstall")
	settings_submenu.add_item("Open Installation Location")
	settings_submenu.add_item("Clear Image Cache")
	
	popup_menu.add_submenu_node_item("Manage", settings_submenu)
	settings_submenu.index_pressed.connect(_on_context_subitem_selected)
	_update_context_menu()


func _update_context_menu() -> void:
	var game_installed := InstallManager.game_is_installed(game_data)
	
	_handle_context_action_button(game_installed)
	_handle_context_favorite_button()
	
	settings_submenu.set_item_disabled(0, not game_installed)
	settings_submenu.set_item_disabled(1, not game_installed)


func _handle_context_action_button(game_installed: bool) -> void:
	var game_installing := InstallManager.game_being_downloaded != null
	
	if game_installed:
		if game_data.launched:
			popup_menu.set_item_text(0, "Stop")
			popup_menu.set_item_metadata(0, "stop")
			popup_menu.set_item_disabled(0, false)
		elif game_data.outdated:
			popup_menu.set_item_text(0, "Update")
			popup_menu.set_item_metadata(0, "update")
			popup_menu.set_item_disabled(0, game_installing)
		else:
			popup_menu.set_item_text(0, "Play")
			popup_menu.set_item_metadata(0, "play")
			popup_menu.set_item_disabled(0, false)
	else:
		popup_menu.set_item_disabled(0, game_installing)
		
		popup_menu.set_item_text(0, "Install")
		popup_menu.set_item_metadata(0, "install")
	


func _handle_context_favorite_button() -> void:
	var item_text = "Remove from Favorites" if game_data.favorited else "Favorite"
	popup_menu.set_item_text(1, item_text)


func _on_context_item_selected(index):
	match index:
		0:
			_handle_context_action_button_selected(popup_menu.get_item_metadata(index))
		1:
			SettingsManager.manager.set_game_favorite(game_data, not game_data.favorited)


func _handle_context_action_button_selected(meta: String) -> void:
	match meta:
		"play":
			GameLauncher.launch_game(game_data)
		"update":
			await InstallManager.update_game(game_data)
		"install":
			await InstallManager.install_game(game_data)
		"stop":
			GameLauncher.stop_current_game()
	SettingsManager.ui_manager.update_game_visuals(game_data)


func _on_context_subitem_selected(index):
	match index:
		0:
			InstallManager.uninstall_game(game_data)
			SettingsManager.ui_manager.update_game_visuals(game_data)
		1:
			SettingsManager.manager.open_game_file_location(game_data)
		2:
			CacheManager.clear_image_cache(game_data.game_id)


## Returns the formatted game name, displaying game status if applicable
func _get_formatted_game_name() -> String:
	if InstallManager.game_is_installed(game_data):
		if game_data.launched:
			return "[color=%s]%s - Running[/color]" % [color_running ,game_data.game_name]
		else:
			return game_data.game_name
	elif game_data == InstallManager.game_being_downloaded:
		return "[color=%s]%s - Installing[/color]" % [color_installing, game_data.game_name]
	else:
		return "[color=%s]%s[/color]" % [color_uninstalled, game_data.game_name]


func _on_pressed():
	SettingsManager.manager.select_game(game_data)


func _on_button_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var mouse_pos: Vector2 = event.global_position
		_update_context_menu()
		@warning_ignore("narrowing_conversion")
		popup_menu.popup(Rect2i(mouse_pos.x, mouse_pos.y, 200, 0))
