class_name UIManager
extends Node

signal game_displayed(game: GameData)

const GAME_PANEL := preload("uid://bvcj2bi1axw5w")
const TAG_PANEL := preload("uid://b0v6cly1gppm3")
const SCREENSHOT_PANEL := preload("uid://coh4r2ojhrsh7")
const EXPANDABLE_LIST := preload("uid://o8e3ooq2lp0l")

var settings_popup: PopupMenu
var relevant_games: Dictionary
var downloading := false

@onready var loading_screen: Control = %LoadingScreen
@onready var screenshot_popup = %ScreenshotViewer


func _process(_delta: float) -> void:
	if not downloading:
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
		var new_list: ExpandableList = EXPANDABLE_LIST.instantiate()
		games_vbox.add_child(new_list)
		new_list.list_name = category
		for game: GameData in organized_games.get(category):
			# If not relevant, don't show
			if not relevant_games.has(game.game_id):
				continue
			
			var new_GAME_PANEL: GamePanel = GAME_PANEL.instantiate()
			new_GAME_PANEL.game_data = game
			new_GAME_PANEL.set_button_group(button_group)
			new_GAME_PANEL.update_visuals()
			new_list.add_item(new_GAME_PANEL)
		new_list.call_deferred("update_visuals") # wait for list items to be positioned


func _format_game_info(data_name: String, value: String) -> String:
	return "[color=gray]%-15s[/color] %s" % [data_name, value]


## Shows a game's info on the game display
func display_game(game: GameData) -> void:
	%GameLogo.texture = game.icon
	%GameBackground.texture = game.background
	%GameNameLabel.text = game.game_name
	if game.executable_name.get_extension() == "html":
		%PlaytimeLabel.text = "N/A"
	else:
		%PlaytimeLabel.text = GameData.secs_to_time_string(game.playtime_secs)
	%GameDescription.text = game.description
	%DateLabel.text = _format_game_info("Date", game.creation_date)
	%EngineLabel.text = _format_game_info("Engine", game.engine)
	%SizeLabel.text = _format_game_info("File Size", str(game.file_size_mb) + "MB")
	if game.installed_version:
		%VersionLabel.text = _format_game_info("Version", game.installed_version)
	else:
		%VersionLabel.text = _format_game_info("Version", game.version_number)
	%FavoriteButton.set_pressed_no_signal(game.favorited)
	
	if InstallManager.game_is_installed(game):
		if GameLauncher.launched_game and GameLauncher.launched_game.game_id == game.game_id:
			show_game_button(%StopButton)
		else:
			show_game_button(%PlayButton)
	else:
		show_game_button(%InstallButton)
	
	var tags_panel: GameInfoPanel = %TagsPanel
	tags_panel.visible = not game.tags.is_empty()
	tags_panel.clear_items()
	
	for tag in game.tags:
		var new_tag: Tag = TAG_PANEL.instantiate()
		new_tag.set_tag_name(tag)
		tags_panel.add_item(new_tag)
	
	var screenshots_panel: GameInfoPanel = %ScreenshotsPanel
	screenshots_panel.visible = not game.screenshots.is_empty()
	screenshots_panel.clear_items()
	
	for screenshot in game.screenshots:
		var new_screenshot: Screenshot = SCREENSHOT_PANEL.instantiate()
		new_screenshot.set_screenshot(screenshot)
		new_screenshot.connect_button(%ScreenshotViewer.open_screenshot.bind(screenshot))
		
		screenshots_panel.add_item(new_screenshot)
	
	game_displayed.emit(game)


## Shows one of the main buttons in the game display
func show_game_button(button_to_show: Control) -> void:
	%InstallButton.hide()
	%PlayButton.hide()
	%StopButton.hide()
	%UpdateButton.hide()
	button_to_show.show()


## Sets game display UI to it's installing mode
func set_game_display_installing() -> void:
	show_game_button(%InstallButton)
	downloading = true
	%InstallButton.disabled = true
	%InstallProgressArea.show()


## Sets game display UI to it's installed mode
func set_game_display_installed() -> void:
	show_game_button(%PlayButton)
	downloading = false
	%InstallButton.disabled = false
	%InstallProgressArea.hide()


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
