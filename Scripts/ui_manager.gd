extends Node
class_name UIManager

@export var game_panel: PackedScene
@export var tag_panel: PackedScene
@export var screenshot_panel: PackedScene

@onready var loading_screen: Control = %LoadingScreen
@onready var screenshot_popup = %ScreenshotViewer

var settings_popup: PopupMenu

func set_settings_state(settings_dict: Dictionary):
	settings_popup.set_item_checked(0, settings_dict.get("auto_check_updates", false))
	settings_popup.set_item_checked(1, settings_dict.get("rich_presence_enabled", false))


func display_games_list() -> void:
	var games_vbox: VBoxContainer = %GamesVBox
	# Clear previous games
	for child in games_vbox.get_children():
		child.queue_free()
	
	for game in SettingsManager.manager.games_library:
		var new_game_panel: GamePanel = game_panel.instantiate()
		new_game_panel.game_data = game
		new_game_panel.update_visuals()
		games_vbox.add_child(new_game_panel)


func format_game_info(data_name: String, value: String) -> String:
	return "[color=gray]%-15s[/color] %s" % [data_name, value]


func display_game(game: GameData) -> void:
	%GameLogo.texture = game.icon
	%GameBackground.texture = game.background
	%GameNameLabel.text = game.game_name
	%PlaytimeLabel.text = GameData.secs_to_time_string(game.playtime_secs)
	%GameDescription.text = game.description
	%DateLabel.text = format_game_info("Date", game.creation_date)
	%EngineLabel.text = format_game_info("Engine", game.engine)
	%SizeLabel.text = format_game_info("File Size", str(game.file_size_mb) + "MB")
	%VersionLabel.text = format_game_info("Version", game.version_number)
	
	var tags_panel: GameInfoPanel = %TagsPanel
	var screenshots_panel: GameInfoPanel = %ScreenshotsPanel
	
	tags_panel.visible = not game.tags.is_empty()
	tags_panel.clear_items()
	for tag in game.tags:
		var new_tag: Tag = tag_panel.instantiate()
		new_tag.set_tag_name(tag)
		tags_panel.add_item(new_tag)
	
	screenshots_panel.visible = not game.screenshots.is_empty()
	screenshots_panel.clear_items()
	for screenshot in game.screenshots:
		var new_screenshot: Screenshot = screenshot_panel.instantiate()
		new_screenshot.set_screenshot(screenshot)
		new_screenshot.get_node("Button").pressed.connect(%ScreenshotViewer.open_screenshot.bind(screenshot))
		
		screenshots_panel.add_item(new_screenshot)
