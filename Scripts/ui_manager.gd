class_name UIManager
extends Node

signal game_displayed(game: GameData)

const GAME_PANEL := preload("uid://bvcj2bi1axw5w")
const TAG_PANEL := preload("uid://b0v6cly1gppm3")
const SCREENSHOT_PANEL := preload("uid://coh4r2ojhrsh7")
const EXPANDABLE_LIST := preload("uid://o8e3ooq2lp0l")

var settings_popup: PopupMenu
var relevant_games: Dictionary

@onready var loading_screen: Control = %LoadingScreen
@onready var screenshot_popup = %ScreenshotViewer


func _process(_delta: float) -> void:
	if not InstallManager.game_being_downloaded:
		return
	
	var selected_game = SettingsManager.manager.selected_game
	%InstallProgressBar.value = InstallManager.calculate_install_progress(selected_game)


func set_settings_ui(settings_dict: Dictionary):
	settings_popup.set_item_checked(0, settings_dict.get("auto_check_updates"))
	settings_popup.set_item_checked(1, settings_dict.get("rich_presence_enabled"))
	
	%SortButton.set_sorting_ui(settings_dict.get("sorting"), settings_dict.get("sorting_reversed"))
	%GroupButton.set_grouping_ui(settings_dict.get("grouping"))


func display_games_list() -> void:
	var games_vbox: VBoxContainer = %GamesVBox
	# Clear previous games
	for child in games_vbox.get_children():
		child.queue_free()
	
	var organized_games := GameOrganizer.get_organized_games()
	var button_group := ButtonGroup.new()
	
	for category in organized_games:
		_create_category_list(category, organized_games.get(category), button_group)


func _create_category_list(category_name: String, games: Array, button_group: ButtonGroup) -> void:
	var new_list: ExpandableList = EXPANDABLE_LIST.instantiate()
	%GamesVBox.add_child(new_list)
	new_list.list_name = category_name
	
	_populate_category_with_games(new_list, games, button_group)
	
	new_list.call_deferred("update_visuals")


func _populate_category_with_games(list: ExpandableList, games: Array, button_group: ButtonGroup) -> void:
	for game: GameData in games:
		game.game_panel = null
		
		if relevant_games.has(game.game_id):
			var game_panel := _create_game_panel(game, button_group)
			list.add_item(game_panel)
			game_panel.update_visuals()


func _create_game_panel(game: GameData, button_group: ButtonGroup) -> GamePanel:
	var new_game_panel: GamePanel = GAME_PANEL.instantiate()
	new_game_panel.game_data = game
	new_game_panel.set_button_group(button_group)
	game.game_panel = new_game_panel
	return new_game_panel


func _format_game_info(data_name: String, value: String) -> String:
	return "[color=gray]%-15s[/color] %s" % [data_name, value]


## Shows a game's info on the game display
func display_game(game: GameData) -> void:
	_update_game_header(game)
	_update_game_details(game)
	_update_game_action_buttons(game)
	_update_game_tags(game)
	_update_game_screenshots(game)
	
	game_displayed.emit(game)


func _update_game_header(game: GameData) -> void:
	%GameLogo.texture = game.icon
	%GameBackground.texture = game.background
	%GameNameLabel.text = game.game_name


func _update_game_details(game: GameData) -> void:
	_set_playtime_label(game)
	%GameDescription.text = game.description
	%DateLabel.text = _format_game_info("Date", game.creation_date)
	%EngineLabel.text = _format_game_info("Engine", game.engine)
	%SizeLabel.text = _format_game_info("File Size", str(game.file_size_mb) + "MB")
	_set_version_label(game)
	%FavoriteButton.set_pressed_no_signal(game.favorited)


func _set_playtime_label(game: GameData) -> void:
	%PlaytimeLabel.text = GameData.secs_to_time_string(game.playtime_secs)


func _set_version_label(game: GameData) -> void:
	if game.installed_version:
		%VersionLabel.text = _format_game_info("Version", game.installed_version)
	else:
		%VersionLabel.text = _format_game_info("Version", game.version_number)


func _update_game_action_buttons(game: GameData) -> void:
	if InstallManager.game_is_installed(game):
		_handle_installed_game_buttons(game)
	else: # Game is not installed
		_handle_uninstalled_game_buttons(game)


func _handle_installed_game_buttons(game: GameData) -> void:
	if game.launched:
		show_game_action_button(%StopButton)
	elif game.outdated:
		show_game_action_button(%UpdateButton)
	else:
		show_game_action_button(%PlayButton)
	
	%InstallButton.disabled = false
	%InstallProgressArea.hide()


func _handle_uninstalled_game_buttons(game: GameData) -> void:
	show_game_action_button(%InstallButton)
	
	var is_downloading = game == InstallManager.game_being_downloaded
	%InstallButton.disabled = is_downloading
	%InstallProgressArea.visible = is_downloading


func _update_game_tags(game: GameData) -> void:
	var tags_panel: GameInfoPanel = %TagsPanel
	tags_panel.visible = not game.tags.is_empty()
	tags_panel.clear_items()
	
	for tag in game.tags:
		var new_tag: Tag = TAG_PANEL.instantiate()
		new_tag.set_tag_name(tag)
		tags_panel.add_item(new_tag)


func _update_game_screenshots(game: GameData) -> void:
	var screenshots_panel: GameInfoPanel = %ScreenshotsPanel
	screenshots_panel.visible = not game.screenshots.is_empty()
	screenshots_panel.clear_items()
	
	for index in game.screenshots.size():
		var new_screenshot: Screenshot = SCREENSHOT_PANEL.instantiate()
		new_screenshot.set_screenshot(game.screenshots[index])
		new_screenshot.connect_button(%ScreenshotViewer.open_screenshot.bindv([game.screenshots, index]))
		
		screenshots_panel.add_item(new_screenshot)


## Update a games visuals in it's panel and main display if possible
func update_game_visuals(game: GameData) -> void:
	if game.game_panel:
		game.game_panel.update_visuals()
	
	if SettingsManager.manager.selected_game == game:
		display_game(game)


## Shows one of the main buttons in the game display
func show_game_action_button(button_to_show: Control) -> void:
	var action_buttons = [%InstallButton, %PlayButton, %StopButton, %UpdateButton]
	for button: Control in action_buttons:
		if button == button_to_show:
			button.show()
		else:
			button.hide()


## Prompts the user for confirmation to uninstall the current game
func show_uninstall_confirmation() -> void:
	# Ask for confirmation before uninstalling
	var confirmation := ConfirmationDialog.new()
	confirmation.title = "Uninstall Game"
	var game_name = SettingsManager.manager.selected_game.game_name
	confirmation.dialog_text = "Are you sure you want to uninstall %s?" % game_name
	confirmation.ok_button_text = "Uninstall"
	confirmation.unresizable = true
	
	confirmation.confirmed.connect(SettingsManager.manager.uninstall_selected_game)
	
	add_child(confirmation)
	confirmation.popup_centered(Vector2i(330, 100))
